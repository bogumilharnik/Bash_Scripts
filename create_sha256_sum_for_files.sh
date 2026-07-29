find . -type f -name '*.ogg' -exec sh -c '
    [ -f "$1.sha256" ] && sha256sum -c --status "$1.sha256" && exit 0
    sha256sum "$1" > "$1.sha256"
' _ {} \;
