local utils = require("utils")
local vec2 = require("lib/vec2")
local zerpgui = require("lib/zerpgui")
local assets = require("scripts/assets")

local interface = {
    damageNums = {};
    hitmarkers = {};
    diffPreview = nil;
    diffPreviewTexts = {
        easy = "Enemies can't dash and shoots slower. Completely removes the fast-paced gameplay.";
        medium = "Enemies can dash, while shooting slightly faster than the player.";
        hard = "Enemies will probably tear you apart with dashing to you & shooting like it's a bullet hell.";
    }
}

-- Button events
function interface.playButtonClick()
    GameState = "diffSelect"
end

function interface:easyButtonClick()
    if interface.diffPreview == "easy" then
        Difficulty = 1
        GameState = "game"
    else
        interface.diffPreview = "easy"
    end
end

function interface.mediumButtonClick()
    if interface.diffPreview == "medium" then
        Difficulty = 2
        GameState = "game"
    else
        interface.diffPreview = "medium"
    end
end

function interface.hardButtonClick()
    if interface.diffPreview == "hard" then
        Difficulty = 3
        GameState = "game"
    else
        interface.diffPreview = "hard"
    end
end

-- Other calls
function interface:playerShot()

end

function interface:load()
    -- Main menu -------------------------------------------------------------------------------------------------
    self.menu = zerpgui:newCanvas()
    self.menu:newTextLabel(
        "title", vec2.new(0, 120), "Block Dash", 48, "00", "center"
    )
    self.menu:newButton(
        "play", vec2.new(350, 260), nil, 1, "Play", 24, nil, self.playButtonClick, "00"
    )
    -- Difficulty selection ------------------------------------------------------------------------------------
    self.diffSelect = zerpgui:newCanvas()
    self.diffSelect:newTextLabel(
        "title", vec2.new(0, 120), "Difficulty Select", 48, "00", "center"
    )
    -- Buttons
    self.diffSelect:newButton(
        "easy", vec2.new(380, 260), vec2.new(200, 70), 2, "easy", 24, nil, self.easyButtonClick, "00"
    )
    self.diffSelect:newButton(
        "medium", vec2.new(380, 340), vec2.new(200, 70), 2, "normal", 24, nil, self.mediumButtonClick, "00"
    )
    self.diffSelect:newButton(
        "hard", vec2.new(380, 420), vec2.new(200, 70), 2, "hard", 24, nil, self.hardButtonClick, "00"
    )
    -- Preview text
    self.diffSelect:newTextLabel(
        "preview", vec2.new(0, 15), "", 14, "00", "center"
    )
    -- Game ---------------------------------------------------------------------------------------------------
    self.game = zerpgui:newCanvas()
    -- Weapon image
    self.game:newImage(
        "weaponImg", vec2.new(60, 445), 0, nil, 3, "x+"
    )
    -- Weapon text
    self.game:newTextLabel(
        "weaponText", vec2.new(25, 470), "", 24, "x+", "left"
    )
end

function interface:update(delta)
    -- Change canvas based on GameState
    self.menu.enabled = GameState == "menu"
    self.diffSelect.enabled = GameState == "diffSelect"
    self.game.enabled = GameState == "game"
    -- Difficulty selection menu
    if GameState == "diffSelect" then
        if self.diffPreview then
            local t = "\nClick again to continue."
            self.diffSelect.preview.text = self.diffPreviewTexts[self.diffPreview] .. t
        else
            self.diffSelect.preview.text = ""
        end
    end
    -- Game
    if GameState == "game" then
        -- Weapon UI
        local w = Player.weapons[Player.slot]
        if w then
            self.game.weaponImg.source = assets.weapons[w.name .. "Img"]
            self.game.weaponText.text = utils.capitalize(w.name)
        else
            self.game.weaponImg.source = nil
            self.game.weaponText.text = ""
        end
    end
    -- Zerpgui updating
    zerpgui:update(delta)
end

function interface:draw()
    zerpgui:draw()
end

return interface