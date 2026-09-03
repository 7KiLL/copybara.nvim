local M = {}

M.get_current_line_with_abs_file_ref = function()
	local abs_path = vim.api.nvim_buf_get_name(0)

	local cursor_location = vim.api.nvim_win_get_cursor(0)

	return string.format("%s#L%d", abs_path, cursor_location[1])
end

M.get_abs_file_ref = function()
	return string.format("%s", vim.api.nvim_buf_get_name(0))
end

M.get_rel_file_ref = function()
	return vim.fn.expand("%:.")
end

M.get_current_line_with_rel_file_ref = function()
	local cursor_location = vim.api.nvim_win_get_cursor(0)

	return string.format("%s#L%s", M.get_rel_file_ref(), cursor_location[1])
end
---@param selection Selection
M.get_llm_friendly_selection = function(selection)
	return string.format(
		"%s#L%d-L%d\n%s",
		M.get_rel_file_ref(),
		selection.start.line,
		selection.finish.line,
		selection.text
	)
end

---@param selection Selection
M.get_selected_lines_with_rel_file_ref = function(selection)
	return string.format("%s#L%d-L%d", M.get_rel_file_ref(), selection.start.line, selection.finish.line)
end

---@param selection Selection
M.get_selected_lines_with_abs_file_ref = function(selection)
	return string.format("%s#L%d-L%d", M.get_abs_file_ref(), selection.start.line, selection.finish.line)
end

---@param selection Selection
M.get_selected_lines_with_chars_and_abs_file_ref = function(selection)
	return string.format(
		"%s#L%sC%-L%sC%",
		M.get_abs_file_ref(),
		selection.start.line,
		selection.start.pos,
		selection.finish.line,
		selection.finish.pos
	)
end

---@param selection Selection
M.get_selected_lines_with_chars_abs_file_text_ref = function(selection)
	return string.format(
		"%s#L%sC%-L%sC%",
		M.get_rel_file_ref(),
		selection.start.line,
		selection.start.pos,
		selection.finish.line,
		selection.finish.pos
	)
end

return M
