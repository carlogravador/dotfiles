-- init.lua — Neovim entry point
--
-- This file is loaded automatically when Neovim starts.
-- It loads core settings first, then bootstraps the plugin manager.
--
-- Load order matters:
--   1. core.options  — Set vim options before anything else
--   2. core.keymaps  — Leader key must be set before plugins bind to it
--   3. core.autocmds — Autocommands for editor behavior
--   4. plugins       — Bootstrap lazy.nvim and load all plugin specs

require("core.options")
require("core.theme")
require("core.keymaps")
require("core.autocmds")
require("plugins")
