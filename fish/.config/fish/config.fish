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
            # --- 1. ベースとなるセッション名とディレクトリの決定 ---
            set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)

            # 変数のスコープを確保
            set -l session_name
            set -l target_dir
            set -l is_git false

            if test -n "$repo_root"
                set session_name (basename $repo_root)
                set target_dir $repo_root
                set is_git true
            else
                set session_name (basename $PWD)
                set target_dir $PWD
            end

            # ドットなどは置換（例: my.app -> my_app）
            set session_name (string replace -a . _ $session_name)

            # --- 2. VS Code判定とレイアウト設定 ---
            # layout_arg を空のリストとして初期化（これが重要！）
            # 中身がない場合、コマンド実行時に引数そのものが消滅します
            set -l layout_arg

            if test "$TERM_PROGRAM" = "vscode"
                # 【VS Codeの場合】
                # 1. セッション名に "-vscode" を付けて完全に別物にする
                set session_name "$session_name-vscode"
                # 2. layout_arg は空のまま（＝デフォルトのシンプル画面）
                #set -l project_layout "$HOME/.config/zellij/layouts/$session_name.kdl"

            else
                # 【Ghosttyなどその他の場合】
                set -l project_layout "$HOME/.config/zellij/layouts/$session_name.kdl"

                if test -f "$project_layout"
                    # プロジェクト専用レイアウトがあれば優先
                    set layout_arg --layout "$project_layout"
                else if $is_git
                    # Gitリポジトリならリッチな構成 (lazygit + btm)
                    set layout_arg --layout "$HOME/.config/zellij/layouts/template_git.kdl"
                else
                    # それ以外なら通常構成 (btmのみ)
                    set layout_arg --layout "$HOME/.config/zellij/layouts/template_basic.kdl"
                end
            end

            # --- 3. 起動 ---
            # $layout_arg が空のときは、オプション自体が渡されずエラーになりません
            exec zellij attach --create $session_name $layout_arg
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
