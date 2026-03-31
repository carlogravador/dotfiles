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
  lua_ls = {
    -- https://luals.github.io/wiki/settings/ | `:h nvim_get_runtime_file`
    Lua = { workspace = { library = vim.api.nvim_get_runtime_file("lua", true) }, },
  },
  clangd = {},
  pyright = {},
  bashls = {},
  dockerls = {},
  cmake = {},
  copilot = {}
}

-- configure each lsp server on the table
-- to check what clients are attached to the current buffer, use
-- `:checkhealth vim.lsp`. to view default lsp keybindings, use `:h lsp-defaults`.
for server, config in pairs(lsp_servers) do
  vim.lsp.config(server, {
    settings = config,

    -- only create the keymaps if the server attaches successfully
    on_attach = function(_, bufnr)

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to implementation" })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "List references" })
      -- vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "Go to type definition" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover documentation" })
      -- vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature help" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code action" })
      -- vim.keymap.set("n", "<leader>f", function()
      --   vim.lsp.buf.format({ async = true })  -- Format the file asynchronously (non-blocking)
      -- end, { buffer = bufnr, desc = "Format file" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr, desc = "Next diagnostic" })
      vim.keymap.set("n", "<leader>se", vim.diagnostic.open_float, { buffer = bufnr, desc = "Show diagnostic message" })
      vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, { buffer = bufnr, desc = "Diagnostics to location list" })

    end,
  })
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
