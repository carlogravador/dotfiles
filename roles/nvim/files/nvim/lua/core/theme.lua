-- core/theme.lua — Theme selection and colors

-- Enable true color support for accurate colors in modern terminals
vim.opt.termguicolors = true
-- Allow user to override background ("dark" or "light"); default to dark
vim.opt.background = "dark"
vim.cmd.colorscheme("retrobox")

