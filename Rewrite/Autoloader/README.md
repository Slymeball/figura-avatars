<!--<p align="center"><img src="https://github.com/Slymeball/figura-avatars/blob/main/Icons/patpat%20icon.png?raw=true" width=25%></p>-->
<h1 align="center">Autoloader - Use `autoScripts` with ease!</h1>

Autoloader is a script that requires all of your scripts based on their priority. By default, every script has a priority of zero, however this can be overridden with the `scriptOrder` table in `autoloader.lua`. For example, an avatar with the scripts...

```
├ autoloader.lua
├ script_a.lua
├ script_b.lua
├ folder_1
│ ├ script_1a.lua
│ └ script_1b.lua
└ folder_2
  ├ important_libray.lua
  └ other_library.lua
```

...and the `scriptOrder`...

```lua
scriptOrder = {
    [99] = "folder_2.important_library",
    [50] = "folder_2.other_library",
    [1] = {
        "folder_1.script_1a",
        "folder_1.script_1b"
    },
    [-1] = "script_b"
}
```

...would load scripts in the order...

- `folder_2.important_library`
- `folder_2.other_library`
- `folder_1.script_1a` / `folder_1.script_1b`
- `script_a`
- `script_b`

# Usage

1. Put the latest `autoloader.lua` (see pins) in your avatar's files
2. Add `"autoScripts": ["autoloader"]` to your `avatar.json` file.
3. (Optional, but like, why not do this?) Prioritize your scripts

# Why?

Well, if you're anything like me, you have a shit ton of scripts just sitting in your avatar and just a few need prioritization over the others. Instead of specifying every little script in the `autoScripts` tag in `avatar.json`, I feel this is just a better solution.
