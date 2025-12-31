# --- Environment ---
export PATH=$HOME/.local/bin:$PATH

# --- Init Tools ---
# Silence errors if tools are missing during bootstrap
if command -v starship >/dev/null; then
    eval "$(starship init zsh)"
fi
if command -v zoxide >/dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
fi

# --- Aliases ---
# Note: Standard commands (ls, cat, find, grep) are preserved for AI compatibility.
# Use these modern alternatives for interactive use:

# eza (ls replacement)
if command -v eza >/dev/null; then
    alias ll='eza -lh --icons --git'
    alias la='eza -lha --icons --git'
    alias l='eza --icons --git'
    alias lt='eza --tree --level=2 --icons'
fi

# bat (cat replacement)
# 'bat' command is expected to be available (linked from batcat by ansible if needed)

# Others
# rg (ripgrep), fd (fd-find) are used directly.

# Git Delta configuration (if not in .gitconfig)
if command -v delta >/dev/null; then
    # These are usually best in .gitconfig, but for reference:
    export GIT_PAGER="delta"
fi
