-- plugin/lualine.lua — Statusline
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

vim.pack.add({ "https://github.com/nvim-lualine/lualine.nvim" })

-- Returns the fg/bg of lualine_y_normal so inactive sections can mirror it.
-- Called as a function so it resolves after lualine has defined its highlights.
local function inactive_color()
  return {
    -- fg = hl.fg and string.format("#%06x", hl.fg) or nil,
    -- bg = hl.bg and string.format("#%06x", hl.bg) or nil,
    fg = "#82aaff",
    bg = "#3b4261",
  }
end

local sidekick_ok, sidekick_status = pcall(require, "sidekick.status")

require("lualine").setup({
  options = {
    -- Use a built-in theme (no external colorscheme dependency)
    -- theme = "dracula",
    -- Use simple ASCII separators (works in any terminal)
    component_separators = { left = "|", right = "|" },
    section_separators = { left = "", right = "" },
    -- Don't show lualine in these filetypes
    -- disabled_filetypes = {
    --   statusline = { "NvimTree" },
    -- },
    -- Use a single global statusline (Neovim 0.7+)
    -- globalstatus = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      "diff",
    },
    lualine_c = {
      { "filename", path = 1 },  -- path=1 shows relative path
      -- Sidekick: Copilot status
      {
        function()
          if not sidekick_ok then
            return ""
          end
          return " "
        end,
        color = function()
          if not sidekick_ok then
            return nil
          end
          local status = sidekick_status.get()
          if status then
            if status.kind == "Error" then
              return "DiagnosticError"
            elseif status.busy then
              return "DiagnosticWarn"
            else
              return "Special"
            end
          end
        end,
        cond = function()
          if not sidekick_ok then
            return false
          end
          return sidekick_status.get() ~= nil
        end,
      },
      -- { "diagnostics" },
    },
    lualine_x = {
      "diagnostics",
      -- CLI session status (from sidekick)
      {
        function()
          if not sidekick_ok then
            return ""
          end
          local status = sidekick_status.cli()
          return " " .. (#status > 1 and #status or "")
        end,
        cond = function()
          return sidekick_ok and #sidekick_status.cli() > 0
        end,
        color = function()
          return "Special"
        end,
      },
      "filetype",
    },
    lualine_y = {
      { "encoding" },
      { "fileformat" },
      -- { "filetype" },
    },
    -- lualine_y = { "progress" },  -- Percentage through the file
    lualine_z = {
      {
        function()
          return "row: %l/%L"
        end,
      },
      {
        function()
          return "col: %c"
        end,
      },
    },
    -- lualine_z = { "location" },  -- Line:Column
  },
  inactive_sections = {
      lualine_c = {
          { "filename", path = 1, color = inactive_color },
      },
      lualine_x = {
          { "encoding",   color = inactive_color },
          { "fileformat", color = inactive_color },
          { "filetype",   color = inactive_color },
      },
      -- lualine_y = { displayFileLines },
      -- lualine_z = {
      --   {
      --       displayRow
      --   },
      --   {
      --       displayColumn
      --   }
      -- }
  },
  extensions = {
    "nvim-tree",
    "fzf",
    "quickfix"
  },
})
