-- plugin/cmp.lua — Autocompletion via blink.cmp
--
-- blink.cmp is a fast, async completion engine written in Rust.
-- It provides built-in LSP, path, buffer, and snippet sources,
-- and supports function signature help while typing arguments.

vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = "1.*" },
  -- Curated snippet library for many languages (VSCode format)
  "https://github.com/rafamadriz/friendly-snippets",
})

require("blink.cmp").setup({
  -- ── Keymaps ──────────────────────────────────────────────────
  -- Extend the "default" preset (<C-n/p> navigate, <C-y> accept, <C-e> hide)
  -- rather than replacing it — keeps muscle memory for standard Vim completion.
  -- <Tab> is intentionally left unbound here to avoid conflicting with
  -- Copilot's <Tab> accept binding in plugin/ai.lua.
  keymap = {
    preset = "default",
    -- ["<CR>"] = { "accept", "fallback" },
    -- -- Scroll the documentation popup without leaving completion
    -- ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    -- ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    -- -- Jump between snippet placeholders
    -- ["<C-l>"] = { "snippet_forward", "fallback" },
    -- ["<C-h>"] = { "snippet_backward", "fallback" },
  },

  -- ── Completion Sources ────────────────────────────────────────
  -- Order matters: items from earlier sources rank higher.
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  -- ── Snippets ──────────────────────────────────────────────────
  -- Use blink's built-in snippet engine to expand friendly-snippets.
  snippets = {
    preset = "default",
  },

  -- ── Signature Help ────────────────────────────────────────────
  -- Show a floating window with the current function's signature while
  -- typing arguments (uses the LSP signatureHelp capability).
  signature = {
    enabled = true,
  },

  -- ── Appearance ────────────────────────────────────────────────
  appearance = {
    -- Render kind icons using the "mono" Nerd Font variant
    nerd_font_variant = "mono",
  },
})

