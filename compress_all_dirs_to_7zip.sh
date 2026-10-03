#!/bin/bash

for d in */; do 7z a -mx9 "${d%/}.7z" "$d"; done
