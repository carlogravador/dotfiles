-- plugins/lualine.lua — Statusline
--
-- lualine.nvim replaces Neovim's default statusline with a configurable,
-- informative bar at the bottom of the screen.
--
-- The statusline is divided into sections:
--   ┌─────────────────────────────────────────────────────────┐
--   │ A │ B │ C                              X │ Y │ Z │
--   └─────────────────────────────────────────────────────────┘
--   A = mode (NORMAL, INSERT, etc.)
--   B = branch, diff stats
--   C = filename
--   X = diagnostics, filetype
--   Y = encoding, file format
--   Z = cursor position

return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",  -- File type icons in the statusline
  },
  event = "VeryLazy",  -- Load after UI is ready (doesn't block startup)
  config = function()

    local function displayRow()
        return "row: %l/%L"
    end

    local function displayColumn()
        return "col: %c"
    end

    require("lualine").setup({
      options = {
        -- Use a built-in theme (no external colorscheme dependency)
        theme = "dracula",
        -- Use simple ASCII separators (works in any terminal)
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
        -- Don't show lualine in these filetypes
        -- disabled_filetypes = {
        --   statusline = { "NvimTree" },
        -- },
        -- Use a single global statusline (Neovim 0.7+)
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
        --   "branch",
          -- "diff",
        },
        lualine_c = {
          { "filename", path = 1 },  -- path=1 shows relative path
          {"diagnostics"}
        },
        -- lualine_x = {
        --   "diagnostics",
        --   "filetype",
        -- },
        lualine_x = {
            -- {
            --     'searchcount',
            --     maxcount = 999999,
            --     timeout = 500,
            -- },
            {'encoding'},
            {'fileformat'},
            {'filetype'},
        },
        lualine_y = {},  -- Empty
        -- lualine_y = { "progress" },  -- Percentage through the file

        lualine_z = {
          {
            displayRow
          },
          {
            displayColumn
          }
        }
        -- lualine_z = { "location" },  -- Line:Column
      },
      extensions = {
        "nvim-tree",
        "fzf",
        "quickfix",
        "nvim-tree"
      }
    })
  end,
}
