# Candler - The Figura Command Interpreter

Candler is a modular command interpreter for the Figura mod for Minecraft.

## Adding Candler to your Avatar

Just drop the `Candler/` folder in your avatar folder and Candler should automatically start with your avatar. If your avatar uses an Autostart, make sure to add Candler and all command scripts you intend to use to it.

## Adding the Library to your script

Just `require()` Candler from the correct location. For instance,

```lua
candler = require("Candler.candler")
```

should allow you to access Candler's API from the keyword `candler` (if you put the Candler folder directly in your avatar's folder).

## Registering a Cat

Cats (short for categories) are what hold your commands. You cannot register a command without at least one cat. To register a cat, use `.newCategory()`. `newCategory` takes two arguments: `name` (string), the name of your cat (which will be lowercased as soon as it is registered), and `information` (table), additional metadata about your cat. `newCategory`, when filled out completely, should look something like...

```lua
candler.newCategory("nameOfCat", {
    description = "Description of Cat",
    author = "Author of Cat",
    version = "1.0",
    website = "https://cat.site",
    issues = "https://cat.site/issues"
})
```

All of this information can be found with the `.ver [category]` command, and your category's name will be shown in `.help` and `.cat`.

## Registering a Command

Commands actually do things and can be called from the chat with the prefix (typically `.`). To register a command, use `.setCommand`. `setCommand` takes four arguments: `cat` (string), the name of the cat to put this command under, `name` (string), the name of the command and the main alias, `information` (table), additional metadata about your command, and `funct` (function), the function to call when your command is called. `setCommand`, when filled out completely, should look something like...

```lua
candler.newCategory("nameOfCat", "command", {
    aliases = {"cmd", "mycommand"},
    description = "A \"Hello, World!\" command!",
    arguments = {}
}, function()
    print("Hello, world!")
end)
```

All of this information can be found with the `.help [command]`/`.help [category] [command]` command, and your command's name will be shown in `.help` or `.help [category]`.

Using `setCommand` after the command has been registered will change the command's metadata and function.

## Removing a Command or Cat

To remove a cat or command, you can use the functions `.removeCategory()` and `.removeCommand()` respectively.

`removeCategory` takes one argument: `cat` (string), the name of the category to remove. Removing a category completely deletes the commands within. However, it can most likely be re-registered intact with a simple reload.

Same goes for `removeCommand`, but it takes two arguments instead: `cat` (string), the category in which the command to remove is in, and `command` (string), the name of the command to remove.