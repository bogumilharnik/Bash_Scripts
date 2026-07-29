find . -type f -name '*.ogg' -exec sh -c 'sha256sum "$1" > "$1.sha256"' _ {} \;
