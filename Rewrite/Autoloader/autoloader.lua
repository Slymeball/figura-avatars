local scriptOrder = {
}

local scr_pp, scr_name = ...
local scr_fp = (scr_pp ~= "" and scr_pp .. "." or "") .. scr_name

local skiplist = {}

local function requireIfNot(name, exclude)
    if name ~= exclude then require(name) end
end

for idx, v in pairs(scriptOrder) do
    if idx > 0 then
        if type(v) == "string" then
            requireIfNot(v, scr_fp)
            skiplist[v] = true
        elseif type(v) == "table" then
            for _, script in pairs(v) do
                requireIfNot(script, scr_fp)
                skiplist[script] = true
            end
        end
        scriptOrder[idx] = nil
    elseif idx < 0 then
        if type(v) == "string" then
            skiplist[v] = true
        elseif type(v) == "table" then
            for _, script in pairs(v) do
                skiplist[script] = true
            end
        end
    end
end

for idx, v in pairs(listFiles(nil, true)) do
    if not skiplist[v] then requireIfNot(v, scr_fp) end
end

for _, v in pairs(scriptOrder) do
    if type(v) == "string" then
        requireIfNot(v, scr_fp)
        skiplist[v] = true
    elseif type(v) == "table" then
        for _, script in pairs(v) do
            requireIfNot(script, scr_fp)
            skiplist[script] = true
        end
    end
end