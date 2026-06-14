#!/usr/bin/env bash
set -Eeuo pipefail

trap 'echo "Błąd w linii $LINENO: $BASH_COMMAND" >&2' ERR

if [[ $EUID -ne 0 ]]; then
  echo "Uruchom ten skrypt jako root: sudo bash $0" >&2
  exit 1
fi

PREFIX="/opt/ffmpeg-gpu"
BUILD_DIR="/usr/local/src/ffmpeg-build"
FFMPEG_GIT="https://git.ffmpeg.org/ffmpeg.git"
NV_CODEC_HEADERS_GIT="https://git.videolan.org/git/ffmpeg/nv-codec-headers.git"

export DEBIAN_FRONTEND=noninteractive

echo "[1/7] Repozytoria i narzędzia bazowe..."
apt-get update
apt-get install -y software-properties-common ca-certificates curl git wget
add-apt-repository -y universe || true
add-apt-repository -y multiverse || true
apt-get update

echo "[2/7] Zależności budowania..."
apt-get install -y \
  build-essential \
  autoconf \
  automake \
  cmake \
  libtool \
  meson \
  ninja-build \
  pkg-config \
  nasm \
  yasm \
  make \
  python3 \
  zlib1g-dev \
  libass-dev \
  libdav1d-dev \
  libfdk-aac-dev \
  libmp3lame-dev \
  libopus-dev \
  libssl-dev \
  libvpx-dev \
  libx264-dev \
  libx265-dev \
  libfreetype6-dev \
  libnuma-dev

echo "[3/7] CUDA Toolkit (jeśli brakuje nvcc)..."
if ! command -v nvcc >/dev/null 2>&1; then
  if apt-cache show nvidia-cuda-toolkit >/dev/null 2>&1; then
    apt-get install -y nvidia-cuda-toolkit
  elif apt-cache show cuda-toolkit >/dev/null 2>&1; then
    apt-get install -y cuda-toolkit
  else
    echo "Nie znaleziono pakietu CUDA Toolkit w APT." >&2
    echo "Zainstaluj CUDA Toolkit zgodnie z dokumentacją NVIDIA i uruchom skrypt ponownie." >&2
    exit 1
  fi
fi

if ! command -v nvcc >/dev/null 2>&1; then
  echo "Po instalacji nadal brak nvcc. Przerywam." >&2
  exit 1
fi

export PATH="/usr/local/cuda/bin:${PATH}"
export LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH:-}"

echo "[4/7] Katalog roboczy..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "[5/7] nv-codec-headers..."
rm -rf nv-codec-headers
git clone "$NV_CODEC_HEADERS_GIT"
make -C nv-codec-headers -j"$(nproc)"
make -C nv-codec-headers install
ldconfig

echo "[6/7] FFmpeg źródła..."
rm -rf ffmpeg
git clone --depth 1 "$FFMPEG_GIT" ffmpeg
cd ffmpeg

echo "[7/7] Configure / build / install..."
./configure \
  --prefix="$PREFIX" \
  --pkg-config-flags=--static \
  --extra-cflags="-I/usr/local/cuda/include -I/usr/local/include" \
  --extra-ldflags="-L/usr/local/cuda/lib64 -L/usr/local/lib" \
  --enable-gpl \
  --enable-nonfree \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libvpx \
  --enable-libfdk-aac \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libass \
  --enable-openssl \
  --enable-cuda \
  --enable-cuda-nvcc \
  --enable-nvenc \
  --enable-libnpp \
  --enable-libdav1d

make -j"$(nproc)"
make install
ldconfig

echo
echo "Gotowe."
echo "FFmpeg: $PREFIX/bin/ffmpeg"
"$PREFIX/bin/ffmpeg" -hide_banner -version
echo
echo "Sprawdzenie kodeków/akceleracji:"
"$PREFIX/bin/ffmpeg" -hide_banner -decoders | grep -Ei 'av1|dav1d|cuvid' || true
"$PREFIX/bin/ffmpeg" -hide_banner -encoders | grep -Ei 'nvenc|libx264|libx265|libvpx|libmp3lame|libopus' || true
"$PREFIX/bin/ffmpeg" -hide_banner -filters  | grep -Ei 'cuda|npp' || true
