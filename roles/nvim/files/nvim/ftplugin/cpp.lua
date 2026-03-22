-- ftplugin/cpp.lua — C++ filetype settings
--
-- Use Neovim's built-in cindent instead of treesitter indent.
-- cindent is mature and handles C++ brace blocks correctly,
-- while treesitter indent has known issues with brace indentation.
vim.bo.cindent = true
