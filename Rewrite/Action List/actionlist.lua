if not host:isHost() then return end

-- Icon Support
-- TODO: If :getIcon(), :getHoverIcon(), and :getToggleIcon(), are added, use that instead. Why didn't they exist before???
actionItems = {
    normal = {},
    hover = {},
    toggle = {}
}

local old_index_Action = figuraMetatables.Action.__index
function figuraMetatables.Action.__index(self, key)
    if key == "item" or key == "setItem" then
        return setItem
    elseif key == "hoverItem" or key == "setHoverItem" then
        return setHoverItem
    elseif key == "toggleItem" or key == "setToggleItem" then
        return setToggleItem
    else
        return old_index_Action(self, key)
    end
end

function setItem(action, item)
    local newItem
    if type(item) == "string" then
        newItem = world.newItem(item)
    else
        newItem = item
    end

    if type(newItem) ~= "ItemStack" then
        if type(item) == "string" then
            error("Could not parse item stack from string: " .. tostring(item))
        else
            error("Invalid argument to item(): " .. tostring(item))
        end
    end
    actionItems.normal[action] = item
    old_index_Action(action, "item")(action, item)
    return action
end

function setHoverItem(action, item)
    local newItem
    if type(item) == "string" then
        newItem = world.newItem(item)
    else
        newItem = item
    end

    if type(newItem) ~= "ItemStack" then
        if type(item) == "string" then
            error("Could not parse item stack from string: " .. tostring(item))
        else
            error("Invalid argument to item(): " .. tostring(item))
        end
    end
    actionItems.hover[action] = item
    old_index_Action(action, "hoverItem")(action, item)
    return action
end

function setToggleItem(action, item)
    local newItem
    if type(item) == "string" then
        newItem = world.newItem(item)
    else
        newItem = item
    end

    if type(newItem) ~= "ItemStack" then
        if type(item) == "string" then
            error("Could not parse item stack from string: " .. tostring(item))
        else
            error("Invalid argument to item(): " .. tostring(item))
        end
    end
    actionItems.toggle[action] = item
    old_index_Action(action, "toggleItem")(action, item)
    return action
end

-- Page Detection
local pageLastHover = {}
local hoveredAction = 1
local old_index_ActionWheelAPI = figuraMetatables.ActionWheelAPI.__index

function figuraMetatables.ActionWheelAPI.__index(self, key)
    if key == "setPage" then
        return function(self, page)
            if action_wheel:getCurrentPage() then
                pageLastHover[action_wheel:getCurrentPage()] = hoveredAction
            end
            if pageLastHover[page] then
                hoveredAction = pageLastHover[page]
            else
                hoveredAction = 1
            end
            old_index_ActionWheelAPI(self, "setPage")(self, page)
            return self
        end
    end
    return old_index_ActionWheelAPI(self, key)
end

-- Set variables.
local wheelData = {}
local path = table.pack(...)[1]
local keyHeld = false
local actionBeingScrolled = false
local currentPage

local guiPart = models[path].GUI.GUI
local iconsTexture = textures[path .. ".GUI.texture"]
guiPart:setVisible(false)

-- Compile the current page's actions as a table with...
--   - Original Action,
--   - Title (first line of title)
--   - Description (all other lines of title)
--   - Function Indicators (icons)
--   - Item
local function reloadWheel()
    if not action_wheel:getCurrentPage() then return end
    wheelData = {}
    local actions = action_wheel:getCurrentPage():getActions()
    for idx, v in pairs(actions) do
        wheelData[idx] = {}
        wheelData[idx].action = v

        local title = ""
        if v:isToggled() and v:getToggleTitle() then
            title = v:getToggleTitle()
        else
            if v:getTitle() then
                title = v:getTitle()
            end
        end

        if string.find(title, '"\n",') then
            wheelData[idx].title = string.sub(title, 1, string.find(title, '"\n",')-1) .. '""]'
            wheelData[idx].description = '["' .. string.sub(title, string.find(title, '"\n",')+2, -1)
        else
            wheelData[idx].title = title
            wheelData[idx].description = '""'
        end

        wheelData[idx].icons = {}
        for aidx, av in pairs({"leftClick", "rightClick"}) do
            if v[av] then
                wheelData[idx].icons[aidx-1] = true
            -- else
            --     wheelData[idx].icons[aidx-1] = false
            end
        end

        if v.toggle and v:isToggled() then
            wheelData[idx].icons[3] = true
        end

        if v.toggle and not v:isToggled() then
            wheelData[idx].icons[4] = true
        end

        if v.scroll then
            wheelData[idx].icons[2] = true
        end

        if actionItems.normal[v] then
            wheelData[idx].item = actionItems.normal[v]
        else
            wheelData[idx].item = world.newItem("minecraft:yellow_concrete")
        end

        wheelData[idx].color = vec(0,0,0,.5)

        if v:getColor() then
            wheelData[idx].color = vec(v:getColor()[1],v:getColor()[2],v:getColor()[3],.5)
        end

        if v:isToggled() then
            if actionItems.toggle[v] then
                wheelData[idx].item = actionItems.toggle[v]
            end
            if v:getToggleColor() then
                wheelData[idx].color = vec(v:getToggleColor()[1],v:getToggleColor()[2],v:getToggleColor()[3],.5)
            else
                wheelData[idx].color = vec(0,.5,0,.5)
            end
        end

        if idx == hoveredAction then
            if actionItems.hover[v] then
                wheelData[idx].item = actionItems.hover[v]
            end
            if v:getHoverColor() then
                wheelData[idx].color = vec(v:getHoverColor()[1],v:getHoverColor()[2],v:getHoverColor()[3],.5)
            end
        end
    end
