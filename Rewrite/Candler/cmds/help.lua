require("Candler.candler").setCommand("Candler", "help", {
    aliases = {"?"},
    description = "Displays a list of commands or a command's information.",
    arguments = {
        {
            name = "category", -- The name of the argument.
            description = "The category to show the commands of.", -- A description of the argument.
            required = false, -- Does not actually do anything, just shows the argument as <arg> in help menus. If not required, it is displayed as [arg].
        },
        {
            name = "command", -- The name of the argument.
            description = "The command to list the information of.", -- A description of the argument.
            required = false, -- Does not actually do anything, just shows the argument as <arg> in help menus. If not required, it is displayed as [arg].
        },
        {
            name = "page", -- The name of the argument.
            description = "The page of help to list.", -- A description of the argument.
            required = false, -- Does not actually do anything, just shows the argument as <arg> in help menus. If not required, it is displayed as [arg].
            default = 1,
        }
    }
}, function (args)
    local header
    if not args[1] then
        args[1] = "1"
    end

    -- Get (hopefully) sorted list of aliases and their corresponding command.
    local commandList = {}
    local catList = {}
    for catk, catv in pairs(candler.cats) do
        catList[catk] = {description = catv.description}
        for cmdk, cmdv in pairs(catv.commands) do
            commandList[cmdk] = cmdv
            -- print(cmdv)
            for _, alias in pairs(cmdv.aliases) do
                commandList[alias] = {}
                commandList[alias].description = cmdv.description
                commandList[alias].arguments = cmdv.arguments
                commandList[alias].aliases = {cmdk}
            end
        end
    end

    local combList = {}
    for key, value in pairs(catList) do
        combList[key] = value
    end
    for key, value in pairs(commandList) do
        combList[candler.prefix .. key] = value
    end

    local a = {}
    for n in pairs(commandList) do table.insert(a, n) end
    table.sort(a)

    local b = {}
    for n in pairs(catList) do table.insert(b, n) end
    table.sort(b)

    local ba = b
    for key, value in pairs(a) do
        table.insert(ba, candler.prefix .. value)
    end
    -- print(ba)

    if tonumber(args[1]) then
        -- Set and Print Header
        header = '["",{"text":"                    ","color":"yellow","strikethrough":true}," Help (Page ' .. tonumber(args[1]) .. ') ",{"text":"                    ","color":"yellow","strikethrough":true}]'
        printJson(header)
        
        -- Print out the page
        for i = (8*(tonumber(args[1])-1))+1, (8*(tonumber(args[1])-1))+8 do
            if not combList[ba[i]] then
                printJson('"\n"')
                goto continue
            end

            if #combList[ba[i]].description > 50 then
                desc = string.sub(combList[ba[i]].description, 1, 50) .. "..."
            else
                desc = string.sub(combList[ba[i]].description, 1, 50)
            end

            desc = string.gsub(desc, "\\", "\\\\")
            -- desc = string.gsub("Lorem Ipsum Dolar Sit Amet", "\\", "\\\\")
            -- print(combList[ba[i]])
            desc = string.gsub(desc, "\"", "\\\"")
            printJson('[{"text":"\n' .. ba[i] .. ': ","color":"gold"},{"text":"' .. desc .. '","color":"white"}]')
            ::continue::
        end
    elseif catList[string.lower(args[1])] then
        if not args[2] then
            args[2] = 1
        end
        if tonumber(args[2]) then
            -- Header
            header = '["",{"text":"                    ","color":"yellow","strikethrough":true}," Help (Cat: ' .. string.lower(args[1]) .. '; Page ' .. tonumber(args[2]) .. ') ",{"text":"                    ","color":"yellow","strikethrough":true}]'
            printJson(header)

            -- Make list of commands only in this category.
            local tempCmdList = {}
            for cmdk, cmdv in pairs(candler.cats[string.lower(args[1])].commands) do
                tempCmdList[cmdk] = cmdv
            end
            local tempA = {}
            for n in pairs(tempCmdList) do table.insert(tempA, n) end
            table.sort(tempA)

            -- Print out the page
            for i = (8*(tonumber(args[2])-1))+1, (8*(tonumber(args[2])-1))+8 do
                if not tempCmdList[tempA[i]] then
                    printJson('"\n"')
                    goto continue
                end

                if #combList[ba[i]].description > 50 then
                    desc = string.sub(tempCmdList[tempA[i]].description, 1, 50) .. "..."
                else
                    desc = string.sub(tempCmdList[tempA[i]].description, 1, 50)
                end
                desc = string.gsub(desc, "\\", "\\\\")
                desc = string.gsub(desc, "\"", "\\\"")
                printJson('[{"text":"\n' .. candler.prefix  .. tempA[i] .. ': ","color":"gold"},{"text":"' .. desc .. '","color":"white"}]')
                ::continue::
            end
        else
            if not candler.cats[string.lower(args[1])].commands[string.lower(args[2])] then
                printJson('[{"text":"ERROR!", "color":"red", "bold":true}, {"text":" This command does not exist. Maybe check for typos?", "color":"gray", "bold":false}]')
                return nil
            end
            header = '["",{"text":"                    ","color":"yellow","strikethrough":true}," Help (' .. candler.prefix .. string.lower(args[2]) .. ') ",{"text":"                    ","color":"yellow","strikethrough":true}]'
            printJson(header)
    
            -- Print description.
            desc = string.gsub(candler.cats[string.lower(args[1])].commands[string.lower(args[2])].description, "\\", "\\\\")
            desc = string.gsub(desc, "\"", "\\\"")
            printJson('[{"text":"\n' .. desc .. '","color":"white"}]')
    
            -- Generate and Print Aliases
            local idx = 0
            local aliases = "["
            for _, alias in pairs(candler.cats[string.lower(args[1])].commands[string.lower(args[2])].aliases) do
                idx = idx + 1
                if idx == 1 then
                    aliases = aliases .. '{"text":"' .. alias .. '","color":"white"}'
                else
                    aliases = aliases .. ',{"text":", ","color":"gray"},{"text":"' .. alias .. '","color":"white"}'
                end
            end
            aliases = aliases .. "]"
            printJson('{"text":"\nAliases (' .. idx .. '): ","color":"gold"}')
            printJson(aliases)
    
            -- Generate and Print Usage
            printJson('{"text":"\nUsage: ' .. candler.prefix .. string.lower(args[2]) ..' ","color":"gray"}')
    
            for _, v in pairs(candler.cats[string.lower(args[1])].commands[string.lower(args[2])].arguments) do
                if v.required then
                    printJson('{"text":"<' .. v.name .. '> ", "color":"aqua"}')
                else
                    printJson('{"text":"[' .. v.name .. '] ", "color":"dark_aqua"}')
                end
            end
    
            -- Generate and print argument information
            if not (candler.cats[string.lower(args[1])].commands[string.lower(args[2])].arguments == {}) then
                printJson('{"text":"\n\nArguments:","color":"gray"}')
                local count = 0
                for _, v in pairs(candler.cats[string.lower(args[1])].commands[string.lower(args[2])].arguments) do
                    count = count + 1
                    if v.required then
                        printJson('[{"text":"\n- ","color":"dark_gray"},{"text":"<' .. v.name .. '>", "color":"aqua"}]')
                    else
                        printJson('[{"text":"\n- ","color":"dark_gray"},{"text":"[' .. v.name .. ']", "color":"dark_aqua"}]')
                    end
                    if v.default then
                        printJson('{"text":" (default: ' .. tostring(v.default) .. ')","color":"gray"}')
                    end
                    printJson('[{"text":": ","color":"gray"},{"text":"' .. v.description .. '","color":"white"}]')
                end
                if count == 0 then
                    printJson('{"text":"\nNo arguments provided in command information."}')
                end
            end
        end
    else
        if not commandList[string.lower(args[1])] then
            printJson('[{"text":"ERROR!", "color":"red", "bold":true}, {"text":" This command does not exist. Maybe check for typos?", "color":"gray", "bold":false}]')
            return nil
        end
        header = '["",{"text":"                    ","color":"yellow","strikethrough":true}," Help (' .. candler.prefix .. string.lower(args[1]) .. ') ",{"text":"                    ","color":"yellow","strikethrough":true}]'
        printJson(header)

        -- Print description.
        desc = string.gsub(commandList[string.lower(args[1])].description, "\\", "\\\\")
        desc = string.gsub(desc, "\"", "\\\"")
        printJson('[{"text":"\n' .. desc .. '","color":"white"}]')

        -- Generate and Print Aliases
        local idx = 0
        local aliases = "["
        for _, alias in pairs(commandList[string.lower(args[1])].aliases) do
            idx = idx + 1
            if idx == 1 then
                aliases = aliases .. '{"text":"' .. alias .. '","color":"white"}'
            else
                aliases = aliases .. ',{"text":", ","color":"gray"},{"text":"' .. alias .. '","color":"white"}'
            end
        end
        aliases = aliases .. "]"
        printJson('{"text":"\nAliases (' .. idx .. '): ","color":"gold"}')
        printJson(aliases)

        -- Generate and Print Usage
        printJson('{"text":"\nUsage: ' .. candler.prefix .. string.lower(args[1]) ..' ","color":"gray"}')

        for _, v in pairs(commandList[string.lower(args[1])].arguments) do
            if v.required then
                printJson('{"text":"<' .. v.name .. '> ", "color":"aqua"}')
            else
                printJson('{"text":"[' .. v.name .. '] ", "color":"dark_aqua"}')
            end
        end

        -- Generate and print argument information
        if not (commandList[string.lower(args[1])].arguments == {}) then
            printJson('{"text":"\n\nArguments:","color":"gray"}')
            local count = 0
            for _, v in pairs(commandList[string.lower(args[1])].arguments) do
                count = count + 1
                if v.required then
                    printJson('[{"text":"\n- ","color":"dark_gray"},{"text":"<' .. v.name .. '>", "color":"aqua"}]')
                else
                    printJson('[{"text":"\n- ","color":"dark_gray"},{"text":"[' .. v.name .. ']", "color":"dark_aqua"}]')
                end
                if v.default then
                    printJson('{"text":" (default: ' .. tostring(v.default) .. ')","color":"gray"}')
                end
                printJson('[{"text":": ","color":"gray"},{"text":"' .. v.description .. '","color":"white"}]')
            end
            if count == 0 then
                printJson('{"text":"\nNo arguments provided in command information."}')
            end
        end

    end
    -- Jank code to determine length of footer with bold and unbold spaces. It works for me... somehow.
    -- So, turns out, it *did not* work for me, both cases I was testing it in just didn't use the bottom code.
    local headerWidth = client:getTextWidth(header)
    local spaces = ""
    local footer
    while true do
        spaces = spaces .. " "
        footer = '[{"text":"' .. spaces .. '","color":"yellow","strikethrough":true}]'
        if client:getTextWidth(footer) >= headerWidth then
            break
        end
    end

    if client:getTextWidth(footer) > headerWidth then

    end

    printJson('"\n"', footer)
end)