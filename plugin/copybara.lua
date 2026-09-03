if vim.g.loaded_copybara then
	return
end
vim.g.loaded_copybara = true

vim.api.nvim_create_user_command("Copybara", function(opts)
	require("copybara").run(opts)
end, {
	nargs = "?",
	range = true,
	desc = "Copy a file reference (no argument opens the menu)",
	complete = function()
		return require("copybara").action_ids()
	end,
})
