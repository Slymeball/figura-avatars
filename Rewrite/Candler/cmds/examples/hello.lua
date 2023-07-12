require("Candler.cmds.examples.register")

require("Candler.candler").setCommand("Examples", "hello", {
    command = "hello", -- The main command that should be shown on help pages.
    aliases = {"greetings", "hi", "hey"}, -- Every other command that should lead to this file.
    description = "A command that greets you with a \"hello!\"", -- A description of the command.
    arguments = {
        {
            name = "name", -- The name of the argument.
            description = "The name of the person to greet.", -- A description of the argument.
            required = false, -- Does not actually do anything, just shows the argument as <arg> in help menus. If not required, it is displayed as [arg].
            default = avatar:getEntityName(), -- The default value.
        }
    }
}, function (arg)
    if not arg[1] then arg[1] = avatar:getEntityName() end
    print("Hello, " .. arg[1] .. "!")
end)