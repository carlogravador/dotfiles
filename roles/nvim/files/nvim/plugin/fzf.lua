-- plugin/fzf.lua — Fuzzy finder using fzf

vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

local fzf = require("fzf-lua")

local function send_file_selection_to_sidekick(selected)
  if not selected then
    return
  end
  local items = {}
  if type(selected) == "string" then
    for s in selected:gmatch("[^\r\n]+") do
      table.insert(items, s)
    end
  elseif type(selected) == "table" then
    items = selected
  end

  local ok, cli = pcall(require, "sidekick.cli")
  if not ok or type(cli.send) ~= "function" then
    return
  end

  for _, item in ipairs(items) do
    if type(item) == "string" and item ~= "" then
      local path = item
      local slash_pos = path:find("/")
      if slash_pos then
        -- Walk left from the first slash to find the start of the path token
        local start_pos = slash_pos
        while start_pos > 1 do
          local ch = path:sub(start_pos - 1, start_pos - 1)
          if ch:match("[%w._%-]") then
            start_pos = start_pos - 1
          else
            break
          end
        end
        path = path:sub(start_pos)
      else
        path = path:match("%S+") or path
      end
      -- remove trailing :<line> (e.g. file.lua:123) if present
      path = path:match("^%s*(.-)%s*$")
      path = path:gsub(":%d+$", "")
      if path ~= "" then
        pcall(cli.send, { msg = "@" .. path })
      end
    end
  end
end

fzf.setup({
  -- Use a "borderless" profile for a clean look, then override as needed
  "fzf-vim",
  winopts = {
    height = 0.85,
    width = 0.80,
    row = 0.35,
    preview = {
      hidden = false,
      default = "builtin",
      -- default = "bat",
      layout = "flex", -- Auto-switch between horizontal/vertical preview
      flip_columns = 120, -- Switch to vertical preview if window < 120 cols
    },
  },
  keymap = {
    builtin = {
      ["<C-y>"] = "preview-up",
      ["<C-e>"] = "preview-down",
    },
  },
  actions = {
    files = {
      ["ctrl-s"] = send_file_selection_to_sidekick,
    },
  },
})

fzf.register_ui_select()

-- ── Commands ─────────────────────────────────────────────
-- :Files [dir]  and  :Rg [dir]  mirror classic fzf.vim commands,
-- with tab-completion for directories so you can scope the search.
vim.api.nvim_create_user_command("Files", function(opts)
  fzf.files({ cwd = opts.args ~= "" and opts.args or nil })
end, { nargs = "?", complete = "dir", desc = "FZF files (optional dir)" })

vim.api.nvim_create_user_command("Rg", function(opts)
  fzf.live_grep({ cwd = opts.args ~= "" and opts.args or nil })
end, { nargs = "?", complete = "dir", desc = "FZF live grep (optional dir)" })

-- ── Keymaps ──────────────────────────────────────────────
local map = vim.keymap.set

-- File finding
map("n", "<leader>ff", fzf.files, { desc = "Find files" })

-- Grep / search
map("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
map("n", "<leader>fw", fzf.grep_cword, { desc = "Grep word under cursor" })
map("v", "<leader>fw", fzf.grep_visual, { desc = "Grep visual selection" })

-- Buffers & navigation
map("n", "<leader>fb", fzf.buffers, { desc = "Find buffers" })
map("n", "<leader>fh", fzf.helptags, { desc = "Help tags" })
map("n", "<leader>fk", fzf.keymaps, { desc = "Keymaps" })

-- LSP integration (find symbols, diagnostics via fzf)
map("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "Document symbols" })
map("n", "<leader>fS", fzf.lsp_workspace_symbols, { desc = "Workspace symbols" })
map("n", "<leader>fd", fzf.diagnostics_document, { desc = "Document diagnostics" })
map("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "Workspace diagnostics" })

-- Git
map("n", "<leader>gc", fzf.git_commits, { desc = "Git commits" })
map("n", "<leader>gs", fzf.git_status, { desc = "Git status" })
