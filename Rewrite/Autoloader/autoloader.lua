--[[
 ___ _ _ ___ ___ _   ___ ___ ___ ___ ___
| . | | |_ _| . | |_| . | . | . \ ._| ._|
|_,_|___||_||___|___|___|_,_|___/___|_,_|
                      v1.1 - By Slymeball
AutoScripts Automation (+ loadtime libs!)

Basic Usage
===============
1. Add the following to your avatar.json's structure:
`"autoScripts": ["<path.to.autoloader>"]`
(make sure to replace `<path.to.autoloader>` with Autoloader's path within your avatar)

2. (OPTIONAL) Create your script order. Scripts that should be loaded before all others should have higher, positive priority, while scripts that should be ran last should have lower, negative priority.
For instance, a script that replaces metatables for its own use should be placed higher.
If left blank, all scripts will run at a random order.

3. (OPTIONAL) Place any scripts you don't want to run automatically AT ALL in the skipList.
Functions placed in the skipList from the start will not be ran by Autoloader at all. Other scripts must require/dofile it if they wish for it to run.

Using Loadtime Libraries
===============
With Autoloader's loadtime libraries, you can register hooks and searchers 

Hooks
===============
Hooks are requests made to Autoloader to watch for global variables being changed. If a global variable with the name specified in the hook is changed, Autoloader will log it and report it back to the script when loading is finished.
This is typically used for parts of a larger script to make themselves known to the main part of the script.

`autoloader.newHook(gv, callback)`

Creates a new hook that searches for string `gv`. When Autoloader is finished loading scripts, `callback` will be run with each found script's hook content and path as one parameter.

Searchers
===============
Hooks are requests made to Autoloader to look for strings within script paths. If a path is found, Autoloader will log it and report it back to the script when loading is finished.

`autoloader.newSearcher(path, callback, usePattern)`

Creates a new searcher that searches for string `path`. When Autoloader is finished loading scripts, `callback` will be run with each found path as one parameter. If `usePattern` is true, `path` will be interpreted as a pattern.
--]]

-- CONFIGURATION =============================

local scriptOrder = {
}

local skipList = {
}

-- SCRIPTING HOURS ===========================

local scr_pp, scr_name = ...
local scr_fp = (scr_pp ~= "" and scr_pp .. "." or "") .. scr_name

local hooks = {}
local searchers = {}

local scriptStartedCount = 0

local function checkRequire(name)
    if name == scr_fp then return end

    for _, v in pairs(searchers) do
        if string.find(name, v.pattern, nil, not v.usePattern) then
            v.results[#v.results+1] = name
        end
    end

    for _, v in pairs(hooks) do
        _G[v.pattern] = nil
    end

    scriptStartedCount = scriptStartedCount + 1
    require(name)

    for _, v in pairs(hooks) do
        if _G[v.pattern] ~= nil then
            v.results[#v.results+1] = {
                path = name,
                data = _G[v.pattern]
            }
        end
    end
end

-- Libraries

local lib = {}

-- Registers a new hook.
---@param gv string Global variable name
---@param callback function Callback function
function lib.newHook(gv, callback)
    hooks[#hooks+1] = {
        pattern = gv,
        callback = callback,
        results = {}
    }

    return true
end

-- Registers a new hook.
---@param path string Path substring
---@param callback function Callback function
---@param usePattern boolean? True = Use Lua patterns instead of plaintext.
function lib.newSearcher(path, callback, usePattern)
    searchers[#searchers+1] = {
        pattern = path,
        callback = callback,
        usePattern = usePattern,
        results = {}
    }

    return true
end

autoloader = lib

-- The Actual Require Thing

local function startRequiring()
    if startTime then return end
    startTime = client:getSystemTime()

    for idx, v in pairs(scriptOrder) do
        if idx > 0 then
            if type(v) == "string" then
                checkRequire(v)
                skipList[v] = true
            elseif type(v) == "table" then
                for _, script in pairs(v) do
                    checkRequire(script)
                    skipList[script] = true
                end
            end
            scriptOrder[idx] = nil
        elseif idx < 0 then
            if type(v) == "string" then
                skipList[v] = true
            elseif type(v) == "table" then
                for _, script in pairs(v) do
                    skipList[script] = true
                end
            end
        end
    end
    
    for idx, v in pairs(listFiles(nil, true)) do
        if not skipList[v] then checkRequire(v) end
    end
    
    for _, v in pairs(scriptOrder) do
        if type(v) == "string" then
            checkRequire(v)
            skipList[v] = true
        elseif type(v) == "table" then
            for _, script in pairs(v) do
                checkRequire(script)
                skipList[script] = true
            end
        end
    end

    endTime = client:getSystemTime()
    if host:isHost() then
        host:setActionbar('{"text":"","extra":[{"text":"AUTOLOADER","color":"#6ca4f7","bold":true},{"text":" • ","color":"dark_gray"},{"text":"Loaded ' .. tostring(scriptStartedCount) .. ' scripts in ' .. tostring(endTime - startTime) .. ' ms.","color":"white"}]}')
    end
end

startRequiring()

for _, v in pairs(hooks) do
    v.callback(table.unpack(v.results))
end

for _, v in pairs(searchers) do
    v.callback(table.unpack(v.results))
end

autoloader = nil
