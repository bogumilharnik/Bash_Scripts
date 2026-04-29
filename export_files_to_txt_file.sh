#!/bin/bash

( find . -type d -print0 | sort -z | while IFS= read -r -d '' d; do     echo "===== KATALOG: $d =====";     find "$d" -maxdepth 1 -type f ! -name 'wynik.txt' -print0 | sort -z | while IFS= read -r -d '' f; do       echo "----- PLIK: $f -----";       cat "$f";       echo;     done;     echo;   done ) > wynik.txt