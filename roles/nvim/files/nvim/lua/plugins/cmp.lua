-- plugins/cmp.lua — Autocompletion
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

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",  -- Lazy-load: only load when entering insert mode
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",     -- LSP completion source
    "hrsh7th/cmp-buffer",       -- Buffer words source
    "hrsh7th/cmp-path",         -- File path source
    "L3MON4D3/LuaSnip",        -- Snippet engine
    "saadparwaiz1/cmp_luasnip", -- Snippet completion source
    "rafamadriz/friendly-snippets", -- Collection of common snippets
  },
  config = function()
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
        ["<C-n>"] = cmp.mapping.select_next_item(),          -- Next item
        ["<C-p>"] = cmp.mapping.select_prev_item(),          -- Previous item

        -- Scroll documentation window
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),             -- Scroll up
        ["<C-f>"] = cmp.mapping.scroll_docs(4),              -- Scroll down

        -- Trigger completion manually (usually auto-triggers)
        ["<C-Space>"] = cmp.mapping.complete(),

        -- Cancel completion
        ["<C-e>"] = cmp.mapping.abort(),

        -- Confirm selection
        -- "select = false" means you must explicitly pick an item;
        -- pressing Enter without selecting does a normal newline.
        ["<CR>"] = cmp.mapping.confirm({ select = false }),

        -- Tab: accept completion or jump to next snippet placeholder
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()  -- Insert a literal Tab character
          end
        end, { "i", "s" }),

        -- Shift-Tab: reverse of Tab
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
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
  end,
}
