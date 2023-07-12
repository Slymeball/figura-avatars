require("Candler.candler").setCommand("Candler", "version", {
    aliases = {"ver"},
    description = "Shows information and version of Candler and categories.",
    arguments = {
        {
            name = "category",
            description = "The category to get information on.",
            required = false,
            default = "Candler"
        }
    }
}, function(args)
    if not args[1] then
        args[1] = "Candler"
    end
    args[1] = string.lower(args[1])
    if not candler.cats[args[1]] then
        printJson('[{"text":"ERROR!", "color":"red", "bold":true}, {"text":" This category does not exist. Type \\\"' .. candler.prefix .. 'cats\\\" for a list of categories.", "color":"gray", "bold":false}]')
    else
        printJson('[{"text":"' .. args[1] .. '","color":"green"}]')
        if candler.cats[args[1]].version then
            printJson('[{"text":" version ","color":"white"},{"text":"' .. candler.cats[args[1]].version .. '","color":"green"}]')
        end
        if candler.cats[args[1]].description then
            printJson('"\n' .. candler.cats[args[1]].description .. '"')
        end
        if candler.cats[args[1]].website then
            printJson('["\nWebsite: ", {"text":"' .. candler.cats[args[1]].website .. '","color":"green","clickEvent":{"action":"open_url","value":"' .. candler.cats[args[1]].website .. '"},"hoverEvent":{"action":"show_text","contents":[{"text":"Open ","color":"white"},{"text":"' .. candler.cats[args[1]].website .. '","color":"green"},{"text":" in your web browser.","color":"white"}]}}]')
        end
        if candler.cats[args[1]].issues then
            printJson('["\nIssues: ", {"text":"' .. candler.cats[args[1]].issues .. '","color":"green","clickEvent":{"action":"open_url","value":"' .. candler.cats[args[1]].issues .. '"},"hoverEvent":{"action":"show_text","contents":[{"text":"Open ","color":"white"},{"text":"' .. candler.cats[args[1]].issues .. '","color":"green"},{"text":" in your web browser.","color":"white"}]}}]')
        end
        if candler.cats[args[1]].author then
            printJson('["\nAuthor: ", {"text":"' .. candler.cats[args[1]].author ..'","color":"green"}]')
        end
    end
end)