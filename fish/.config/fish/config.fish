set -gx EDITOR "micro"
set -gx FD_DIRS_IGNORE ".cache" "node_modules" "target" "vendor" ".git"
# --- Homebrew Setup (条件分岐でエラー回避) ---
# Linuxbrewのディレクトリが存在する場合のみ読み込む
if test -d /home/linuxbrew/.linuxbrew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end
# brewコマンドが使える状態になっている場合のみ、補完設定を読み込む
if type -q brew
    if test -d (brew --prefix)"/share/fish/vendor_completions.d"
        set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
    end
end
# --- Tool Initialization ---
# Initialize Mise (これを忘れると言語が動きません！)
if type -q mise
    if status is-interactive
        mise activate fish | source
    else
        mise activate fish --shims | source
    end
end

if status is-interactive
    # Commands to run in interactive sessions can go here

    # Disable default greeting
    set -U fish_greeting

    # Initialize Starship
    if type -q starship
        starship init fish | source
    end

    # Initialize Zoxide (smarter cd)
    if type -q zoxide
        zoxide init fish --cmd cd | source
    end
    #echo "DEBUG: TERM_PROGRAM=$TERM_PROGRAM, ZELLIJ=$ZELLIJ, interactive=(status is-interactive)"
    if status is-interactive
        if not set -q ZELLIJ
            if type -q zellij
                # --- 1. セッション名とディレクトリの決定 ---
                set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
                set -l session_name
                set -l is_git false

                if test -n "$repo_root"
                    set session_name (basename $repo_root)
                    set is_git true
                else
                    set session_name (basename $PWD)
                end

                # ドットやスペースをアンダースコアに置換
                set session_name (string replace -a . _ $session_name)
                set session_name (string replace -a " " _ $session_name)

                # --- 2. VS Code判定とレイアウト設定 ---
                # layout_arg をリストとして初期化
                set -l layout_arg

                if test "$TERM_PROGRAM" = "vscode"
                    # VS Codeの場合: 名前を変えて、レイアウト指定なし
                    set session_name "$session_name-vscode"
                else
                    # Ghosttyなどの場合: レイアウトを設定
                    set -l project_layout "$HOME/.config/zellij/layouts/$session_name.kdl"

                    if test -f "$project_layout"
                        # プロジェクト専用レイアウト
                        set layout_arg --layout "$project_layout"
                    else if $is_git
                        # Git用レイアウト
                        set layout_arg --layout "$HOME/.config/zellij/layouts/template_git.kdl"
                    else
                        # 通常レイアウト
                        set layout_arg --layout "$HOME/.config/zellij/layouts/template_default.kdl"
                    end
                end

                # --- 3. 起動 ---
                if zellij list-sessions | string match -q "$session_name (EXITED)"
                    zellij delete-session $session_name
                end
                # ユーザー提示の構文: layout(オプション) を先に書き、その後に attach を呼ぶ
                # layout_arg が空の場合は単に無視されます
                exec zellij $layout_arg attach --create $session_name -f
            end
        end
    end

    # Initialize Navi (cheatsheets)
    if type -q navi
        navi widget fish | source
    end

    # --- Aliases & Abbreviations ---

    # 'ls' family (using eza)
    if type -q eza
        function ls --wraps eza
            eza --icons --git $argv
        end
        abbr -a ll "ls -l"
        abbr -a la "ls -la"
        abbr -a lt "ls --tree --level=2"
    end

    # cat -> bat
    if type -q bat
        function cat --wraps bat
            bat $argv
        end
    end

    # procs (ps replacement)
    if type -q procs
        function ps --wraps procs
            procs $argv
        end
    end

    # dust (du replacement)
    if type -q dust
        function du --wraps dust
            dust $argv
        end
    end

    # duf (df replacement)
    if type -q duf
        function df --wraps duf
            duf $argv
        end
    end

    # ripgrep (grep replacement)
    if type -q rg
        function grep --wraps rg
            rg -i $argv
        end
    end

    # fd (find replacement)
    if type -q fd
        function find --wraps fd
            fd $argv
        end
    end

    # Fzf configuration
    if functions -q fzf_configure_bindings
        # set up fzf key bindings
        fzf_configure_bindings --directory=\ct 2>/dev/null
    end

    function y
	    set tmp (mktemp -t "yazi-cwd.XXXXXX")
	    yazi $argv --cwd-file="$tmp"
	    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
	    	builtin cd -- "$cwd"
	    end
	    rm -f -- "$tmp"
    end

end
