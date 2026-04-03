-- plugin/lsp.lua — Language Server Protocol configuration
--
-- LSP provides IDE features: go-to-definition, find references, hover docs,
-- rename, code actions, diagnostics, etc.
vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
})

-- lsp servers we want to use and their configuration
-- see `:h lspconfig-all` for available servers and their settings
vim.lsp.enable({
  "bashls",
  "cmake",
  "copilot",
  "clangd",
  "docker_language_server",
  "lua_ls",
  "pyright",
})

-- ── Diagnostic Display ───────────────────────────────────────
vim.diagnostic.config({
  virtual_text = false,  -- Disable inline diagnostic text (we'll use signs and floating windows instead)
  signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.INFO] = " ",
        [vim.diagnostic.severity.HINT] = " ",
      },
    },
})
