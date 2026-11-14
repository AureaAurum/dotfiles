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

# Exercise the installed Nushell's external and custom completion callbacks through both profiles.
mkdir -p "$tmp/home/.cache/nushell" "$tmp/bin"
for name in mise carapace starship navi; do
    : > "$tmp/home/.cache/nushell/$name.nu"
done

cat > "$tmp/home/.cache/nushell/zoxide.nu" <<'EOF'
export def --env --wrapped __zoxide_z [...rest: directory@complete_cd] {
  let path = match $rest {
    [] => {'~'},
    [ '-' ] => {'-'},
    [ $arg ] if ($arg | path expand | path type) == 'dir' => {$arg}
    _ => {
      ^zoxide query --exclude $env.PWD -- ...$rest | str trim -r -c "\n"
    }
  }
  cd $path
}
export alias cd = __zoxide_z
EOF

cat > "$tmp/bin/carapace" <<'EOF'
#!/bin/sh
[ "$*" = 'git nushell git ch' ] || exit 1
printf '[{"value":"checkout ","description":"test candidate"}]\n'
EOF
chmod +x "$tmp/bin/carapace"

ws="$tmp/ws"
cat > "$tmp/bin/zoxide" <<EOF
#!/bin/sh
if [ "\$1" = "query" ]; then
    printf '/\n/zoxide/first\n%s/real_dir\n' "$ws"
    exit 0
fi
exit 1
EOF
chmod +x "$tmp/bin/zoxide"

# Fixture directory tree for symlink & root completion regression tests
mkdir -p "$ws/real_dir" "$ws/target_dir/child_dir" "$ws/parent/actual_dir/nested"
: > "$ws/plain_file"

ln -s actual_dir "$ws/parent/rel_link"
ln -s parent/actual_dir "$ws/top_rel_link"
ln -s target_dir "$ws/chain2"
ln -s chain2 "$ws/chain1"
ln -s plain_file "$ws/file_link"
ln -s nonexistent_target "$ws/broken_link"
ln -s broken_link "$ws/broken_chain"

root_entry=$(python3 - <<'PY'
import os
entries = [e for e in os.listdir('/') if os.path.isdir(os.path.join('/', e))]
assert entries, "no root directories found"
print('usr' if 'usr' in entries else entries[0])
PY
)
root_prefix="${root_entry:0:1}"

for profile in pc server; do
    (
        cd "$ws"
        HOME="$tmp/home" PATH="$tmp/bin:$PATH" ROOT_ENTRY="$root_entry" ROOT_PREFIX="$root_prefix" \
            nu --config "$tmp/$profile/.config/nushell/config.nu" -c '
            def assert [cond: bool, msg: string] {
                if not $cond { error make { msg: $msg } }
            }
            def index_of [items: list<string>, target: string] {
                $items | enumerate | where item == $target | get index.0
            }

            let git_vals = ("git ch" | commandline complete --detailed | get value)
            assert ("checkout " in $git_vals) "git completion failed"

            # 1. Empty `cd ` puts local dirs & valid dir symlinks BEFORE zoxide (`/`, `/zoxide/first`),
            #    and excludes regular files, file symlinks, and broken symlinks.
            let empty_vals = ("cd " | commandline complete --detailed | get value)
            for expected in ["real_dir/", "top_rel_link/", "chain1/", "chain2/"] {
                assert ($expected in $empty_vals) $"missing expected local entry: ($expected) in ($empty_vals)"
            }
            for excluded in ["plain_file", "plain_file/", "file_link", "file_link/", "broken_link", "broken_link/", "broken_chain", "broken_chain/"] {
                assert ($excluded not-in $empty_vals) $"unexpected non-dir entry: ($excluded) in ($empty_vals)"
            }
            assert ((index_of $empty_vals "real_dir/") < (index_of $empty_vals "/")) $"local dir must precede zoxide /: ($empty_vals)"

            # 2. Relative symlink inside parent/ (`parent/rel_link -> actual_dir`) resolves relative to `parent/`
            let parent_vals = ("cd parent/" | commandline complete --detailed | get value)
            assert ("parent/rel_link/" in $parent_vals) $"missing parent/rel_link/ in ($parent_vals)"

            # 3. Completion beneath symlinks (`cd chain1/`, `cd chain1/ch`, `cd parent/rel_link/ne`)
            let under_chain_slash = ("cd chain1/" | commandline complete --detailed | get value)
            assert ("chain1/child_dir/" in $under_chain_slash) $"missing chain1/child_dir/ on trailing slash: ($under_chain_slash)"

            let under_chain_partial = ("cd chain1/ch" | commandline complete --detailed | get value)
            assert ("chain1/child_dir/" in $under_chain_partial) $"missing chain1/child_dir/ on partial child: ($under_chain_partial)"

            let under_rel_link = ("cd parent/rel_link/ne" | commandline complete --detailed | get value)
            assert ("parent/rel_link/nested/" in $under_rel_link) $"missing parent/rel_link/nested/: ($under_rel_link)"

            # 4. Root completion (`cd /` and `cd /<prefix>`) preserves leading `/` (e.g. `/usr/`, NOT `usr/`)
            let expected_root = $"/($env.ROOT_ENTRY)/"
            let wrong_rel_root = $"($env.ROOT_ENTRY)/"

            let root_slash_vals = ("cd /" | commandline complete --detailed | get value)
            assert ($expected_root in $root_slash_vals) $"missing ($expected_root) on `cd /`: ($root_slash_vals)"
            assert ($wrong_rel_root not-in $root_slash_vals) $"root stripped to relative ($wrong_rel_root) on `cd /`: ($root_slash_vals)"

            let root_partial_vals = ($"cd /($env.ROOT_PREFIX)" | commandline complete --detailed | get value)
            assert ($expected_root in $root_partial_vals) $"missing ($expected_root) on `cd /($env.ROOT_PREFIX)`: ($root_partial_vals)"
            assert ($wrong_rel_root not-in $root_partial_vals) $"root stripped to relative ($wrong_rel_root) on `cd /($env.ROOT_PREFIX)`: ($root_partial_vals)"
        '
    )
done