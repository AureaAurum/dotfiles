# --- Homebrew (Linux/macOS) ---
# Ensure Homebrew is in PATH before checking for tools
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
elif [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    HOMEBREW_PREFIX="/opt/homebrew"
elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
    HOMEBREW_PREFIX="/usr/local"
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
    export BAT_THEME="ansi" 
fi

# Git Delta configuration
if command -v delta >/dev/null; then
    export GIT_PAGER="delta"
fi

# --- Plugins (zsh-syntax-highlighting, zsh-autosuggestions) ---
# Must be at the end

# 1. Try Homebrew (Linuxbrew/macOS)
if [ -n "$HOMEBREW_PREFIX" ]; then
    if [ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
        source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    fi
    if [ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
        source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
# 2. Try System packages (Debian/Ubuntu/Fedora)
else
    # Debian/Ubuntu often places them in /usr/share/...
    if [ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
        source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    fi
    if [ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
        source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
fi
