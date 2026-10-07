#!/usr/bin/env bash

# Skrypt: konwersja.sh
#
# MKV >= 1920 px -> MP4 1280x720
#
# GPU:
#   dekodowanie : NVIDIA CUVID
#   skalowanie  : CUDA
#   kodowanie   : NVIDIA NVENC

find . -type f -iname "*.mkv" -print0 |
while IFS= read -r -d '' f; do

    echo "============================================================"
    echo "Plik: $f"

    resolution=$(ffprobe -v error \
        -select_streams v:0 \
        -show_entries stream=width,height \
        -of csv=s=x:p=0 \
        "$f")

    if [ -z "$resolution" ]; then
        echo "   ❌ Nie udało się odczytać rozdzielczości — pomijam."
        echo
        continue
    fi

    width="${resolution%x*}"
    height="${resolution#*x}"

    echo "   Rozdzielczość: ${width}x${height}"

    if [ "$width" -ge 1920 ]; then

        out="${f%.*}.mp4"

        echo "   ✅ Konwertuję:"
        echo "      $f"
        echo "   →  $out"
        echo

        ffmpeg -hide_banner -nostdin \
            -hwaccel cuda \
            -hwaccel_output_format cuda \
            -c:v h264_cuvid \
            -i "$f" \
            -c:v h264_nvenc \
            -preset fast \
            -vf "scale_cuda=1280:720" \
            -b:v 1.2M \
            -b:a 128k \
            "$out"

        result=$?

        echo

        if [ "$result" -eq 0 ]; then
            echo "   ✅ Konwersja zakończona pomyślnie."
        else
            echo "   ❌ BŁĄD konwersji (kod: $result)"
            echo "      $f"
        fi

    else
        echo "   ⏩ Pomijam — szerokość mniejsza niż 1920."
    fi

    echo
done