end

guiPart:setPos(vec(((client:getScaledWindowSize()[1]/2)-(400/2))*-1, ((client:getScaledWindowSize()[2]/2)-(100/2))*-1, 0))

-- Render the list.
local function renderWheel()
    guiPart:setPos(vec(((client:getScaledWindowSize()[1]/2)-(400/2))*-1, ((client:getScaledWindowSize()[2]/2)-(100/2))*-1, 0))
    guiPart:removeTask()
    for idx, v in pairs(guiPart:getChildren()) do
        if v:getName() ~= "ListItem_nil" then
            guiPart:removeChild(v)
        end
    end
    local backgroundTexture = textures:newTexture("actionlist.background", 1, 1):fill(0,0,1,1,vec(0,0,0,.5))
    if #wheelData <= 0 then
        return
    end
    backgroundTexture = backgroundTexture:fill(0,0,1,1,wheelData[hoveredAction].color)
    guiPart:newSprite("actionlist.background"):setTexture(backgroundTexture):setScale(vec(400,100,1))
    local idx = 0
    for _, v in pairs(wheelData) do
        idx = idx + 1
        local diff = idx - hoveredAction
        v.part = nil
        v.part = guiPart.ListItem_nil:copy("ListItem_" .. tostring(idx)):setPos(vec(-20, -20, 0))
        if diff == 0 then
            v.part:newItem("actionList.icon." .. tostring(idx)):setItem(wheelData[idx].item):setScale(vec((1/16)*60,(1/16)*60,1)):setPos(vec(-30,-30,0))
            v.part:newText("actionList.title." .. tostring(idx)):setText(v.title):setPos(vec(-70,0,0)):setScale(vec(2,2,1)):setShadow(true):setWidth(400-50)
            v.part:newText("actionList.description." .. tostring(idx)):setText(v.description):setPos(vec(-70,-9*2,0)):setScale(vec(1,1,1)):setShadow(true):setWidth(400-110)

            local renderedIcons = -1
            for aidx, iv in pairs(v.icons) do
                if iv then
                    renderedIcons = renderedIcons + 1
                    v.part:newSprite("actionList.ficon." .. tostring(idx) .. tostring(aidx)):setTexture(iconsTexture):setPos(vec(renderedIcons*-8, -65, -.5)):region(vec(8,8)):setUV(vec((aidx*8)/48,0)):setScale(vec(1/6,1,1))
                    v.part:newSprite("actionList.ficon." .. tostring(idx) .. tostring(aidx) .. ".shadow"):setTexture(iconsTexture):setPos(vec((renderedIcons*-8)-1, -66, -.49)):region(vec(8,8)):setUV(vec((aidx*8)/48,0)):setScale(vec(1/6,1,1)):setColor(vec(.25, .25, .25, 1))
                -- else
                --     v.part:newSprite("actionList.ficon." .. tostring(idx) .. tostring(aidx)):setTexture(iconsTexture):setPos(vec(renderedIcons*-8, -65, -.5)):region(vec(8,8)):setUV(vec((5*8)/48,0)):setScale(vec(1/6,1,1))
                end
            end
        else
            if diff < 0 then
                v.part:setPos(vec(-20, -50*diff, 0))
            else
                v.part:setPos(vec(-20, -70+(-50*diff), 0))
            end
            v.part:newItem("actionList.icon." .. tostring(idx)):setItem(wheelData[idx].item):setScale(vec((1/16)*30,(1/16)*30,1)):setPos(vec(-45,-15,0))
            v.part:newText("actionList.title." .. tostring(idx)):setText(v.title):setPos(vec(-70,0,0)):setScale(vec(1.5,1.5,1)):setShadow(true)

            local renderedIcons = -1
            for aidx, iv in pairs(v.icons) do
                if iv then
                    renderedIcons = renderedIcons + 1
                    v.part:newSprite("actionList.ficon." .. tostring(idx) .. tostring(aidx)):setTexture(iconsTexture):setPos(vec(-70+(renderedIcons*-8), -14, -.5)):region(vec(8,8)):setUV(vec((aidx*8)/48,0)):setScale(vec(1/6,1,1))
                    v.part:newSprite("actionList.ficon." .. tostring(idx) .. tostring(aidx) .. ".shadow"):setTexture(iconsTexture):setPos(vec(-71+(renderedIcons*-8), -15, -.49)):region(vec(8,8)):setUV(vec((aidx*8)/48,0)):setScale(vec(1/6,1,1)):setColor(vec(.25, .25, .25, 1))
                end
            end
        end
        guiPart:addChild(v.part)
    end
    local scrollBG = guiPart.ListItem_nil:copy("bar"):setPos(vec(-398,0,-.49))
    scrollBG:newSprite("actionlist.barBG"):setTexture(textures:newTexture("actionlist.barBG", 1, 1):fill(0,0,1,1,vec(0,0,0,.25))):setScale(2,100,1)
    guiPart:addChild(scrollBG)
    local scrollBar = guiPart.ListItem_nil:copy("bar"):setPos(vec(-398,math.map(hoveredAction, 1, idx, 0, -100+(100/idx)),-.5))
    scrollBar:newSprite("actionlist.bar"):setTexture(textures:newTexture("actionlist.bar", 1, 1):fill(0,0,1,1,vec(1,1,1,1))):setScale(2,100/idx,1)
    guiPart:addChild(scrollBar)
