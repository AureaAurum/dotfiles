if status is-interactive
    # Commands to run in interactive sessions can go here

    # Disable default greeting
    set -U fish_greeting

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

    # Initialize Starship
    if type -q starship
        starship init fish | source
    end

    # Initialize Zoxide (smarter cd)
    if type -q zoxide
        zoxide init fish --cmd cd | source
    end

    if status is-interactive
        if not set -q ZELLIJ
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

            # --- 2. VS Codeと通常端末の完全分離 ---
            set -l layout_arg

            if test "$TERM_PROGRAM" = "vscode"
                # VS Codeの場合: 末尾に -vscode を強制付与し、レイアウトは指定しない
                set session_name "$session_name-vscode"
            else
                # VS Code以外の場合: 通常の名前を使用し、レイアウトを決定
                set -l project_layout "$HOME/.config/zellij/layouts/$session_name.kdl"

                if test -f "$project_layout"
                    set layout_arg --layout "$project_layout"
                else if $is_git
                    set layout_arg --layout "$HOME/.config/zellij/layouts/template_git.kdl"
                else
                    set layout_arg --layout "$HOME/.config/zellij/layouts/template_default.kdl"
                end
            end

            # --- 3. 起動ロジック (ここが重要) ---
            # 実行中のセッション一覧を取得 (-nで名前のみ、-sでショート形式)
            set -l active_sessions (zellij list-sessions -n -s 2>/dev/null)

            # セッション名が完全一致で存在するか確認
            if contains $session_name $active_sessions
                # 存在する -> アタッチする
                exec zellij attach $session_name
            else
                # 存在しない -> レイアウトを指定して新規作成する
                # ($layout_arg が空ならデフォルトレイアウトになります)
                exec zellij -n $session_name $layout_arg
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

    # Common Git Shortcuts
    function g --wraps git
        git $argv
    end
    function gs --wraps "git status"
        git status $argv
    end
    function ga --wraps "git add"
        git add $argv
    end
    function gc --wraps "git commit"
        git commit $argv
    end
    function gl --wraps "git pull"
        git pull $argv
    end
    function gp --wraps "git push"
        git push $argv
    end

    # Fzf configuration
    if functions -q fzf_configure_bindings
        # set up fzf key bindings
        fzf_configure_bindings --directory=\ct 2>/dev/null
    end
end
