-- plugin/00-theme.lua — Colorscheme (loaded first via numeric prefix)
--
-- The 00- prefix ensures this file is sourced before all other plugin/
-- files, so the colorscheme is available immediately on startup.

vim.pack.add({
  "https://github.com/folke/tokyonight.nvim.git"
})

vim.opt.background = "dark"
vim.cmd.colorscheme("tokyonight")
