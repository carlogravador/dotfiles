-- plugin/dap.lua — Debug Adapter Protocol (DAP) configuration
--
-- DAP lets you debug programs directly inside Neovim with breakpoints,
-- stepping, variable inspection, and more — like a traditional IDE debugger.
--
-- Architecture:
--   nvim-dap          — The DAP client (talks to debug adapters)
--   nvim-dap-ui       — UI panels for variables, breakpoints, call stack, REPL
--   mason-nvim-dap    — Auto-install debug adapters via Mason
--   codelldb          — Debug adapter for Rust, C, and C++ (based on LLDB)
--
-- How DAP works:
--   1. You set breakpoints in your code
--   2. You start a debug session (F5)
--   3. nvim-dap launches the debug adapter (codelldb) which starts your program
--   4. The program pauses at breakpoints; you can inspect variables, step through code, etc.
--
-- Keybindings (set below):
--   F5         — Start/continue debugging
--   F10        — Step over (execute current line, skip into functions)
--   F11        — Step into (enter the function call)
--   F12        — Step out (finish current function, return to caller)
--   <leader>b  — Toggle breakpoint on current line
--   <leader>B  — Set conditional breakpoint (prompts for condition)
--   <leader>dr — Toggle DAP REPL (interactive debug console)
--   <leader>du — Toggle DAP UI panels

vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/rcarriga/nvim-dap-ui",
  "https://github.com/nvim-neotest/nvim-nio",
  "https://github.com/jay-babu/mason-nvim-dap.nvim",
})

local dap = require("dap")
local dapui = require("dapui")

-- ── nvim-dap-ui ──────────────────────────────────────────────
-- Layout: panels on the left (scopes, breakpoints, stacks)
-- and a panel on the bottom (repl, console)
dapui.setup({
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.40 },      -- Variables in current scope
        { id = "breakpoints", size = 0.20 },  -- List of all breakpoints
        { id = "stacks", size = 0.20 },       -- Call stack
        { id = "watches", size = 0.20 },      -- Watch expressions
      },
      size = 40,         -- Width in columns
      position = "left",
    },
    {
      elements = {
        { id = "repl", size = 0.50 },     -- Debug REPL
        { id = "console", size = 0.50 },  -- Program output
      },
      size = 10,         -- Height in lines
      position = "bottom",
    },
  },
})

-- Automatically open/close the DAP UI when a debug session starts/ends
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- ── mason-nvim-dap — Auto-install debug adapters via Mason ───
-- Requires mason.nvim to be set up first (done in 01-mason.lua).
require("mason-nvim-dap").setup({
  -- Debug adapters to auto-install
  ensure_installed = {
    "codelldb",  -- LLDB-based adapter for Rust, C, C++
  },
  -- Automatically configure installed adapters
  automatic_installation = true,
  -- Use default handler (auto-configures adapters with sensible defaults)
  handlers = {},
})

-- ── Breakpoint signs ─────────────────────────────────────────
-- Customize how breakpoints look in the sign column
vim.fn.sign_define("DapBreakpoint", {
  text = "●",
  texthl = "DapBreakpoint",
  linehl = "",
  numhl = "",
})
vim.fn.sign_define("DapBreakpointCondition", {
  text = "◆",
  texthl = "DapBreakpointCondition",
  linehl = "",
  numhl = "",
})
vim.fn.sign_define("DapStopped", {
  text = "▶",
  texthl = "DapStopped",
  linehl = "DapStoppedLine",
  numhl = "",
})

-- ── codelldb adapter configuration ───────────────────────────
-- mason-nvim-dap's handlers auto-configure codelldb, but if you
-- need to override, you can do it here:
--
-- The adapter is the program that nvim-dap talks to.
-- codelldb speaks the DAP protocol and controls LLDB under the hood.
--
-- If mason-nvim-dap doesn't configure it automatically, uncomment:
-- local mason_path = vim.fn.stdpath("data") .. "/mason"
-- local codelldb_path = mason_path .. "/bin/codelldb"
--
-- dap.adapters.codelldb = {
--   type = "server",
--   port = "${port}",
--   executable = {
--     command = codelldb_path,
--     args = { "--port", "${port}" },
--   },
-- }

-- ── Debug configurations per language ────────────────────────
-- These define HOW to start debugging for each language.
-- "request = launch" means start a new process.
-- "request = attach" means connect to an already-running process.

-- C
dap.configurations.c = {
  {
    name = "Launch (C)",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}

-- C++ (same adapter, same configuration pattern)
dap.configurations.cpp = dap.configurations.c

-- ── Keymaps ──────────────────────────────────────────────────
local map = vim.keymap.set

-- Session control
map("n", "<F5>", dap.continue, { desc = "DAP: Start/Continue" })
map("n", "<F10>", dap.step_over, { desc = "DAP: Step Over" })
map("n", "<F11>", dap.step_into, { desc = "DAP: Step Into" })
map("n", "<F12>", dap.step_out, { desc = "DAP: Step Out" })
map("n", "<leader>dt", dap.terminate, { desc = "DAP: Terminate session" })

-- Breakpoints
map("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
map("n", "<leader>B", function()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP: Set conditional breakpoint" })
map("n", "<leader>lp", function()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "DAP: Set log point" })

-- UI
map("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })
map("n", "<leader>dr", dap.repl.toggle, { desc = "DAP: Toggle REPL" })

-- Hover (inspect variable under cursor during debug)
map({ "n", "v" }, "<leader>dh", function()
  require("dap.ui.widgets").hover()
end, { desc = "DAP: Hover variable" })
