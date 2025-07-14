#!/bin/bash

echo "=== WERYFIKACJA: PLIKI .JPG, KTÓRE MAJĄ ODPOWIEDNIK .CR2 ==="

find . -type f \( -iname "*.jpg" \) | while read -r jpg_file; do
    # Wyciągnięcie ścieżki bez rozszerzenia
    base_name="${jpg_file%.*}"

    # Szukamy odpowiadającego pliku CR2 (niezależnie od wielkości liter)
    if find . -type f -iname "$(basename "$base_name").cr2" | grep -q .; then
        echo "[ZNALEZIONO] $jpg_file — ma odpowiadający .CR2"
    fi
done
