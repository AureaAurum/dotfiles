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
        # Zellijの外、かつVSCodeのターミナルでない場合（VSCode内でも使いたい場合はこの行の条件を外してください）
        if not set -q ZELLIJ
            
            # 1. Gitリポジトリ内ならそのルートディレクトリのパスを取得
            set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
            
            if test -n "$repo_root"
                # Git管理下なら「リポジトリ名」をセッション名にする
                set session_name (basename $repo_root)
            else
                # Git管理外なら「現在のフォルダ名」をセッション名にする
                set session_name (basename $PWD)
            end
    
            # 2. セッション名に使えない文字（.など）があれば置換しておく（念のため）
            set session_name (string replace -a . _ $session_name)
    
            # 3. その名前でアタッチ（なければ作成）
            # VSCode内で使う場合、execをつけると統合ターミナルを閉じた時の挙動が怪しくなることがあるので
            # 挙動が変なら exec を外して試してください
            exec zellij attach --create $session_name
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
