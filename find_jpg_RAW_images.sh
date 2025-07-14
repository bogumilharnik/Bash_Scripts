#!/bin/bash

# Znajdź wszystkie pliki JPG bez względu na wielkość liter w rozszerzeniu
find . -maxdepth 1 -type f \( -iname "*.jpg" \) | while read -r jpg_file; do
    # Usuń ./ z początku ścieżki
    jpg_file="${jpg_file#./}"

    # Pobierz nazwę pliku bez rozszerzenia
    base_name="${jpg_file%.*}"

    # Szukaj odpowiadającego pliku CR2 (wielkość liter ignorowana)
    if find . -maxdepth 1 -type f -iname "${base_name}.cr2" | grep -q .; then
        echo "Usuwam: $jpg_file (istnieje ${base_name}.CR2)"
        rm "$jpg_file"
    else
        echo "Zostawiam: $jpg_file (brak CR2)"
    fi
done
