# --- Homebrew (Linux/macOS) ---
# Ensure Homebrew is in PATH before checking for tools
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

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
if command -v bat >/dev/null; then
    # bat is usually 'bat' on brew, 'batcat' on apt (but we are using brew now)
    # No alias needed if native command is used, but ensuring config is clean
    export BAT_THEME="ansi" 
fi

# Others
# rg (ripgrep), fd (fd-find) are used directly.

# Git Delta configuration
if command -v delta >/dev/null; then
    export GIT_PAGER="delta"
fi
