
local function round(number, decimals)
    local power = 10^decimals
    return math.floor(number * power) / power
end
if not host:isHost() then return end
local zoom = {}

-- DEFAULTS
zoom.defaults = {
    keybind = "key.keyboard.z",
    zoomFOV = .4,
    spyglassSounds = 1,
    minimumZoom = 1, -- in form of 1/x
    maximumZoom = 20, -- in form of 1/x
    scrolling = 1,
    scrollHint = 1,
    sensitivityMultiplier = .15
}

zoom.config = config:load("zoom")

if not zoom.config then
    config:save("zoom", {})
    zoom.config = config:load("zoom")
end

---Saves a value to the zoom config and saves the config table to the avatar's config file as "zoom"
---@param k Key
---@param v Value
local function saveToConfig(k, v)
    zoom.config[k] = v
    config:save("zoom", zoom.config)
end

for k, v in pairs(zoom.defaults) do
    if not zoom.config[k] then
        saveToConfig(k, v)
    end
end

local defaultSensitivity
local function setZoom(num)
    renderer:setFOV(num)
    if renderer.getSensitivity then
        if (not num) and (defaultSensitivity) then
            renderer:setSensitivity(defaultSensitivity)
            defaultSensitivity = nil
        else
            if not defaultSensitivity then
                defaultSensitivity = renderer:getSensitivity()
            end
            renderer:setSensitivity(defaultSensitivity + (zoom.config.sensitivityMultiplier * (renderer:getFOV() - 1)))
        end
    end
end

zoom.keybind = keybinds:newKeybind('§a§lOk Sloomer §8- §7Zoom', zoom.config.keybind, false)

function zoom.keybind.press()
    setZoom(zoom.config.zoomFOV)
    if zoom.config.spyglassSounds >= 1 then sounds["minecraft:item.spyglass.use"]:setPos(player:getPos()):setVolume(.35):play() end
end

function zoom.keybind.release()
    setZoom(nil)
    if zoom.config.spyglassSounds >= 1 then sounds["minecraft:item.spyglass.stop_using"]:setPos(player:getPos()):setVolume(.35):play() end
end

events.TICK:register(function()
    if zoom.keybind:getKey() ~= zoom.config.keybind then
        saveToConfig("keybind", zoom.keybind:getKey())
    end
end, "Keybind Change Listener")

events.MOUSE_SCROLL:register(function(dir)
    if zoom.keybind:isPressed() and zoom.config.scrolling >= 1 then
        setZoom(math.clamp(renderer:getFOV() + (dir * -.25 * renderer:getFOV()), 1/zoom.config.maximumZoom, 1/zoom.config.minimumZoom))
        -- print(1/renderer:getFOV())
        if zoom.config.spyglassSounds >= 1 then sounds["minecraft:entity.chicken.step"]:setPitch(2):setSubtitle("Spyglass zooms"):setVolume(99):setPos(player:getPos()):play() end
        if zoom.config.scrollHint >= 1 then host:setActionbar('[{"text":"Zoom Level:","color":"aqua","bold":true},{"text":" x' .. round(1 / renderer:getFOV(), 2) .. '","color":"white","bold":false}]') end
        return true
    end
end)

-- ========== CANDLER ========== --
events.TICK:register(function ()
    -- print("Searching for candler...")
    if candler then
        -- print("Found Candler!")
        local c = candler.lib
        c.newCategory("OkSloomer", {
            description = "Candler integration for Ok Sloomer, used for configuring zoom options.",
            version = "0.1.1",
            author = "Slymeball"
        })
        c.setCommand("oksloomer", "zoom", {
            description = "Set a configuration option for Ok Sloomer or print the config.",
            aliases = {"oksloomer"},
            arguments = {
                {
                    name = "key",
                    description = "The option to change. If left blank, the config will be printed out.",
                    required = false
                },
                {
                    name = "value",
                    description = "The value to change it to.",
                    required = false
                }
            }
        }, function (args)
            if not args[1] then
                printTable(zoom.config)
                return
            end
            if not zoom.config[args[1]] then
                printJson('[{"text":"ERROR!", "color":"red", "bold":true}, {"text":" This config option does not exist! Maybe check for typos?", "color":"gray", "bold":false}]')
                return
            end
            -- if true then
            print(type(zoom.config[args[1]]))
            if type(zoom.config[args[1]]) == "number" then
                if not tonumber(args[2]) then
                    printJson('[{"text":"ERROR!", "color":"red", "bold":true}, {"text":" Incorrect type! This is a ' .. type(zoom.config[args[1]]) .. '!", "color":"gray", "bold":false}]')
                    return
                end
                args[2] = tonumber(args[2])
            end
            saveToConfig(args[1], args[2])
            printJson('[{"text":"", "color":"gray"},{"text":"✔", "color":"green"}," Set config ",{"text":"' .. args[1] .. '","color":"green"}," to ",{"text":"' .. tostring(args[2]) .. '","color":"green"},"."]')
        end)
        events.TICK:remove("Candler Integration")
        -- return true
    end
end, "Candler Integration")
