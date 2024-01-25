# fzfcommands.nvim

A Neovim plugin that provides an interactive FZF interface to run custom commands and shell commands in a split-window tmux pane.

## Demo
Here is a simple demo of the plugin. 

A shortcut open the fzf cmd line, allowing you run new commands or run a previous command. 

I then demonstrate a seperate shortcut allowing you to run the last run command instantly.

All commands are run in a seperate tmux pane, or a full new window (configurable below) 

https://github.com/jwtly10/fzfcommands.nvim/assets/39057715/cb180932-86af-4db9-8feb-1af05c240a23


## Features
- Interactive picker to select commands using fzf 
- Specify custom commands in config
- Load additional private/local commands from json file
- Persistent command history during session
- Runs commands in horizontal tmux pane

## Usage

Call `require('fzfcommands').open_fzf_finder()` to open the fzf command finder - eg.
```lua
vim.api.nvim_set_keymap("n", "<leader>ff", "<cmd>lua require('fzfcommands').open_fzf_finder()<cr>",{ noremap = true, silent = true })
```

Start typing to search commands and history. Use arrow keys to navigate and `<CR>` to run selected command.

## Installation

```lua
-- Using Packer
use { 'jwtly10/fzfcommands.nvim' }
```


``` bash
# Manually
git clone https://github.com/jwtly10/fzfcommands.nvim ~/.config/nvim/pack/plugins/start/fzfcommands.nvim
```

### Configuration
```lua
-- Example Config
require('fzfcommands').setup({
  commands = {
    "mvn clean install",
    "git status", 
  },
  settings = {
        split = true,-- open new tmux pane either split view or new window
        dir = "/path/to/local_commands.json", -- optional local private commands file,
  -- used to allow private commands which are hidden with .gitignore
  }
})
```

The local commands JSON file should be in the following format.
You are free to edit this file to manually load commands, or bulk remove. As long as JSON format is adhered to.
```json
{
  "commands": [
    "Rebuild ctags",
    "Test command" 
  ]
}
```

## Implementation
- Uses Telescope.nvim for fzf UI
- Runs commands in tmux using tmux split-window
- Allows free text commands, which are stored for easy use during session
- Loads additional local commands from json
