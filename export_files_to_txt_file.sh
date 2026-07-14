( find . -type d -print0 | sort -z | while IFS= read -r -d '' d; do
    printf -- "===== KATALOG: %s =====\n" "$d"
    find "$d" -maxdepth 1 -type f \
      ! -name 'wynik.txt' \
      ! -name 'vault.pass' \
      ! -path './.git/*' \
      -print0 | sort -z | while IFS= read -r -d '' f; do
        printf -- "----- PLIK: %s -----\n" "$f"
        cat "$f"
        printf -- "\n"
    done
    printf -- "\n"
  done ) > wynik.txt
