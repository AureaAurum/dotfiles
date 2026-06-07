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


let abbreviations = {
# Aliases - Replacing standard tools with modern alternatives if available
# Note: In Nushell, aliases are defined at parse time. 
# We use custom commands (def) to allow for conditional logic or just define them.
 cat: 'bat'
 ps: 'procs'
 du: 'dust'
 df: 'duf'
 grep: 'rg -i'
 find: 'fd'

# Standard ls overrides
 ls: 'eza --icons'
 ll: 'eza -l --icons'
 la: 'eza -la --icons'
 lt: 'eza --tree --level=2 --icons'

}


# The default config record. This is where much of your global configuration is setup.
$env.config = {
    show_banner: false # true or false to enable or disable the welcome banner at startup
    table: {
        mode: rounded # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
        index_mode: auto # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
        show_empty: true # show 'empty list' and 'empty record' placeholders for command output
        padding: { left: 1, right: 1 } # a left right padding of each column in a table
        trim: {
            methodology: wrapping # wrapping or truncating
            wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
            truncating_suffix: "..." # A suffix used by the 'truncating' methodology
        }
        header_on_separator: false # show header text on separator/border line
        # abbreviated_row_count: 10 # limit data rows from top and bottom after reaching a set point
    }

    error_style: "fancy" # "fancy" or "plain" for screen reader-friendly error messages

    # datetime_format determines what a datetime rendered in the shell would look like.
    # Behavior without this configuration point will be to "humanize" the datetime display,
    # showing something like "a day ago."
    datetime_format: {
         normal: '%a, %d %b %Y %H:%M:%S %z'    # shows up in displays of variables or other datetime's outside of tables
         table: '%m/%d/%y %I:%M:%S%p'          # generally shows up in tabular outputs such as ls. commenting this out will change it to the default human readable datetime format
    }

    completions: {
        case_sensitive: false # set to true to enable case-sensitive completions
        quick: true    # set this to false to prevent auto-selecting completions when only one remains
        partial: true    # set this to false to prevent partial filling of the prompt
        algorithm: "prefix"    # prefix or fuzzy
        external: {
            enable: true
            max_results: 50 # the maximum number of results to return from an external completer, this is to prevent performance issues with completions that return a large number of results
            completer: $external_completer
        }
    }

    # filesize: {
    #    metric: false # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
    #    format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, auto
    #}

    color_config: $dark_theme # if you want a more interesting theme, you can replace the empty record with `$dark_theme`, `$light_theme` or another custom record
    # use_grid_icons: true
    # footer_mode: "25" # always, never, number_of_rows, auto
    float_precision: 2 # the precision for displaying floats in tables
    buffer_editor: "" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
    use_ansi_coloring: true
    bracketed_paste: true # enable bracketed paste, currently useless on windows
    edit_mode: emacs # emacs, vi
    render_right_prompt_on_last_line: true # true or false to enable or disable right prompt to be rendered on last line of the prompt.
    use_kitty_protocol: true # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this.
    highlight_resolved_externals: true # true enables highlighting of external commands in the repl resolved by which.

  keybindings: [
    {
      name: abbr_menu
      modifier: none
      keycode: enter
      mode: [emacs, vi_normal, vi_insert]
      event: [
          { send: menu name: abbr_menu }
          { send: enter }
      ]
    }
    {
      name: accept_abbr
      modifier: control
      keycode: char_y
      mode: [emacs, vi_normal, vi_insert]
      event: [
        { send: HistoryHintComplete }]
    }
    {
      name: abbr_menu
      modifier: none
      keycode: space
      mode: [emacs, vi_normal, vi_insert]
      event: [
          { send: menu name: abbr_menu }
          { edit: insertchar value: ' '}
      ]
    }
    # End fish
  ]
  cursor_shape: {
    vi_insert: line
    vi_normal: block
    emacs: line
  }
  menus: [
    # Menu for fish like abbreviations
    {
      name: abbr_menu
      only_buffer_difference: false
      marker: none
      type: {
        layout: columnar
        columns: 1
        col_width: 20
        col_padding: 2
      }
      style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
      }
      source: { |buffer, position|
        # Extract the current word before the cursor
        let before_cursor = ($buffer | str substring 0..$position)
        let current_word = ($before_cursor | split row ' ' | last)
  
        # Only expand abbreviations when the current word is at the start of the line.
        # This avoids expanding later words like `ps` in `docker ps`.
        let word_len = ($current_word | str length | into int)
        let before_word_start = ($position - $word_len)
        let before_word = if $before_word_start > 0 {
          ($buffer | str substring 0..<$before_word_start)
        } else {
          ''
        }
        let is_line_start = ($before_word | str trim) == ''

        let match = if $is_line_start { $abbreviations | columns | where $it == $current_word } else { [] }
        if ($match | is-empty) {
          { value: $buffer }
        } else {
          # Replace only the current word, preserve rest of buffer
          let replacement = ($abbreviations | get $match.0)
          let before_word_end = ($position - $word_len)
          let before_word = if $before_word_end > 0 {
            ($buffer | str substring 0..<$before_word_end)
          } else {
            ''
          }
          let after_cursor = ($buffer | str substring $position..)
          { value: ($before_word ++ $replacement ++ $after_cursor) }
        }
      }
    }
  ]




}

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
