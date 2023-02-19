#!/usr/bin/env bash

set -euo pipefail

wget  --tries=2 -k -K  -E -r -l 10 -p -N -F --restrict-file-names=windows -nH localhost:3030

git add .