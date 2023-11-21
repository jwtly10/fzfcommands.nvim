local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local log = require("plenary.log")

local M = {}

M.commands = {}
M.history = {}

local function listCommands(t1, t2)
    local result = {}

    for _, value in ipairs(t2) do
        table.insert(result, value .. " (recent)")
    end

    for _, value in ipairs(t1) do
        table.insert(result, value)
    end

    return result
end

function M.setup(config)
    config = config or { "" }
    M.commands = config.commands or {}
end

function M.open_fzf_finder(opts)
    opts = opts or require("telescope.themes").get_dropdown()
    pickers.new(opts, {
        prompt_title = "Choose a command",
        finder = finders.new_table {
            results = listCommands(M.commands, M.history),
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = actions_state.get_selected_entry()
                if selection == nil then
                    local picker = actions_state.get_current_picker(prompt_bufnr)
                    local prompt = picker:_get_prompt()
                    log.info("Manual Command: " .. vim.inspect(prompt))

                    -- Add to history
                    table.insert(M.history, prompt)

                    M.run_in_tmux(prompt)
                    actions.close(prompt_bufnr)
                    return
                end

                actions.close(prompt_bufnr)
                log.info("Command Selected: " .. vim.inspect(selection[1]))
                M.run_in_tmux(selection[1])
            end)

            return true
        end
    }):find()
end

function M.run_in_tmux(command)
    local current_directory = vim.fn.getcwd()
    local tmux_command = string.format("tmux split-window -h -c '%s' 'cd %s && %s; read -n 1'", current_directory,
        current_directory, command)
    vim.fn.system(tmux_command)
end

return M
