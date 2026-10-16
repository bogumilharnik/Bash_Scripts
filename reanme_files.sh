#!/bin/bash

for f in *; do
    # Usunięcie znaków #, ", (, ), |
    newname=$(echo "$f" | tr -d '#"()|')
    
    if [ "$f" != "$newname" ]; then
        mv -- "$f" "$newname"
        echo "Przemianowano: '$f' -> '$newname'"
    fi
done
