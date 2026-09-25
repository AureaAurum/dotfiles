local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

config.default_prog = { 'nu' }

config.font = wezterm.font 'Moralerspace Neon'
config.font_size = 11
config.window_background_opacity = 0.9
config.enable_kitty_keyboard = true

config.colors = {
  foreground = '#d4be98',
  background = '#292828',

  ansi = {
    '#32302f',
    '#ea6962',
    '#a9b665',
    '#d8a657',
    '#7daea3',
    '#d3869b',
    '#89b482',
    '#d4be98',
  },

  brights = {
    '#5a524c',
    '#ea6962',
    '#a9b665',
    '#d8a657',
    '#7daea3',
    '#d3869b',
    '#89b482',
    '#d4be98',
  },

  tab_bar = {
    background = '#292828',
    active_tab = {
      bg_color = '#3c3836',
      fg_color = '#d4be98',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#292828',
      fg_color = '#928374',
    },
    inactive_tab_hover = {
      bg_color = '#32302f',
      fg_color = '#d4be98',
    },
    new_tab = {
      bg_color = '#292828',
      fg_color = '#928374',
    },
  },
}

-- Put the tab/status bar at the bottom, Zellij-style.
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false

-- ============================================================
-- Key bindings
-- ============================================================

config.keys = {
  -- Clipboard
  {
    key = 'v',
    mods = 'CTRL',
    action = act.PasteFrom 'Clipboard',
  },

  -- ----------------------------------------------------------
  -- Direct pane operations
  --
  -- These remain usable without entering Pane mode.
  -- ----------------------------------------------------------

  {
    key = 'n',
    mods = 'ALT',
    action = act.SplitHorizontal {
      domain = 'CurrentPaneDomain',
    },
  },

  {
    key = 'x',
    mods = 'ALT',
    action = act.CloseCurrentPane {
      confirm = false,
    },
  },

  {
    key = 'LeftArrow',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Left',
  },

  {
    key = 'RightArrow',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Right',
  },

  {
    key = 'UpArrow',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Up',
  },

  {
    key = 'DownArrow',
    mods = 'ALT',
    action = act.ActivatePaneDirection 'Down',
  },

  -- ----------------------------------------------------------
  -- Zellij-like modes
  -- ----------------------------------------------------------

  -- Pane mode
  {
    key = 'p',
    mods = 'CTRL',
    action = act.ActivateKeyTable {
      name = 'pane_mode',
      one_shot = false,
    },
  },

  -- Tab mode
  {
    key = 't',
    mods = 'CTRL',
    action = act.ActivateKeyTable {
      name = 'tab_mode',
      one_shot = false,
    },
  },

  -- ----------------------------------------------------------
  -- WezTerm built-in modes / UI
  -- ----------------------------------------------------------

  -- Copy/select mode
  {
    key = 'x',
    mods = 'CTRL|SHIFT',
    action = act.ActivateCopyMode,
  },

  -- Search
  {
    key = 'f',
    mods = 'CTRL|SHIFT',
    action = act.Search 'CurrentSelectionOrEmptyString',
  },

  -- Command palette
  {
    key = 'p',
    mods = 'CTRL|SHIFT',
    action = act.ActivateCommandPalette,
  },

  -- Passthrough mode (Bypass all WezTerm keys except toggle key)
  {
    key = 'z',
    mods = 'CTRL|SHIFT',
    action = act.ActivateKeyTable {
      name = 'passthrough_mode',
      one_shot = false,
      replace_current = true,
    },
  },
}

-- ============================================================
-- Key tables
-- ============================================================

