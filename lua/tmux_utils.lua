M = {}

function M.run(command, config)
    local current_directory = vim.fn.getcwd()
    local tmux_command = ""

    if config.settings.split then
        tmux_command = string.format("tmux split-window -h -c '%s' 'cd %s && %s; read -n 1'", current_directory,
            current_directory, command)
    else
        tmux_command = string.format("tmux new-window -c '%s' 'cd %s && %s; read -n 1'", current_directory,
            current_directory, command)
    end
    vim.fn.system(tmux_command)
end

return M
