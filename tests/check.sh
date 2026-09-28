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
cat > "$tmp/home/.cache/nushell/zoxide.nu" <<'EOF'
export def --env --wrapped __zoxide_z [...rest: directory@complete_cd] {}
export alias cd = __zoxide_z
EOF
cat > "$tmp/bin/zoxide" <<'EOF'
#!/bin/sh
[ "$1" = query ] || exit 1
[ "$4" = tar ] || exit 0
printf '%s\n' "$TEST_HISTORY"
EOF
chmod +x "$tmp/bin/zoxide"
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

mkdir -p "$tmp/work/nearby" "$tmp/history/target"
for profile in pc server; do
    (
        cd "$tmp/work"
        HOME="$tmp/home" PATH="$tmp/bin:$PATH" TEST_HISTORY="$tmp/history/target" \
            nu --config "$tmp/$profile/.config/nushell/config.nu" -c '
                let history = ("cd tar" | commandline complete --detailed | get value)
                let local = ("cd nea" | commandline complete --detailed | get value)
                if $env.TEST_HISTORY not-in $history { error make {msg: "zoxide completion failed"} }
                if "nearby/" not-in $local { error make {msg: "directory completion failed"} }
            '
    )
done