config.key_tables = {
  -- ----------------------------------------------------------
  -- Pane mode
  -- Ctrl+p
  -- ----------------------------------------------------------
  pane_mode = {
    {
      key = 'n',
      action = act.SplitHorizontal {
        domain = 'CurrentPaneDomain',
      },
    },

    {
      key = 'd',
      action = act.SplitVertical {
        domain = 'CurrentPaneDomain',
      },
    },

    {
      key = 'x',
      action = act.CloseCurrentPane {
        confirm = false,
      },
    },

    {
      key = 'LeftArrow',
      action = act.ActivatePaneDirection 'Left',
    },

    {
      key = 'RightArrow',
      action = act.ActivatePaneDirection 'Right',
    },

    {
      key = 'UpArrow',
      action = act.ActivatePaneDirection 'Up',
    },

    {
      key = 'DownArrow',
      action = act.ActivatePaneDirection 'Down',
    },

    {
      key = 'h',
      action = act.ActivatePaneDirection 'Left',
    },

    {
      key = 'l',
      action = act.ActivatePaneDirection 'Right',
    },

    {
      key = 'k',
      action = act.ActivatePaneDirection 'Up',
    },

    {
      key = 'j',
      action = act.ActivatePaneDirection 'Down',
    },

    {
      key = 'f',
      action = act.TogglePaneZoomState,
    },

    {
      key = 'Escape',
      action = act.PopKeyTable,
    },

    {
      key = 'Enter',
      action = act.PopKeyTable,
    },
  },

  -- ----------------------------------------------------------
  -- Tab mode
  -- Ctrl+t
  -- ----------------------------------------------------------
  tab_mode = {
    {
      key = 'n',
      action = act.SpawnTab 'CurrentPaneDomain',
    },

    {
      key = 'x',
      action = act.CloseCurrentTab {
        confirm = false,
      },
    },

    {
      key = 'LeftArrow',
      action = act.ActivateTabRelative(-1),
    },

    {
      key = 'RightArrow',
      action = act.ActivateTabRelative(1),
    },

    {
      key = 'h',
      action = act.ActivateTabRelative(-1),
    },

    {
      key = 'l',
      action = act.ActivateTabRelative(1),
    },

    {
      key = '1',
      action = act.ActivateTab(0),
    },

    {
      key = '2',
      action = act.ActivateTab(1),
    },

    {
      key = '3',
      action = act.ActivateTab(2),
    },

    {
      key = '4',
      action = act.ActivateTab(3),
    },

    {
      key = '5',
      action = act.ActivateTab(4),
    },

    {
      key = '6',
      action = act.ActivateTab(5),
    },

    {
      key = '7',
      action = act.ActivateTab(6),
    },

    {
      key = '8',
      action = act.ActivateTab(7),
    },

    {
      key = '9',
      action = act.ActivateTab(8),
    },

    {
      key = 'Escape',
      action = act.PopKeyTable,
    },

    {
      key = 'Enter',
      action = act.PopKeyTable,
    },
  },

  -- ----------------------------------------------------------
  -- Passthrough mode
  -- Ctrl+Shift+z (or auto on ssh / micro)
  -- ----------------------------------------------------------
  passthrough_mode = (function()
    local t = {
      {
        key = 'z',
        mods = 'CTRL|SHIFT',
        action = act.ClearKeyTableStack,
      },
    }
    for _, b in ipairs(config.keys) do
      if not (b.key == 'z' and b.mods == 'CTRL|SHIFT') then
        table.insert(t, {
          key = b.key,
          mods = b.mods,
          action = act.SendKey {
            key = b.key,
            mods = b.mods,
          },
        })
      end
    end
    return t
  end)(),
}

-- ============================================================
-- Mouse
-- ============================================================

config.mouse_bindings = {
  {
    event = {
      Down = {
        streak = 1,
        button = 'Right',
      },
    },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },
}

-- ============================================================
-- Bottom status / mode hints (Zellij style)
-- ============================================================

local hint_theme = {
  bg = '#292828',        -- ステータスバー背景
  key_bg = '#3c3836',    -- キーキャップ背景 (Gruvbox bg2)
  key_fg = '#ebdbb2',    -- キーキャップ文字色 (Gruvbox fg0 / Bold)
  desc_fg = '#d4be98',   -- アクション説明文字色 (Gruvbox fg)
  sep_fg = '#5a524c',    -- 区切り文字色 (Gruvbox bg4 / gray)
  badge_fg = '#292828',  -- モードバッジ文字色 (暗い背景色で高コントラスト)
}

local mode_configs = {
  normal = {
    badge = ' NORMAL ',
    badge_bg = '#a9b665', -- Green
    keys = {
      { key = 'Ctrl+p', desc = 'Pane' },
      { key = 'Ctrl+t', desc = 'Tab' },
      { key = 'Ctrl+Shift+x', desc = 'Select' },
      { key = 'Ctrl+Shift+f', desc = 'Search' },
      { key = 'Ctrl+Shift+p', desc = 'Palette' },
      { key = 'Ctrl+Shift+z', desc = 'Pass' },
    },
  },

  pane_mode = {
    badge = ' PANE ',
    badge_bg = '#d8a657', -- Yellow
    keys = {
      { key = 'n', desc = 'Split→' },
      { key = 'd', desc = 'Split↓' },
      { key = 'x', desc = 'Close' },
      { key = 'hjkl/←↑↓→', desc = 'Move' },
      { key = 'f', desc = 'Zoom' },
      { key = 'Esc', desc = 'Normal' },
    },
  },

  tab_mode = {
    badge = ' TAB ',
    badge_bg = '#89b482', -- Aqua
    keys = {
      { key = 'n', desc = 'New' },
      { key = 'x', desc = 'Close' },
      { key = 'h/←', desc = 'Prev' },
      { key = 'l/→', desc = 'Next' },
      { key = '1-9', desc = 'Select' },
      { key = 'Esc', desc = 'Normal' },
    },
  },

  copy_mode = {
    badge = ' SELECT ',
    badge_bg = '#d3869b', -- Purple
    keys = {
      { key = 'hjkl', desc = 'Move' },
      { key = 'v', desc = 'Select' },
      { key = 'y', desc = 'Copy' },
      { key = '/', desc = 'Search' },
      { key = 'Esc', desc = 'Normal' },
    },
  },

  search_mode = {
    badge = ' SEARCH ',
    badge_bg = '#7daea3', -- Blue
    keys = {
      { key = 'Enter', desc = 'Next' },
      { key = 'Shift+Enter', desc = 'Prev' },
      { key = 'Esc', desc = 'Normal' },
    },
  },

  passthrough_mode = {
    badge = ' PASSTHROUGH ',
    badge_bg = '#ea6962', -- Red
    keys = {
      { key = 'Ctrl+Shift+z', desc = 'Normal' },
    },
  },
}

