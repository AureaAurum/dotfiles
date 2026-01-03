if status is-interactive
    # Commands to run in interactive sessions can go here

    # Disable default greeting
    set -U fish_greeting

    # Homebrew Setup
    if test -d /home/linuxbrew/.linuxbrew
        eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    end

    # Initialize Starship
    if type -q starship
        starship init fish | source
    end

    # Initialize Zoxide (smarter cd)
    if type -q zoxide
        zoxide init fish | source
    end

    # Initialize Navi (cheatsheets)
    if type -q navi
        navi widget fish | source
    end

    # --- Aliases & Abbreviations ---

    # 'ls' family (using eza)
    if type -q eza
        alias ls="eza --icons"
        abbr -a ll "ls -l"
        abbr -a la "ls -a"
        abbr -a lt "ls --tree --level=2"
    end

    # cat -> bat
    if type -q bat
        alias cat="bat"
    end

    # procs (ps replacement)
    if type -q procs
        alias ps="procs"
    end

    # dust (du replacement)
    if type -q dust
        alias du="dust"
    end

    # duf (df replacement)
    if type -q duf
        alias df="duf"
    end

    # ripgrep (grep replacement)
    if type -q rg
        alias grep="rg"
    end

    # fd (find replacement)
    if type -q fd
        alias find="fd"
    end

    # Common Git Shortcuts
    alias g="git"
    alias gs="git status"
    alias ga="git add"
    alias gc="git commit"
    alias gl="git pull"
    alias gp="git push"

    # Fzf configuration
    if functions -q fzf_configure_bindings
        # set up fzf key bindings
        fzf_configure_bindings --directory=\ct --git_status=\cs --processes=\cp --variables=\cv 2>/dev/null
    end
end
