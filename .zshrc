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

# --- Aliases (Interactive Only) ---
# Guard aliases to ensure scripts/AI get plain output
if [[ -o interactive ]]; then

    # eza (ls replacement)
    if command -v eza >/dev/null; then
        alias ls='eza -h --icons --git'
        alias ll='eza -lh --icons --git'
        alias la='eza -lha --icons --git'
        alias l='eza --icons --git'
        alias lt='eza --tree --level=2 --icons'
    fi

    # bat (cat replacement)
    if command -v bat >/dev/null; then
        export BAT_THEME="ansi"
        alias cat='bat'
    fi

    # procs (ps replacement)
    if command -v procs >/dev/null; then
        alias ps='procs'
    fi

    # dust (du replacement)
    if command -v dust >/dev/null; then
        alias du='dust'
    fi

    # duf (df replacement)
    if command -v duf >/dev/null; then
        alias df='duf'
    fi

    # ripgrep (grep replacement)
    if command -v rg >/dev/null; then
        alias grep='rg'
    fi

    # fd (find replacement)
    if command -v fd >/dev/null; then
        alias find='fd'
    fi

fi

# Git Delta configuration
if command -v delta >/dev/null; then
    export GIT_PAGER="delta"
fi

# --- Plugins (zsh-syntax-highlighting, zsh-autosuggestions) ---
# System packages (Debian/Ubuntu/Fedora) - apt installed
# Debian/Ubuntu often places them in /usr/share/...
if [ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
