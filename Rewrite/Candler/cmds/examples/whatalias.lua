require("Candler.cmds.examples.register")

require("Candler.candler").setCommand("Examples", "alias", {
    command = "alias", -- The main command that should be shown on help pages.
    aliases = {"what", "command", "was", "used"}, -- Every other command that should lead to this file.
    description = "Repeats what alias was used.", -- A description of the command.
    arguments = {}
}, function (_, alias)
    print("Alias used: " .. alias)
end)