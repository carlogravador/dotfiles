-- plugins/mini.lua — Small, focused Neovim modules
--
-- mini.nvim is a collection of independent Lua modules that provide
-- common editor features (auto-pairs, surround, etc.) with minimal config.

return {
  "nvim-mini/mini.nvim", version = "*",
  config = function()
    require("mini.pairs").setup()
    require("mini.surround").setup()
  end,
}
