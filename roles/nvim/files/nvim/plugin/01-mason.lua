-- plugin/01-mason.lua — Tool installer (loaded before lsp.lua and dap.lua)
--
-- mason.nvim is a portable installer for LSP servers, DAP adapters, linters,
-- and formatters. It runs before plugin files that depend on it (lsp.lua,
-- dap.lua) thanks to the 01- prefix.
--
-- Run :MasonUpdate to refresh the registry after upgrading mason.nvim.
-- Run :Mason to open the installer UI.

vim.pack.add({ "https://github.com/williamboman/mason.nvim" })

require("mason").setup({
  ui = {
    border = "rounded",
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})
