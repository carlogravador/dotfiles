-- load config for packer plugin manager
require('packer_config')

-- load theme first
require('dracula_config')

-- load config for nvim
require('nvim_config')

-- load config for lualine plugin
require('lualine_config')

-- load custom key bindings
require('mappings_config')

-- Treesitter for syntax highlighting
require('treesitter_config')

-- LSP config
require('lsp_config')

-- FZF config
require('fzf_lua_config')

-- nvim-tree config
require('nvim_tree_config')

-- comment.nvim config
require('comment_nvim_config')