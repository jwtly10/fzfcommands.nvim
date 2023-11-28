M = {}

function M.combine(t1, t2)
    local result = {}

    for _, value in ipairs(t1) do
        table.insert(result, value)
    end

    for _, value in ipairs(t2) do
        table.insert(result, value)
    end

    return result
end

-- Read the local commands file and add the commands to the loc table.
--- @param dir string: The path to the project.
--- @param loc table: The table to save the commands to.
function M.read_local_commands_file(dir, loc)
    local file, err = io.open(dir, "r")
    if err then
        -- TODO: Log error based on usage
        return
    end

    if file then
        local contents = file:read("*a")
        local commands = vim.json.decode(contents)

        if commands then
            if commands.commands ~= nil then
                for _, value in ipairs(commands.commands) do
                    table.insert(loc, value)
                end
            else
                error("Error parsing local command file: commands key not found")
            end
        else
            error("Error parsing local command file" .. err)
        end

        file:close()
    end
end

-- Find the nearest git directory.
local function find_nearest_git()
    local git_cmd = vim.fn.system('git rev-parse --show-toplevel 2> /dev/null')
    return vim.fn.trim(git_cmd)
end

-- Save the commands to the local commands file.
--- @param project_path string: The path to the project.
--- @param commands table: The commands table to save.
local function save_historic_commands(project_path, commands)
    local config = {
        commands = commands
    }

    local json_config = vim.fn.json_encode(config)

    local file_path = project_path .. '/.git/fzfcommands.json'

    vim.fn.writefile({ json_config }, file_path)
end

-- Save the command to the history.
--- @param commands table: The current state of history command table.
--- @param prompt string: The command to save.
function M.save_history(commands, prompt)
    table.insert(commands, 1, prompt)
    save_historic_commands(find_nearest_git(), commands)
end

-- Load the history commands.
--- @param loc table: The commands table to load the history into.
function M.load_history(loc)
    local file_path = find_nearest_git() .. '/.git/fzfcommands.json'
    M.read_local_commands_file(file_path, loc)
end

return M
