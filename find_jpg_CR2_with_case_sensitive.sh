#!/bin/bash

echo "=== USUWANIE: PLIKI .JPG Z ODPOWIEDNIKIEM .CR2 (rekurencyjnie, wielkość liter ma znaczenie) ==="

find . -type f -name "*.JPG" | while read -r jpg_file; do
    # Wyciągnięcie pełnej ścieżki bez rozszerzenia
    base_name="${jpg_file%.JPG}"

    # Jeśli istnieje dokładnie odpowiadający plik .CR2
    if [[ -f "${base_name}.CR2" ]]; then
        echo "Usuwam: $jpg_file (istnieje ${base_name}.CR2)"
        rm "$jpg_file"
    fi
done
