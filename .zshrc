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

# --- Zeno.zsh ---
if [ -f "$HOME/.local/share/zeno/zeno.zsh" ] && command -v deno >/dev/null; then
    export ZENO_HOME="$HOME/.local/share/zeno"
    export ZENO_ENABLE_SOCK=1
    export ZENO_GIT_CAT="bat --color=always"
    export ZENO_GIT_TREE="eza --tree"
    source "$ZENO_HOME/zeno.zsh"
    
    # Keybindings (Optional, but recommended)
    bindkey ' '  zeno-auto-snippet
    bindkey '^ ' zeno-completion  # Ctrl+Space
    bindkey '^M' zeno-auto-snippet-and-accept-line
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
# System packages (Debian/Ubuntu/Fedora) - apt installed
# Debian/Ubuntu often places them in /usr/share/...
if [ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
