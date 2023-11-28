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

function M.load_local_commands(dir, loc)
    local file, err = io.open(dir, "r")
    if err then
        error("Error loading private command file" .. err)
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
                error("Error parsing private command file: commands key not found")
            end
        else
            error("Error parsing private command file" .. err)
        end

        file:close()
    end
end

function M.save_history(loc, prompt)
    table.insert(loc, prompt)
end

return M
