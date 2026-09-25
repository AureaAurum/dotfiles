#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

bash -n pc/.bashrc
python3 - <<'PY'
import json
import tomllib
from pathlib import Path

for root in (Path('common'), Path('pc'), Path('server')):
    for path in root.rglob('*'):
        if path.suffix == '.json':
            json.loads(path.read_text())
        elif path.suffix == '.toml':
            tomllib.loads(path.read_text())
PY

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
for profile in pc server; do
    mkdir "$tmp/$profile"
    stow -d "$PWD" -t "$tmp/$profile" common "$profile"
    test -e "$tmp/$profile/.config/nushell/common_config.nu"
    test -e "$tmp/$profile/.config/nushell/common_env.nu"
    test -e "$tmp/$profile/.config/nushell/config.nu"
    test -e "$tmp/$profile/.config/nushell/env.nu"
done
