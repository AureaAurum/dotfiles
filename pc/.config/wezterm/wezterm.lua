local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = { 'nu' }
config.font = wezterm.font 'Moralerspace Neon'
config.font_size = 11
config.window_background_opacity = 0.9
config.enable_kitty_keyboard = true
config.colors = {
  foreground = '#d4be98',
  background = '#292828',
  ansi = { '#32302f', '#ea6962', '#a9b665', '#d8a657', '#7daea3', '#d3869b', '#89b482', '#d4be98' },
  brights = { '#5a524c', '#ea6962', '#a9b665', '#d8a657', '#7daea3', '#d3869b', '#89b482', '#d4be98' },
}
config.keys = {
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
  {
    key = 'n',
    mods = 'ALT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'x',
    mods = 'ALT',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
  { key = 'LeftArrow', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Down' },
}
config.mouse_bindings = {
  { event = { Down = { streak = 1, button = 'Right' } }, mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard' },
}

-- Initialize each window, including windows added to an existing GUI process.
wezterm.on('window-config-reloaded', function(window, pane)
  local key = 'btm-window-' .. window:window_id()
  if wezterm.GLOBAL[key] then return end
  wezterm.GLOBAL[key] = true
  -- Leave existing multi-pane layouts alone when this config is first loaded.
  if #pane:tab():panes() ~= 1 then return end
  pane:split { direction = 'Right', size = 0.2, args = { 'btm', '-b' } }
  pane:activate()
end)

return config
