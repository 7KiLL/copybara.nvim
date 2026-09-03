---@class CopybaraConfig
---@field disable_notifications? boolean

---@class CopybaraPlugin
---@field setup fun(opts?: CopybaraConfig)
local M = {}

local utils = require("copybara.utils")
local h = require("copybara.handlers")

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

---@class CopybaraMenuItem
---@field name string Name of action item
---@field handler fun():string Callback for item selection action
---@field desc string Description or example of usage
---@type CopybaraMenuItem[]
local base_items = {
	{
		name = "Get line reference (relative)",
		handler = function()
			return h.line_ref(h.get_rel_file_ref())
		end,
		desc = "lua/copybara/init.lua#L50",
	},
	{
		name = "Get line reference (absolute)",
		handler = function()
			return h.line_ref(h.get_abs_file_ref())
		end,
		desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua#L50",
	},
	{
		name = "Get relative file reference",
		handler = h.get_rel_file_ref,
		desc = "lua/copybara/init.lua",
	},
	{
		name = "Get absolute file reference",
		handler = h.get_abs_file_ref,
		desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua",
	},
}

---@param selection Selection
---@return CopybaraMenuItem[]
local function selection_items(selection)
	local rel = h.range_ref(h.get_rel_file_ref(), selection)
	local abs = h.range_ref(h.get_abs_file_ref(), selection)
	local chars = selection.text and h.char_range_ref(h.get_abs_file_ref(), selection)

	local items = {}
	if selection.text then
		table.insert(items, {
			name = "Get LLM friendly selection",
			handler = function()
				return rel .. "\n" .. selection.text
			end,
			desc = "lua/copybara/init.lua#L10-L20\n<selected text>",
		})
	end
	table.insert(items, {
		name = "Get selected lines (relative)",
		handler = function()
			return rel
		end,
		desc = "lua/copybara/init.lua#L10-L20",
	})
	table.insert(items, {
		name = "Get selected lines (absolute)",
		handler = function()
			return abs
		end,
		desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua#L10-L20",
	})

	if selection.text then
		table.insert(items, {
			name = "Get selected lines with chars",
			handler = function()
				return chars
			end,
			desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua#L10C5-L20C12",
		})
		table.insert(items, {
			name = "Get selected reference with text",
			handler = function()
				return chars .. "\n" .. selection.text
			end,
			desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua#L10C5-L20C12\n<selected text>",
		})
	end
	return items
end

M.draw_copy_action_menu = function(opts)
	local selection = utils.get_selection(opts)
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
			local out = it.handler()
			notify(string.format("Copied!\n%s", out))
			utils.copy_to_clipboard(out)
		end
	end)
end

return M
