#!/usr/bin/env bash

OUTPUT_DIR="$HOME/Wideo"
mkdir -p "$OUTPUT_DIR"

find . -type f \( -iname '*.mkv' -o -iname '*.mp4' \) -print0 |
sort -z |
while IFS= read -r -d '' f; do

    echo "============================================"
    echo "Plik: $f"

    codec=$(ffprobe -v error -select_streams v:0 \
        -show_entries stream=codec_name \
        -of default=noprint_wrappers=1:nokey=1 "$f")

    resolution=$(ffprobe -v error -select_streams v:0 \
        -show_entries stream=width,height \
        -of csv=s=x:p=0 "$f")

    if [[ ! "$resolution" =~ ^[0-9]+x[0-9]+$ ]]; then
        echo "❌ Nie udało się odczytać rozdzielczości."
        continue
    fi

    width="${resolution%x*}"
    height="${resolution#*x}"

    echo "Kodek: $codec"
    echo "Rozdzielczość: ${width}x${height}"

    if (( width < 1920 )); then
        echo "⏩ Pomijam — szerokość poniżej 1920."
        continue
    fi

    out="$OUTPUT_DIR/$(basename "${f%.*}").mp4"

    if [ -e "$out" ]; then
        echo "⏩ Plik wynikowy już istnieje: $out"
        continue
    fi

    case "$codec" in
        h264)
            decoder=(-hwaccel cuda -hwaccel_output_format cuda -c:v h264_cuvid)
            filter="scale_npp=1280:720"
            ;;
        hevc)
            decoder=(-hwaccel cuda -hwaccel_output_format cuda -c:v hevc_cuvid)
            filter="scale_npp=1280:720"
            ;;
        av1)
            decoder=(-c:v libdav1d)
            filter="format=nv12,hwupload_cuda,scale_npp=1280:720"
            ;;
        *)
            echo "⏩ Nieobsługiwany kodek: $codec"
            continue
            ;;
    esac

    echo "✅ Rozpoczynam konwersję: $out"

    ffmpeg -hide_banner -nostdin -n \
        "${decoder[@]}" \
        -i "$f" \
        -vf "$filter" \
        -c:v h264_nvenc -preset fast \
        -b:v 1.2M \
        -c:a aac -b:a 128k \
        "$out"

    if [ $? -eq 0 ]; then
        echo "✅ Konwersja zakończona."
    else
        echo "❌ Błąd konwersji: $f"
    fi

done
