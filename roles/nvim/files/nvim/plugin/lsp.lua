-- plugin/lsp.lua — Language Server Protocol configuration
--
-- LSP provides IDE features: go-to-definition, find references, hover docs,
-- rename, code actions, diagnostics, etc.
vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
})

-- lsp servers we want to use and their configuration
-- see `:h lspconfig-all` for available servers and their settings
local lsp_servers = {
  "bashls",
  "cmake",
  "copilot",
  "clangd",
  "docker_language_server",
  "lua_ls",
  "pyright",
}

for _, server in ipairs(lsp_servers) do
  vim.lsp.enable(server)
end

-- ── Diagnostic Display ───────────────────────────────────────
vim.diagnostic.config({
  -- virtual_text = {
  --   prefix = "●",     -- Show a dot before inline diagnostic text
  --   spacing = 4,
  -- },
  -- signs = true,       -- Show signs in the sign column
  virtual_text = false,  -- Disable inline diagnostic text (we'll use signs and floating windows instead)
  signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN] = " ",
        [vim.diagnostic.severity.INFO] = " ",
        [vim.diagnostic.severity.HINT] = " ",
      },
    },
  underline = true,   -- Underline the problematic code
  update_in_insert = false,  -- Don't update diagnostics while typing
  severity_sort = true,      -- Sort by severity (errors first)
  float = {
    border = "rounded",
    source = "always",       -- Always show which LSP server reported it
  },
})
