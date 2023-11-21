# fzfcommands.nvim

A Neovim plugin that provides an interactive FZF interface to run custom commands and shell commands in a split-window tmux pane.

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

```lua
-- Example Config
require('fzfcommands').setup({
  commands = {
    "mvn clean install",
    "git status", 
  },
  dir = "/path/to/local_commands.json", -- optional local private commands file,
  -- used to allow private commands which are hidden with .gitignore
})
```

The local commands JSON file should be in this format:

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
