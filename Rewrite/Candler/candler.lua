candler = {}

candler.cats = {}
candler.commands = {}
candler.prefix = "."

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end


events.CHAT_SEND_MESSAGE:register(function(msg)
    if string.sub(msg, 1, string.len(candler.prefix)) ~= candler.prefix then
        return msg
    else
        local cmd = string.sub(msg, string.len(candler.prefix)+1, -1)
        -- print(cmd)
        
        local args = split(cmd, " ")
        
        local jsonMsg = '[{"text":"> ","color":"dark_gray"}'
        for i, v in ipairs(args) do
            local thing = string.gsub(v, "\\", "\\\\")
            thing = string.gsub(thing, "\"", "\\\"")
            if i == 1 then
                jsonMsg = jsonMsg .. ', {"text":"' .. thing .. ' ", "color":"gray"}'
            else
                jsonMsg = jsonMsg .. ', {"text":"' .. thing .. ' ", "color":"aqua"}'
            end
        end
        jsonMsg = jsonMsg .. ', {"text":"\n"}]'
        printJson(jsonMsg)
        
        host:appendChatHistory(msg)

        if cmd == "" then
            printJson('[{"text":"ERROR!", "color":"red", "bold":true}, {"text":" No command specified. Type \\\"' .. candler.prefix .. 'help\\\" for help.", "color":"gray", "bold":false}]')
            return nil
        end

        for k, v in pairs(candler.commands) do
            if k == string.lower(args[1]) then
                local aliasused = args[1]
                table.remove(args, 1)
                v(args, aliasused)
                return nil
            end
        end

        printJson('[{"text":"ERROR!", "color":"red", "bold":true}, {"text":" Unknown command. Type \\\"' .. candler.prefix .. 'help\\\" for help.", "color":"gray", "bold":false}]')

        return nil
    end
end)

events.RENDER:register(function()
    if host:getChatText() then
        if string.sub(host:getChatText(), 1, string.len(candler.prefix)) == candler.prefix then
            host:setChatColor(vectors.hexToRGB("#54fbfb"))
        else
            host:setChatColor(vec(1,1,1))
        end
    end
end)

-- ========== COMMAND TOOLS ========== --
function requireArgs(l, args)
    for _, v in ipairs(l) do
        if not args[v] then
            print("Error! Argument " .. tostring(v) .. " required!")
            return false
        end
    end
    return true
end

-- ========== LIBRARY ========== --
local lib = {}

-- Register a new category (cats for short).
---@param name string The name of the category. Will be used as the cat's namespace and help name.
---@param information table The information of the category. See README.MD for more information and a template to copy.
function lib.newCategory(name, information)
    if not name then
        error("Category name is required.")
        return false
    end
    if type(name) ~= "string" then
        error("Category name must be string.")
        return false
    end
    if type(information) ~= "table" then
        error("Category information must be table.")
        return false
    end

    name = string.lower(name)

    candler.cats[name] = information
    candler.cats[name].commands = {}
    return true
end

-- Register a new command.
---@param cat string The name of the category to put the command under.
---@param name string The name of the command, also used as the command's main alias.
---@param information table Information about the command. See README.MD for more information and a template to copy.
---@param funct function The function to call when the command is called.
function lib.setCommand(cat, name, information, funct)
    if not cat then
        error("Category name is required.")
        return false
    end
    if not name then
        error("Command name is required.")
        return false
    end
    if not funct then
        error("Command function is required.")
        return false
    end
    if type(cat) ~= "string" then
        error("Category name must be string.")
        return false
    end
    if type(name) ~= "string" then
        error("Command name must be string.")
        return false
    end
    if type(information) ~= "table" then
        error("Command information must be table.")
        return false
    end
    if type(funct) ~= "function" then
        error("Command function must be function.")
        return false
    end

    cat = string.lower(cat)
    name = string.lower(name)

    candler.cats[cat].commands[name] = information
    candler.cats[cat].commands[name].command = funct
    candler.commands[name] = funct

    if information.aliases then
        for _, v in ipairs(information.aliases) do
            candler.commands[v] = funct
        end
    end
end

-- Removes a category from the registry.
---@param cat string The name of the category to remove.
function lib.removeCategory()
    if not cat then
        error("Category name is required.")
        return false
    end
    if type(cat) ~= "string" then
        error("Category name must be string.")
        return false
    end
    candler.cats[cat] = nil
end

-- Removes a command from a category.
---@param cat string The name of the category that contains the command to remove.
---@param name string The name of the command to remove.
function lib.removeCommand(cat, name)
    if not cat then
        error("Category name is required.")
        return false
    end
    if not name then
        error("Command name is required.")
        return false
    end
    if type(cat) ~= "string" then
        error("Category name must be string.")
        return false
    end
    if type(name) ~= "string" then
        error("Command name must be string.")
        return false
    end
    candler.cats[cat].commands[name] = nil
end

lib.newCategory("Candler", {
    description = "A command interpreter for Figura.",
    author = "Slymeball",
    version = "0.1.0",
    website = "https://github.com/Slymeball/figura-avatars/tree/main/Rewrite/Candler",
    issues = "https://github.com/Slymeball/figura-avatars/issues"
})

return lib