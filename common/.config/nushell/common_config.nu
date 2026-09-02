# common config.nu

let dark_theme = {
    # color for nushell primitives
    separator: white
    leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
    header: green_bold
    empty: blue
    # Closures can be used to choose colors for specific values.
    # The value (in this case, a bool) is piped into the closure.
    # eg) {|| if $in { 'light_cyan' } else { 'light_gray' } }
    bool: light_cyan
    int: white
    filesize: cyan
    duration: white
    date: purple
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cell-path: white
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray
    search_result: {bg: red fg: white}
    shape_and: purple_bold
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_cyan
    shape_closure: green_bold
    shape_custom: green
    shape_datetime: cyan_bold
    shape_directory: cyan
    shape_external: red
    shape_externalarg: white
    shape_external_resolved: green_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: purple_bold
    # shapes are used to change the cli syntax highlighting
    shape_garbage: { fg: white bg: red attr: b}
    shape_globpattern: cyan_bold
    shape_int: purple_bold
    shape_internalcall: light_yellow_bold
    shape_keyword: cyan_bold
    shape_list: cyan_bold
    shape_literal: blue
    shape_match_pattern: green
    shape_matching_brackets: { attr: u }
    shape_nothing: light_cyan
    shape_operator: yellow
    shape_or: purple_bold
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: cyan_bold
    shape_redirection: purple_bold
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_table: blue_bold
    shape_variable: purple
    shape_vardecl: purple
}

# 1. Carapaceコンプリータの定義
let carapace_completer = {|spans: list<string>|
    CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
}

# 2. fishコンプリータの定義
let fish_completer = {|spans: list<string>|
    fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
    | from tsv --flexible --noheaders --no-infer
    | rename value description
    | update value {|row|
        let value = $row.value
        let need_quote = ['\ ', ' ', '[', ']', '(', ')', '{', '}', '\t', "'", '"', '`'] | any {$in in $value}
        if $need_quote {
            $value | str replace --all r#'\'# r#'\\'# | $'"($in)"'
        } else {
            $value
        }
    }
}

# 3. 動的フォールバック・メタコンプリータ
let external_completer = {|spans|
    # まずCarapaceで補完を試みる
    let carapace_res = (do $carapace_completer $spans)

    # Carapaceの結果が空、またはnullならfish completerにフォールバック
    if ($carapace_res | is-empty) {
        let fish_res = (do $fish_completer $spans)
        
        # fishの結果すら空なら、Nushell標準のファイル・標準補完に譲る(nullを返す)
        if ($fish_res | is-empty) { null } else { $fish_res }
    } else {
        $carapace_res
    }
}


# Custom configuration; omitted values use Nushell defaults.
$env.config = {
    show_banner: false
    abbreviations: {
        cat: 'bat'
        ps: 'procs'
        du: 'dust'
        df: 'duf'
        grep: 'rg -i'
        find: 'fd'
        ls: 'eza --icons always'
        ll: 'eza --icons -l'
        la: 'eza --icons -la'
        lt: 'eza --icons --tree --level=2'
    }
    table: { index_mode: auto }

    datetime_format: {
        normal: '%a, %d %b %Y %H:%M:%S %z'
        table: '%m/%d/%y %I:%M:%S%p'
    }

    completions: {
        external: {
            max_results: 50
            completer: $external_completer
        }
    }

    color_config: $dark_theme
    use_ansi_coloring: true
    render_right_prompt_on_last_line: true
    use_kitty_protocol: true
    highlight_resolved_externals: true

    cursor_shape: {
        vi_insert: line
        vi_normal: block
        emacs: line
    }
}

$env.config.keybindings ++=  [
        {
        name: completion_menu_ctrl_t
        modifier: control
        keycode: char_t
        mode: [vi_insert vi_normal emacs]
        event: {
            until: [
                { send: menu name: completion_menu }
                { send: menupagenext }
            ]
        }
    }
    {
        name: history_menu_ctrl_y
        modifier: control
        keycode: char_y
        mode: [vi_insert vi_normal emacs]
        event: {
            until: [
                { send: menu name: history_menu }
                { send: menupagenext }
            ]
        }
    }
  ]

# Source generated configs from env.nu
source ~/.cache/nushell/mise.nu
source ~/.cache/nushell/zoxide.nu
source ~/.cache/nushell/carapace.nu
source ~/.cache/nushell/starship.nu
source ~/.cache/nushell/navi.nu


# Yazi wrapper
def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")
    try {
        ^yazi ...$args --cwd-file $tmp
        if ($tmp | path exists) {
            let cwd = (open $tmp | str trim)
            if $cwd != "" and $cwd != $env.PWD {
                cd $cwd
            }
        }
    } catch {
        rm -f $tmp
    }
}
