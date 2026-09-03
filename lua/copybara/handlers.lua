local M = {}

M.get_abs_file_ref = function()
	return vim.api.nvim_buf_get_name(0)
end

M.get_rel_file_ref = function()
	return vim.fn.expand("%:.")
end

---@param path string
M.line_ref = function(path)
	return string.format("%s#L%d", path, vim.api.nvim_win_get_cursor(0)[1])
end

---@param path string
---@param sel Selection
M.range_ref = function(path, sel)
	return string.format("%s#L%d-L%d", path, sel.start.line, sel.finish.line)
end

---@param path string
---@param sel Selection
M.char_range_ref = function(path, sel)
	return string.format("%s#L%dC%d-L%dC%d", path, sel.start.line, sel.start.pos, sel.finish.line, sel.finish.pos)
end

return M
