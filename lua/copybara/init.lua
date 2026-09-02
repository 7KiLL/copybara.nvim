---@class CopybaraConfig
---@field disable_notifications? boolean

---@class CopybaraPlugin
---@field setup fun(opts?: CopybaraConfig)
local M = {}

---@type fun(str: string)
local notify = function(str)
	vim.notify(str)
end

---@param opts? CopybaraConfig
M.setup = function(opts)
	opts = opts or {}

	if opts.disable_notifications then
		notify = function() end
	end
end

local get_current_line_with_ref_abs = function()
	local abs_path = vim.api.nvim_buf_get_name(0)

	local cursor_location = vim.api.nvim_win_get_cursor(0)

	return string.format("%s#L%d", abs_path, cursor_location[1])
end

---@param str string
local function copy_to_clipboard(str)
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
local function get_selection(opts)
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

local function get_abs_file_ref()
	return string.format("%s", vim.api.nvim_buf_get_name(0))
end

local function get_rel_file_ref()
	return vim.fn.expand("%:.")
end

local function get_current_line_with_ref_rel()
	local cursor_location = vim.api.nvim_win_get_cursor(0)

	return string.format("%s#L%s", get_rel_file_ref(), cursor_location[1])
end

---@class CopybaraMenuItem
---@field name string Name of action item
---@field handler fun():string Callback for item selection action
---@field desc string Description or example of usage
---@type CopybaraMenuItem[]
local base_items = {
	{
		name = "Get line reference (relative)",
		handler = get_current_line_with_ref_rel,
		desc = "lua/copybara/init.lua#L50",
	},
	{
		name = "Get line reference (absolute)",
		handler = get_current_line_with_ref_abs,
		desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua#L50",
	},
	{
		name = "Get relative file reference",
		handler = get_rel_file_ref,
		desc = "lua/copybara/init.lua",
	},
	{
		name = "Get absolute file reference",
		handler = get_abs_file_ref,
		desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua",
	},
}

---@param selection Selection
---@return CopybaraMenuItem[]
local function selection_items(selection)
	local abs_path = vim.api.nvim_buf_get_name(0)
	local rel_lines = string.format("%s#L%d-L%d", get_rel_file_ref(), selection.start.line, selection.finish.line)
	local abs_lines = string.format("%s#L%d-L%d", abs_path, selection.start.line, selection.finish.line)

	-- Ordered by priority: most useful first
	local items = {}
	if selection.text then
		table.insert(items, {
			name = "Get LLM friendly selection",
			handler = function()
				return rel_lines .. "\n" .. selection.text
			end,
			desc = "lua/copybara/init.lua#L10-L20\n<selected text>",
		})
	end
	table.insert(items, {
		name = "Get selected lines (relative)",
		handler = function()
			return rel_lines
		end,
		desc = "lua/copybara/init.lua#L10-L20",
	})
	table.insert(items, {
		name = "Get selected lines (absolute)",
		handler = function()
			return abs_lines
		end,
		desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua#L10-L20",
	})
	if selection.text then
		local ref = string.format(
			"%s#L%dC%d-L%dC%d",
			abs_path,
			selection.start.line,
			selection.start.pos,
			selection.finish.line,
			selection.finish.pos
		)
		table.insert(items, {
			name = "Get selected lines with chars",
			handler = function()
				return ref
			end,
			desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua#L10C5-L20C12",
		})
		table.insert(items, {
			name = "Get selected reference with text",
			handler = function()
				return ref .. "\n" .. selection.text
			end,
			desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua#L10C5-L20C12\n<selected text>",
		})
	end
	return items
end

M.draw_copy_action_menu = function(opts)
	local selection = get_selection(opts)
	local items = selection and selection_items(selection) or {}
	vim.list_extend(items, base_items)

	local longest = 0
	for _, it in ipairs(items) do
		longest = math.max(longest, vim.api.nvim_strwidth(it.name))
	end
	vim.ui.select(items, {
		prompt = "Copybara",
		format_item = function(it)
			return string.format("%-" .. longest .. "s", it.name)
		end,
	}, function(it)
		if it then
			notify(string.format("Copied!\n%s", it.handler()))
			copy_to_clipboard(it.handler())
		end
	end)
end

return M
