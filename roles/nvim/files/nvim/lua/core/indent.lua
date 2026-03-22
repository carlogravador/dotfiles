-- core/indent.lua — Shared filetype indentation helper
--
-- Called from ftplugin/ files to set buffer-local indent width.
-- Centralizes indent logic so each ftplugin file stays a one-liner.
--
-- Usage (in ftplugin/lua.lua):
--   require("core.indent").set(2)

local M = {}

--- Set buffer-local indentation width.
--- @param width number Number of spaces per indent level.
function M.set(width)
  vim.bo.tabstop = width
  vim.bo.shiftwidth = width
  vim.bo.softtabstop = width
end

return M
