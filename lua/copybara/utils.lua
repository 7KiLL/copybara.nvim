local M = {}

---@param str string
M.copy_to_clipboard = function(str)
	vim.fn.setreg("+", str, "v")
end

--- @class Selection
--- @field start PosTuple
--- @field finish PosTuple
--- @field text? string Selected text, nil unless made in Visual mode
--- @class PosTuple
--- @field line number Line position
--- @field pos? number Column, nil unless made in Visual mode

---@param opts table User command opts (`range`, `line1`, `line2`)
---@return Selection|nil
M.get_selection = function(opts)
	if opts.range == 0 then
		return nil
	end

	local selection = { start = { line = opts.line1 }, finish = { line = opts.line2 } }

	local s, e = vim.fn.getpos("'<"), vim.fn.getpos("'>")
	local mode = vim.fn.visualmode()
	-- Marks describe this range only if Visual mode produced it
	if mode ~= "" and s[2] == opts.line1 and e[2] == opts.line2 then
		selection.start.pos = s[3]
		selection.finish.pos = math.min(e[3], #vim.fn.getline(e[2]))
		selection.text = table.concat(vim.fn.getregion(s, e, { type = mode }), "\n")
	end

	return selection
end

return M
