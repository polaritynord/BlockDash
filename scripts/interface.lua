local vec2 = require("lib/vec2")
local zerpgui = require("lib/zerpgui")

local interface = {
    damageNums = {};
    hitmarkers = {};
}

-- Button events
function interface.playButtonClick()
    GameState = "diffSelect"
end

function interface.diffButtonClick(button)
    -- Set difficulty
    if button.name == "easy" then Difficulty = 1
    elseif button.name == "medium" then Difficulty = 2
    else Difficulty = 3 end
    -- Start game
    GameState = "game"
end

-- Other calls
function interface:playerShot()

end

function interface:load()
    -- Main menu
    self.menu = zerpgui:newCanvas()
    self.menu:newTextLabel(
        "title", vec2.new(0, 120), "Block Dash", 48, "00", "center"
    )
    self.menu:newButton(
        "play", vec2.new(350, 260), nil, 1, "Play", 24, nil, self.playButtonClick, "00"
    )
    -- Difficulty selection
    self.diffSelect = zerpgui:newCanvas()
    self.diffSelect:newTextLabel(
        "title", vec2.new(0, 120), "Difficulty Select", 48, "00", "center"
    )
    self.diffSelect:newButton(
        "easy", vec2.new(380, 260), vec2.new(200, 70), 2, "easy", 24, nil, self.diffButtonClick, "00"
    )
    self.diffSelect:newButton(
        "medium", vec2.new(380, 340), vec2.new(200, 70), 2, "normal", 24, nil, self.diffButtonClick, "00"
    )
    self.diffSelect:newButton(
        "hard", vec2.new(380, 420), vec2.new(200, 70), 2, "hard", 24, nil, self.diffButtonClick, "00"
    )
end

function interface:update(delta)
    -- Change canvas based on GameState
    self.menu.enabled = GameState == "menu"
    self.diffSelect.enabled = GameState == "diffSelect"
    zerpgui:update(delta)
end

function interface:draw()
    zerpgui:draw()
end

return interface