-- BetterRequire Compat
modName = "slyme.patpat"

local patpat = {}
-- Configuration ------------------------------------------
patpat.config = {
    -- Default particle used when the patted doesn't handle particles.
    defaultParticle = {
        particleType = "minecraft:heart",
        every = 3 -- ticks
    },
    requireOffhand = false, -- Should patpat require an empty offhand?
    holdFor = 4, -- ticks, Keeps "petting" target after how many ticks of not petting. used to pet multiple entities.
    blocks = {
        "minecraft:player_head", "minecraft:player_wall_head"
    }
}

-- Opts you into pats. Setting this to false will also protect you from scripts that respect "patpat.noPats"
-- avatar:store("patpat.yesPats", true)

-- Opts you out of pats in older versions of Patpat and in scripts that use an opt-out system.
-- avatar:store("patpat.noPats", true)

-- Opts you out of the patter's particles.
-- avatar:store("patpat.noHearts", true)

patpat.functions = {

    -- runs whenever you're patted or no longer patted. included to maintain compatability.
    togglePat = {
        default = function (beingPetted) -- beingPetted = whether you are being patted or not. named beingPetted to keep backwards compat.
            -- print("togglePat", beingPetted)
        end
    },

    -- runs whenever you're patted
    onPat = {
        default = function ()
            -- print("onPat")
        end
    },

    -- runs whenever you're no longer patted
    onUnpat = {
        default = function ()
            -- print("onUnpat")
        end
    },

    -- runs each tick you're patted
    whilePat = {
        default = function (petters) -- petters = list of entities patting you. named petters to keep backwards compat.
            -- print("whilePat", petters)
        end
    },

    -- runs each swing of an arm of a patter
    oncePat = {
        default = function (entity) -- entity = which entity swinged their arm as a pat.
            -- print("oncePat", entity)
        end
    }

}
-- The code -----------------------------------------------
local lastPat = -1
local patting = {}
local myPatters = {}
local patted = false
local shouldShowHearts, targetInformation

-- if opt-in isn't set, set it to false.
if world.avatarVars()[avatar:getUUID()]["patpat.yesPats"] == nil then
    avatar:store("patpat.yesPats", false)
end

if world.avatarVars()[avatar:getUUID()]["patpat.yesPats"] == false then
    avatar:store("patpat.noPats", true)
end

-- utility
local function callFuncts(t, params)
    for _, v in pairs(t) do
        v(params)
    end
end

-- maintain compatibility with those who don't feel the need to upgrade.
avatar:store("petpet", function(uuid, timer)
    if player:getVariable("patpat.yesPats") then
        myPatters[uuid] = tonumber(timer)

        if not patted then
            patted = true
            callFuncts(patpat.functions.onPat)
            callFuncts(patpat.functions.togglePat, patted)
        end
    end
end)

-- checks for entities and blocks.
local function check()
    local entity = player:getTargetedEntity(host:getReachDistance())
    if entity then
        -- why do you want to pet minecarts?
        if entity:hasContainer() or entity:hasInventory() then
            return nil
        end

        -- this person asked not to be patted. stop trying.
        if entity:getVariable("patpat.noPats") == true then
            sounds["minecraft:entity.villager.no"]:pos(player:getPos()):pitch(.85)
            return nil
        end

        if entity:getVariable("petpet.yesPats") == false then
            sounds["minecraft:entity.villager.no"]:pos(player:getPos()):pitch(.85)
            return nil
        end

        -- this person doesn't even have any form of petpet or patpat. leave them alone.
        if entity:getVariable("petpet.yesPats") == nil and not entity:getVariable("petpet") then
            sounds["minecraft:entity.villager.no"]:pos(player:getPos()):pitch(.85)
            return nil
        end

        -- is nohearts on?
        shouldShowHearts = entity:getVariable("patpat.noHearts")

        return entity:getUUID()
    else
        local block = player:getTargetedBlock(true, host:getReachDistance())

        -- if they asked you not to pat them, don't pat their skull either.
        if block:getEntityData() then
            if block:getEntityData().SkullOwner then
                local uuid = client:intUUIDToString(table.unpack(block:getEntityData().SkullOwner.Id))
                if world.avatarVars()[uuid] then
                    if world.avatarVars()[uuid]["patpat.noPats"] == true then
                        sounds["minecraft:entity.villager.no"]:pos(player:getPos()):pitch(.85)
                        return nil
                    end

                    if world.avatarVars()[uuid]["patpat.yesPats"] == false then
                        sounds["minecraft:entity.villager.no"]:pos(player:getPos()):pitch(.85)
                        return nil
                    end

                    if world.avatarVars()[uuid]["patpat.yesPats"] == nil and not world.avatarVars()[uuid]["petpet"] then
                        sounds["minecraft:entity.villager.no"]:pos(player:getPos()):pitch(.85)
                        return nil
                    end

                    -- is nohearts on?
                    shouldShowHearts = world.avatarVars()[uuid]["patpat.noHearts"]
                else
                    return nil
                end
            end
        end

        -- if empty, nonexistant, or false, don't do anything
        if (not patpat.config.blocks) or patpat.config.blocks == {} then
            return nil
        -- if true, pet *every* block
        elseif patpat.config.blocks == true then
            return block:getPos()
        end

        -- if the block is in the blocks list, pet it
        for _, v in ipairs(patpat.config.blocks) do
            if block.id == v then
                return block:getPos()
            end
        end

        return nil
    end
