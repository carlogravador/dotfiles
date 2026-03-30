-- plugin/lsp.lua — Language Server Protocol configuration
--
-- LSP provides IDE features: go-to-definition, find references, hover docs,
-- rename, code actions, diagnostics, etc.
vim.pack.add({
  "https://github.com/williamboman/mason-lspconfig.nvim",
  "https://github.com/neovim/nvim-lspconfig",
})

-- ── mason-lspconfig — Auto-install and configure LSP servers ──
-- Requires mason.nvim (set up in 01-mason.lua).
-- Find server names with :Mason or at:
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",          -- Lua (for editing Neovim config)
    "clangd",          -- C / C++
    "copilot",
    "docker_language_server",
    "cmake"
  },
  -- Automatically set up servers installed via Mason
  automatic_installation = true,
})

-- ── LSP Server Configurations ───────────────────────────────
-- "capabilities" tells the server what features our client supports.
-- We enhance these with nvim-cmp's completion capabilities (loaded in cmp.lua).
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
  capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
end

-- Lua LSP — Special config for Neovim Lua development
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  settings = {
    Lua = {
      -- Tell the server about Neovim's runtime files so it doesn't
      -- warn about "undefined global vim"
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

-- Clangd — C / C++
vim.lsp.config("clangd", {
  capabilities = capabilities,
})

-- ── LSP Keymaps ─────────────────────────────────────────────
-- These keymaps are set when an LSP server attaches to a buffer.
-- "LspAttach" fires when a server starts for the current file.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
  callback = function(event)
    local buf = event.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
    end

    -- Navigation
    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    map("n", "gr", vim.lsp.buf.references, "List references")
    -- map("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")

    -- Information
    map("n", "K", vim.lsp.buf.hover, "Hover documentation")
    -- map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
    -- map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")

    -- Actions
    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    -- map("n", "<leader>f", function()
    --   vim.lsp.buf.format({ async = true })
    -- end, "Format file")

    -- Diagnostics
    map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
    map("n", "<leader>se", vim.diagnostic.open_float, "Show diagnostic message")
    map("n", "<leader>dl", vim.diagnostic.setloclist, "Diagnostics to location list")
  end,
})

-- ── Diagnostic Display ───────────────────────────────────────
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",     -- Show a dot before inline diagnostic text
    spacing = 4,
  },
  signs = true,       -- Show signs in the sign column
  underline = true,   -- Underline the problematic code
  update_in_insert = false,  -- Don't update diagnostics while typing
  severity_sort = true,      -- Sort by severity (errors first)
  float = {
    border = "rounded",
    source = "always",       -- Always show which LSP server reported it
  },
})
