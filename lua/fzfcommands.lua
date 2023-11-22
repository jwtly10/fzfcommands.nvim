local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local M = {}

M.commands = {}
M.history = {}
M.local_commands = {}
M.dir = ""

local function combine(t1, t2)
    local result = {}

    for _, value in ipairs(t1) do
        table.insert(result, value)
    end

    for _, value in ipairs(t2) do
        table.insert(result, value)
    end

    return result
end

function M.setup(config)
    config = config or { "" }
    M.commands = config.commands or {}
    M.dir = config.dir or ""

    if M.dir ~= "" then
        local file, err = io.open(M.dir, "r")
        if err then
            error("Error loading private command file" .. err)
        end

        if file then
            local contents = file:read("*a")
            local commands = vim.json.decode(contents)

            if commands then
                if commands.commands ~= nil then
                    for _, value in ipairs(commands.commands) do
                        table.insert(M.local_commands, value)
                    end
                else
                    error("Error parsing private command file: commands key not found")
                end
            else
                error("Error parsing private command file" .. err)
            end


            if M.local_commands ~= nil then
                M.commands = combine(M.local_commands, M.commands)
                print("fzfcommands: Private command file loaded")
            end

            file:close()
        end
    end
end

function M.open_fzf_finder(opts)
    opts = opts or require("telescope.themes").get_dropdown()
    pickers.new(opts, {
        prompt_title = "Choose a command",
        finder = finders.new_table {
            results = combine(M.history, M.commands),
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = actions_state.get_selected_entry()
                if selection == nil then
                    local picker = actions_state.get_current_picker(prompt_bufnr)
                    local prompt = picker:_get_prompt()

                    -- Add to history
                    table.insert(M.history, prompt)

                    M.run_in_tmux(prompt)
                    actions.close(prompt_bufnr)
                    return
                end

                actions.close(prompt_bufnr)
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
