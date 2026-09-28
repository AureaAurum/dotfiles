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

# Exercise the installed Nushell's external completion callback through both profiles.
mkdir -p "$tmp/home/.cache/nushell" "$tmp/bin"
for name in mise zoxide carapace starship navi; do
    : > "$tmp/home/.cache/nushell/$name.nu"
done
cat > "$tmp/bin/carapace" <<'EOF'
#!/bin/sh
[ "$*" = 'git nushell git ch' ] || exit 1
printf '[{"value":"checkout ","description":"test candidate"}]\n'
EOF
chmod +x "$tmp/bin/carapace"
for profile in pc server; do
    HOME="$tmp/home" PATH="$tmp/bin:$PATH" nu --config "$tmp/$profile/.config/nushell/config.nu" -c '
        let values = ("git ch" | commandline complete --detailed | get value)
        if "checkout " not-in $values { error make {msg: "git completion failed"} }
    '
done
