local vec2 = require("lib/vec2")
local zerpgui = require("lib/zerpgui")

local interface = {}

function interface.playButtonClick()
    GameState = "diffSelect"
end

function interface:load()
    -- Main menu
    self.menu = zerpgui:newCanvas("menu")
    self.menu:newTextLabel(
        "title", vec2.new(0, 120), "Block Dash", 48, "00", "center"
    )
    self.menu:newButton(
        "play", vec2.new(350, 260), nil, 1, "Play", 24, nil, self.playButtonClick, "00"
    )
end

function interface:update(delta)
    -- Change canvas based on GameState
    self.menu.enabled = GameState == "menu"
    zerpgui:update(delta)
end

function interface:draw()
    zerpgui:draw()
end

return interface