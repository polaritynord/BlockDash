local vec2 = require("lib/vec2")
local zerpgui = require("lib/zerpgui")

local interface = {}

function interface:load()
    -- Main menu
    local menu = zerpgui:newCanvas("menu")
    menu:newTextLabel(
        "title", vec2.new(0, 120), "Block Dash", 24, "00", "center"
    )
end

function interface:update(delta)
    zerpgui:update(delta)
end

function interface:draw()
    zerpgui:draw()
end

return interface