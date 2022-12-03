--[[
    ___ _   _ _ _ _ ___ ___ ___ _   _
   |_ -| |_|_'_| v | -_| ._| . | |_| |_
   |___|___||_||_v_|___|_-_|_,_|___|___|
-- ================================================= --
   AFK Checker: Rewritten                     | v2.1

   A rewrite of my old AFK script, now with less
   hard-coding! Just require this script into
   another and use the function returned.
--]]

afkDelay = 15*20

-- DO NOT MODIFY
afkTime = 0

events.ENTITY_INIT:register(function()
    pos = user:getPos()
    rot = user:getRot()
end)

events.TICK:register(function()
    oldPos = pos
    oldRot = rot
    pos = user:getPos()
    rot = user:getRot()

    if pos == oldPos and rot == oldRot then afkTime = afkTime + 1 else afkTime = 0 end
end)

return function()
    if afkTime >= afkDelay then
        return afkTime
    else
        return nil
    end
end