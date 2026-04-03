-- plugin/lsp.lua — Language Server Protocol configuration
--
-- LSP provides IDE features: go-to-definition, find references, hover docs,
-- rename, code actions, diagnostics, etc.
vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
})

-- Advertise blink.cmp's extended completion capabilities (snippets, label
-- details, etc.) to every language server before they are started.
-- This must be called before vim.lsp.enable() so the capabilities are
-- included in the first initialize request sent to each server.
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
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
  float = {
    border = 'rounded'
  }
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(ev)
    vim.keymap.set('n', '<leader>sd', vim.diagnostic.open_float, {
      desc = 'Show diagnostics in floating window', buffer = ev.buf })
  end,
})
