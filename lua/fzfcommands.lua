local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local tmux = require("tmux_utils")
local utils = require("utils")

local M = {}

-- Main command list
M.commands = {}
-- Historic Commands
M.history = {}
-- Local commands from config setup
M.local_commands = {}

M.config = {}

function M.setup(config)
    M.config = config or {}
    M.commands = config.commands or {}

    if config.settings.dir ~= nil then
        -- utils.read_local_commands_file(config.settings.dir, M.local_commands)

        if M.local_commands ~= nil then
            M.commands = utils.combine(M.local_commands, M.commands)
            print("fzfcommands: Private command file loaded")
        end
    end

    -- Load historic commands
    utils.load_history(M.history)
end

function M.open_fzf_finder(opts)
    opts = opts or require("telescope.themes").get_dropdown()
    pickers.new(opts, {
        prompt_title = "Choose a command",
        finder = finders.new_table {
            results = utils.combine(M.history, M.commands),
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = actions_state.get_selected_entry()
                if selection == nil then
                    local picker = actions_state.get_current_picker(prompt_bufnr)
                    local prompt = picker:_get_prompt()

                    -- Add to history
                    utils.save_history(M.history, prompt)

                    tmux.run(prompt, M.config)
                    actions.close(prompt_bufnr)
                    return
                end

                actions.close(prompt_bufnr)
                tmux.run(selection[1], M.config)
            end)

            return true
        end
    }):find()
end

return M
