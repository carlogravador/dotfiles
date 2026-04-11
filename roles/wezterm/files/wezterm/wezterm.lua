local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Tokyo Night Moon"
config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font("FiraMono Nerd Font")

return config
