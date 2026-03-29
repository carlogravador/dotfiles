-- ftplugin/lua.lua — 2-space indentation for Lua files
require("core.indent").set(2)
vim.treesitter.start()
vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.wo[0][0].foldmethod = 'expr'
