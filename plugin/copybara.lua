if vim.g.loaded_copybara then
	return
end
vim.g.loaded_copybara = true

vim.api.nvim_create_user_command("DrawMenu", function(opts)
	require("copybara").draw_copy_action_menu(opts)
end, { range = true, desc = "Open the Copybara copy menu" })
