#!/usr/bin/env bash

# Skrypt: konwersja.sh
# Konwersja plików MKV o rozdzielczości >= 1920px na MP4 (720p, NVENC)
# Wersja z -nostdin, odporna na spacje i znaki specjalne

find . -type f -iname "*.mkv" -print0 | while IFS= read -r -d '' f; do
    echo "Plik: $f"

    # Odczytaj rozdzielczość z metadanych
    resolution=$(ffmpeg -hide_banner -nostdin -i "$f" 2>&1 \
                 | grep "Video:" | grep -Po '\d{3,5}x\d{3,5}' | head -n 1)

    if [ -z "$resolution" ]; then
        echo "   ❌ Nie udało się odczytać rozdzielczości — pomijam."
        echo
        continue
    fi

    width=$(echo "$resolution" | cut -d'x' -f1)
    height=$(echo "$resolution" | cut -d'x' -f2)
    echo "   Rozdzielczość: ${width}x${height}"

    # Jeśli szerokość >= 1920 → konwertuj
    if [ "$width" -ge 1920 ]; then
        out="${f%.mkv}.mp4"
        echo "   ✅ Konwertuję (>=1920): $out"
        ffmpeg -hide_banner -nostdin \
               -hwaccel cuda -c:v h264 -i "$f" \
               -c:v h264_nvenc -preset fast \
               -vf "hwupload_cuda,scale_npp=1280:720" \
               -b:v 1.2M -b:a 128k "$out"
    else
        echo "   ⏩ Pomijam — rozdzielczość mniejsza niż 1920."
    fi
    echo
done
