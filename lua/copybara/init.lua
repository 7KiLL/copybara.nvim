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
---@field handler fun(sel?: Selection):string Callback for item selection action
---@field desc string Description or example of usage
---@field needs? "range"|"text" Selection kind the item requires; nil means always shown

-- Ordered by priority: most useful first
---@type CopybaraMenuItem[]
local items = {
	{
		name = "Get LLM friendly selection",
		needs = "text",
		handler = function(sel)
			return h.range_ref(h.get_rel_file_ref(), sel) .. "\n" .. sel.text
		end,
		desc = "lua/copybara/init.lua#L10-L20\n<selected text>",
	},
	{
		name = "Get selected lines (relative)",
		needs = "range",
		handler = function(sel)
			return h.range_ref(h.get_rel_file_ref(), sel)
		end,
		desc = "lua/copybara/init.lua#L10-L20",
	},
	{
		name = "Get selected lines (absolute)",
		needs = "range",
		handler = function(sel)
			return h.range_ref(h.get_abs_file_ref(), sel)
		end,
		desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua#L10-L20",
	},
	{
		name = "Get selected lines with chars",
		needs = "text",
		handler = function(sel)
			return h.char_range_ref(h.get_abs_file_ref(), sel)
		end,
		desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua#L10C5-L20C12",
	},
	{
		name = "Get selected reference with text",
		needs = "text",
		handler = function(sel)
			return h.char_range_ref(h.get_abs_file_ref(), sel) .. "\n" .. sel.text
		end,
		desc = "/home/l7kill/code/copybara.nvim/lua/copybara/init.lua#L10C5-L20C12\n<selected text>",
	},
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

---@param sel Selection|nil
---@return CopybaraMenuItem[]
local function available_items(sel)
	return vim.tbl_filter(function(it)
		return it.needs == nil or (sel ~= nil and (it.needs == "range" or sel.text ~= nil))
	end, items)
end

M.draw_copy_action_menu = function(opts)
	local selection = utils.get_selection(opts)
	local items = available_items(selection)

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
			local out = it.handler(selection)
			notify(string.format("Copied!\n%s", out))
			utils.copy_to_clipboard(out)
		end
	end)
end

return M
