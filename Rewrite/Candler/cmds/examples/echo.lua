require("Candler.cmds.examples.register")

require("Candler.candler").setCommand("Examples", "echo", {
    command = "echo", -- The main command that should be shown on help pages.
    aliases = {}, -- Every other command that should lead to this file.
    description = "Repeats what's passed as an argument in order.", -- A description of the command.
    arguments = {
        {
            name = "message", -- The name of the argument.
            description = "The message to repeat back to the player.",
            required = true, -- Does not actually do anything, just shows the argument as <arg> in help menus. If not required, it is displayed as [arg].
        }
    }
}, function (args) -- Candler passes a list of arguments to each command. It does not inclue the prefix OR alias used. The alias used is passed in the next variable.
    if not requireArgs({1}, args) then return end
    -- print("test")

    local printedMessage = table.remove(args, 1)
    for _, v in pairs(args) do
        printedMessage = printedMessage .. " " .. v
    end
    print(printedMessage)
end)