local function build_status_hint(conf)
  local elements = {}

  -- 1. Mode Badge
  table.insert(elements, { Background = { Color = conf.badge_bg } })
  table.insert(elements, { Foreground = { Color = hint_theme.badge_fg } })
  table.insert(elements, { Attribute = { Intensity = 'Bold' } })
  table.insert(elements, { Text = conf.badge })

  -- 2. Keys and descriptions
  for _, item in ipairs(conf.keys) do
    -- Separator
    table.insert(elements, { Background = { Color = hint_theme.bg } })
    table.insert(elements, { Foreground = { Color = hint_theme.sep_fg } })
    table.insert(elements, { Attribute = { Intensity = 'Normal' } })
    table.insert(elements, { Text = ' │ ' })

    -- Keycap badge
    table.insert(elements, { Background = { Color = hint_theme.key_bg } })
    table.insert(elements, { Foreground = { Color = hint_theme.key_fg } })
    table.insert(elements, { Attribute = { Intensity = 'Bold' } })
    table.insert(elements, { Text = ' ' .. item.key .. ' ' })

    -- Action description
    table.insert(elements, { Background = { Color = hint_theme.bg } })
    table.insert(elements, { Foreground = { Color = hint_theme.desc_fg } })
    table.insert(elements, { Attribute = { Intensity = 'Normal' } })
    table.insert(elements, { Text = ' ' .. item.desc })
  end

  -- Trailing padding
  table.insert(elements, { Background = { Color = hint_theme.bg } })
  table.insert(elements, { Foreground = { Color = hint_theme.bg } })
  table.insert(elements, { Text = ' ' })

  return wezterm.format(elements)
end

local cached_hints = {}
for name, conf in pairs(mode_configs) do
  cached_hints[name] = build_status_hint(conf)
end

local pane_proc_was_target = {}

local function is_passthrough_process(pane)
  local success, name = pcall(function()
    return pane:get_foreground_process_name()
  end)
  if not success or not name then
    return false
  end
  local basename = name:gsub('^.*/', ''):gsub('%.exe$', '')
  return basename == 'ssh' or basename == 'micro'
end

wezterm.on('update-status', function(window, pane)
  local pane_id = pane:pane_id()
  local is_target = is_passthrough_process(pane)
  local was_target = pane_proc_was_target[pane_id] or false
  pane_proc_was_target[pane_id] = is_target

  -- 1. プロセスが通常から ssh / micro に切り替わった瞬間
  if is_target and not was_target then
    -- 他の操作モード（tab_mode, pane_mode 等）中でなければパススルーにする
    if window:active_key_table() == nil or window:active_key_table() == 'passthrough_mode' then
      window:perform_action(
        act.ActivateKeyTable {
          name = 'passthrough_mode',
          one_shot = false,
          replace_current = true,
        },
        pane
      )
    end

  -- 2. プロセスが ssh / micro から通常（シェル）に戻った瞬間
  elseif not is_target and was_target then
    -- パススルーモードであれば確実に全スタックをクリアして通常モードへ復帰
    if window:active_key_table() == 'passthrough_mode' then
      window:perform_action(act.ClearKeyTableStack, pane)
    end
  end

  local mode = window:active_key_table()
  window:set_right_status(cached_hints[mode] or cached_hints.normal)
end)

-- ============================================================
-- btm pane
-- ============================================================
--
-- Initialize btm once per window.
--
-- window-config-reloaded is intentionally used rather than gui-startup:
-- this also covers windows created in an already-running WezTerm GUI.
--

wezterm.on('window-config-reloaded', function(window, pane)
  local key = 'btm-window-' .. window:window_id()

  if wezterm.GLOBAL[key] then
    return
  end

  wezterm.GLOBAL[key] = true

  -- Leave an existing multi-pane layout alone when the config is first
  -- loaded into this window.
  if #pane:tab():panes() ~= 1 then
    return
  end

  pane:split {
    direction = 'Right',
    size = 0.2,
    args = { 'btm', '-b' },
  }

  pane:activate()
end)

return config