end

-- Reload wheel each tick the key is held.
events.TICK:register(function ()
    if keyHeld then
        reloadWheel()
        if world.getTime() % 20 then
            renderWheel()
        end
    end
end, "Reload Wheel Each Tick")

-- Keybind
local keybind = keybinds:fromVanilla("figura.config.action_wheel_button")
    :onPress(function ()
        reloadWheel()
        renderWheel()
        guiPart:setVisible(true)
        renderer:setRenderCrosshair(false)
        keyHeld = true
        return true
    end)
    :onRelease(function ()
        guiPart:setVisible(false)
        renderer:setRenderCrosshair(true)
        keyHeld = false
        actionBeingScrolled = false
        return true
    end)

-- Scrolling Handler
events.MOUSE_SCROLL:register(function (dir)
    if actionBeingScrolled then
        wheelData[hoveredAction].action.scroll(dir, wheelData[hoveredAction].action)
        sounds["minecraft:block.note_block.hat"]:setPitch(2.5):pos(player:getPos()):subtitle(nil):play()
        reloadWheel()
        renderWheel()
        return true
    end
    if keyHeld then
        hoveredAction = hoveredAction - dir
        if not wheelData[hoveredAction] then
            hoveredAction = hoveredAction + dir
        else
            sounds["minecraft:block.note_block.hat"]:setPitch(4):pos(player:getPos()):subtitle(nil):play()
        end
        reloadWheel()
        renderWheel()
        return true
    end
end)

-- Click Handler
events.MOUSE_PRESS:register(function (button,status,modifier)
    if keyHeld then
        -- print(button)
        if status == 1 then
            local action = wheelData[hoveredAction]
            local sound = sounds["minecraft:ui.button.click"]:setPitch(2):setVolume(.5):pos(player:getPos()):subtitle(nil)
            if (button == 0 or button == 2) and action.action.scroll then
                sound:play()

                if modifier > 0 then
                    goto skipScroll 
                end

                actionBeingScrolled = not actionBeingScrolled
                if actionBeingScrolled then
                    host:setActionbar('[{"text":"ℹ Scroll mode activated!","color":"yellow"},{"text":" Keep scrolling to trigger this action\'s scroll.","color":"gray"}]')
                else
                    host:setActionbar('[{"text":"ℹ Scroll mode deactivated!","color":"red"},{"text":" Normal scrolling has been resumed.","color":"gray"}]')
                end
                goto skipClick
            end
            ::skipScroll::
            if button == 0 and (action.action.toggle or action.action.untoggle) and not action.action:isToggled() then
                sound:play()
                action.action:setToggled(true)
                if action.action.toggle then
                    action.action.toggle(action.action:isToggled(), action.action)
                end
            elseif button == 0 and (action.action.toggle or action.action.untoggle) and action.action:isToggled() then
                sound:play()
                action.action:setToggled(false)
                if action.action.untoggle then
                    action.action.untoggle(action.action:isToggled(), action.action)
                end
            end
            if button == 0 and action.action.leftClick then
                sound:play()
                action.action.leftClick(action.action)
            end
            if button == 1 and action.action.rightClick then
                sound:play()
                action.action.rightClick(action.action)
            end
        end
        ::skipClick::
        reloadWheel()
        renderWheel()
        return true
    end
end)

reloadWheel()
renderWheel()