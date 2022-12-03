--[[
    ___ _   _ _ _ _ ___ ___ ___ _   _
   |_ -| |_|_'_| v | ._| ._| . | |_| |_
   |___|___||_||_v_|___|_'_|_,_|___|___|
-- ================================================= --
   AFK Checker: Animations                    | v1.1

   Plays an animation when you go AFK. Make sure to
   change the anims before use!
--]]

anims = {
    start = animations.YOUR.ANIMATION_HERE,
    loop = animations.YOUR.ANIMATION_HERE,
    fin = animations.YOUR.ANIMATION_HERE
}

getAFK = require("Slyme_AFK")

initTicks = 0

events.TICK:register(function()
    initTicks = initTicks + 1
    if getAFK() then
        if not oldAFK then
            startAnim = initTicks
            loopAnim = initTicks + (anims.start:getLength() * 20)
        end

        if initTicks == startAnim then
            anims.fin:stop()
            anims.start:play()
        elseif initTicks == loopAnim then
            anims.start:stop()
            anims.loop:play()
        end
    else
        if oldAFK then
            anims.start:stop()
            anims.loop:stop()
            anims.fin:play()
        end
    end
    oldAFK = getAFK()
end)

return function(s, l, f)
    if s then anims.start = s end
    if l then anims.loop = l end
    if f then anims.fin = f end
end