-- plugin/cmp.lua — Autocompletion
--
-- nvim-cmp is a completion engine for Neovim. It aggregates completion
-- candidates from multiple "sources" and displays them in a popup menu.
--
-- Sources used here:
--   cmp-nvim-lsp  — Completions from LSP servers (functions, types, etc.)
--   cmp-buffer    — Words from the current buffer
--   cmp-path      — File system paths
--   LuaSnip       — Snippet engine (expands snippet completions)
--   cmp_luasnip   — Bridge between nvim-cmp and LuaSnip

vim.pack.add({
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/hrsh7th/cmp-path",
  "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help",
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/saadparwaiz1/cmp_luasnip",
  "https://github.com/rafamadriz/friendly-snippets",
  "https://github.com/onsails/lspkind.nvim",
})

local cmp = require("cmp")
local luasnip = require("luasnip")

-- Load snippet collections from friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  -- ── Snippet expansion ──────────────────────────────────
  -- When a completion item is a snippet, this function expands it
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  -- ── Completion sources ─────────────────────────────────
  -- Order matters: higher in the list = higher priority in the menu.
  -- "group_index" groups sources; group 1 shows before group 2.
  sources = cmp.config.sources({
    { name = "nvim_lsp" },   -- LSP completions (highest priority)
    { name = "luasnip" },    -- Snippets
    { name = "path" },       -- File paths
  }, {
    { name = "buffer" },     -- Buffer words (fallback group)
  }),

  -- ── Key mappings ───────────────────────────────────────
  mapping = cmp.mapping.preset.insert({
    -- Navigate the completion menu
    ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
    ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
    ["<C-n>"] = cmp.mapping.select_next_item(),          -- Next item
    ["<C-p>"] = cmp.mapping.select_prev_item(),          -- Previous item

    -- Scroll documentation window
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),             -- Scroll up
    ["<C-f>"] = cmp.mapping.scroll_docs(4),              -- Scroll down
    ["<C-e>"] = cmp.mapping.scroll_docs(1),
    ["<C-y>"] = cmp.mapping.scroll_docs(-1),

    -- Trigger completion manually (usually auto-triggers)
    ["<C-Space>"] = cmp.mapping.complete(),

    -- Confirm selection
    -- "select = false" means you must explicitly pick an item;
    -- pressing Enter without selecting does a normal newline.
    -- ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),

    -- ['<Tab>'] = cmp.mapping(function(fallback)
    --     if cmp.visible() then
    --         if #cmp.get_entries() == 1 then
    --             cmp.confirm({ select = true })
    --         else
    --             cmp.select_next_item()
    --         end
    --     elseif luasnip.expand_or_jumpable() then
    --         luasnip.expand_or_jump()
    --     elseif has_words_before() then
    --         cmp.complete()
    --         if #cmp.get_entries() == 1 then
    --             cmp.confirm({ select = true })
    --         end
    --     else
    --         fallback()
    --     end
    -- end),
    -- ['<S-Tab>'] = cmp.mapping(function(fallback)
    --     if cmp.visible() then
    --         if #cmp.get_entries() == 1 then
    --             cmp.confirm({ select = true })
    --         else
    --             cmp.select_prev_item()
    --         end
    --     elseif luasnip.expand_or_jumpable() then
    --         luasnip.expand_or_jump()
    --     elseif has_words_before() then
    --         cmp.complete()
    --         if #cmp.get_entries() == 1 then
    --             cmp.confirm({ select = true })
    --         end
    --     else
    --         fallback()
    --     end
    -- end),
  }),

  -- ── Appearance ─────────────────────────────────────────
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },

  -- Show source name in the completion menu (e.g., [LSP], [Buffer])
  formatting = {
    format = function(entry, vim_item)
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        luasnip  = "[Snip]",
        buffer   = "[Buf]",
        path     = "[Path]",
      })[entry.source.name]
      return vim_item
    end,
  },
})