end

-- pets a target.
function pings.patpat(target)
    -- entity
    if type(target) == "string" then
        local target = world.getEntity(target)
        if target then
            targetInformation = {
                pos = target:getPos(),
                box = target:getBoundingBox()
            }

            local funct = target:getVariable("petpet")
            if type(funct) == "function" then
                pcall(funct, avatar:getUUID(), patpat.config.holdFor * 1.5)
            end
        else
            return
        end
    -- block
    elseif type(target) == "Vector3" then
        local target = world.getBlockState(target)
        if target then
            targetInformation = {
                pos = target:getPos() + vec(0.5, 0, 0.5),
                box = vec(0.7, 0.7, 0.7)
            }
        else
            return
        end
    else
        return
    end

    -- I stole this code because I am shit at math. What the hell is she gonna do anyways?
    local box2 = targetInformation.box / 2

    targetInformation.box:applyFunc(function(val) return val * math.random() end)
    local particlePos = targetInformation.pos + targetInformation.box.xyz - box2.x_z
    
    if not shouldShowHearts then
        particles[patpat.config.defaultParticle.particleType]:scale(.75):pos(particlePos):spawn()
    end
    host:swingArm()
end

-- Register keybind
patpat.key = keybinds:fromVanilla("key.use")
    :onPress(function ()
        if player:isSneaking() and player:getHeldItem().id == "minecraft:air" and (not patpat.config.requireOffhand or player:getHeldItem(true).id == "minecraft:air") then
            local target = check()
            if target then
                pings.patpat(target)
                lastPat = world.getTime() + patpat.config.defaultParticle.every - 1
                return true
            end
        end
        return nil
    end)
    :onRelease(function ()
        lastPat = -1
    end)

events.TICK:register(function ()
    if host:isHost() and lastPat > -1 and ((lastPat - world.getTime()) % patpat.config.defaultParticle.every == 0) then
        local target = check()
        if target then
            pings.patpat(target)
        end
    end
end, "Button Hold")

events.TICK:register(function ()
    for k, v in pairs(patting) do
        v = v - 1
        if v < 0 then
            patting[k] = nil
        else
            patting[k] = v
        end
    end
end, "Maintain Patting")

events.TICK:register(function ()
    if patted then
        callFuncts(patpat.functions.whilePat, myPatters)

        patted = false
        for k, v in pairs(myPatters) do
            v = v -1
            if v > -1 then
                patted = true
                myPatters[k] = v

                local entity = world.getEntity(k)
                if entity and entity.getSwingTime and entity:getSwingTime() == 1 then
                    callFuncts(patpat.functions.oncePat, entity)
                end
            else
                myPatters[k] = nil
            end
        end

        if not patted then
            callFuncts(patpat.functions.onUnpat)
            callFuncts(patpat.functions.togglePat, false)
        end
    end
end, "Patting Functions")

-- library

local lib = {}
for k, _ in pairs(patpat.functions) do
    lib[k] = {}

    -- register patpat function
    lib[k].register = function(funct, name)
        if not type(funct) == "function" then
            error("where's my function?")
        end
        if not name then
            local idx = 0
            for _ in pairs(patpat.functions[k]) do
                idx = idx + 1
            end
            name = idx + 1
        end
        patpat.functions[k][name] = funct
    end

    lib[k].remove = function(name)
        if not patpat.functions[k][name] then
            return false
        else
            patpat.functions[k][name] = nil
            return true
        end
    end

    lib[k].list = function()
        return patpat.functions[k]
    end
end
return lib