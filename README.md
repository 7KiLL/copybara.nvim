# copybara.nvim

A tiny Neovim plugin for copying file references to your clipboard. Yes, I've missed it after JetBrains.

Open a menu, pick what you want, and it's copied. That's it.

![copybara menu](assets/demo.png)

## What it can copy

- Absolute path: `/home/you/project/lua/copybara/init.lua`
- Relative path: `lua/copybara/init.lua`
- Current line: `/home/you/project/lua/copybara/init.lua#L50`
- Selected lines: `/home/you/project/lua/copybara/init.lua#L10-L20`
- Selected lines with columns: `/home/you/project/lua/copybara/init.lua#L10C5-L20C12`
- Selection reference plus the selected text
- LLM friendly selection: relative path with line range, then the selected text. Handy for pasting into a chat with an AI.

The selection options only show up when you run the command from Visual mode.

## Install

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "7KiLL/copybara.nvim",
  opts = {},
}
```

Or with any other manager, then call setup:

```lua
require("copybara").setup()
```

## Usage

Run `:DrawMenu` in Normal mode or after selecting text in Visual mode.

A keymap is probably nicer:

```lua
vim.keymap.set({ "n", "v" }, "<leader>cp", ":DrawMenu<CR>", { desc = "Copybara menu" })
```

Soon: Dedicated commands for each action  

## Options

```lua
require("copybara").setup({
  disable_notifications = false, -- set to true to stop the "Copied!" popup
})
```

## Requirements

- Neovim 0.10 or newer
- A clipboard provider (the plugin writes to the `+` register)
