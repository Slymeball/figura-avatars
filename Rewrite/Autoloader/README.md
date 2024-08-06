<p align="center"><img src="https://github.com/Slymeball/figura-avatars/blob/main/Icons/autoloader%20icon.png?raw=true" width=25%></p>
<h1 align="center">Autoloader - Use `autoScripts` with ease! (+ some other loadtime libraries)</h1>

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

# Basic Usage

1. Put the latest `autoloader.lua` ([click here](https://github.com/Slymeball/figura-avatars/blob/main/Rewrite/Autoloader/autoloader.lua)) in your avatar's files
2. Add `"autoScripts": ["autoloader"]` to your `avatar.json` file.
3. (Optional, but like, why not do this?) Prioritize your scripts

# Why?

Well, if you're anything like me, you have a shit ton of scripts just sitting in your avatar and just a few need prioritization over the others. Instead of specifying every little script in the `autoScripts` tag in `avatar.json`, I feel this is just a better solution.

# Libraries

Autoloader offers a few APIs under the `autoloader` global variable during loadtime. These can be used to look for scripts that do certain things or have certain details.

(if you're wondering why it's under a global variable and not a require, i *can't* do a require. circular dependencies is a real thing smh)

# Hooks

Hooks allow scripts to watch a global variable for changes during the loadtime process. If a script changes a global variable it is watching when it's started, its path and the variable's data will be logged and sent back to the original script after loadtime for its use.

This is useful in cases where a module of a script would want to make itself known regardless of where the main script is. It can just set a global variable and, if the main script is watching it, the main script will know information about that module.

Just use `autoloader.newHook(gv, callback)` to make a new hook. See more details within `autoloader.lua`.

# Searchers

Searchers allow scripts to look for scripts with a substring in their path. When one is found, its path will be logged and sent back to the original script after loadtime for its use.

Just use `autoloader.newSearcher(path, callback, usePattern)` to make a new searcher. See more details within `autoloader.lua`.
