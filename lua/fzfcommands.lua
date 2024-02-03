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

-- Ordered list of commands that we actually want to display
M.shownList = {}

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
    M.shownList = M.history

    -- TODO: Add this functionality back
    -- M.shownList = utils.combine(M.history, M.commands)
end

function M.run_last_command()
    local last_command = M.shownList[1]
    if last_command ~= nil then
        print("Running: " .. last_command)
        tmux.run(last_command, M.config)
    end
end

function M.open_fzf_finder(opts)
    local checkLocalCmds = {}
    utils.load_history(checkLocalCmds)

    vim.pretty_print(checkLocalCmds)
    vim.pretty_print(M.history)

    if not utils.deep_compare(checkLocalCmds, M.history) then
        -- If the file history has changed, then we need to reload the commands
        print("fzfcommands: Detected local command file change, reloading...")
        M.history = checkLocalCmds
        M.shownList = M.history
    end

    opts = opts or require("telescope.themes").get_dropdown()
    pickers.new(opts, {
        prompt_title = "Choose a command",
        finder = finders.new_table {
            results = M.shownList,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = actions_state.get_selected_entry()
                local recent_command = ""
                local picker = actions_state.get_current_picker(prompt_bufnr)
                local prompt = picker:_get_prompt()
                -- If we cant find a selection, then we need to get the prompt
                if selection == nil or selection[1] ~= prompt and string.len(prompt) > 3 then
                    -- Add to history
                    utils.save_history(M.history, prompt)

                    tmux.run(prompt, M.config)
                    actions.close(prompt_bufnr)
                    recent_command = prompt
                else
                    -- Otherwise run the command
                    actions.close(prompt_bufnr)
                    tmux.run(selection[1], M.config)
                    recent_command = selection[1]
                end

                -- Rebuild the shownList of commands, reordering the most recent command
                local old_map = M.shownList
                M.shownList = {}

                table.insert(M.shownList, recent_command)

                for _, command in ipairs(old_map) do
                    if command ~= recent_command then
                        table.insert(M.shownList, command)
                    end
                end
            end)
            return true
        end
    }):find()
end

return M
