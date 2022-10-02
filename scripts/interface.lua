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

-- Call events
function interface:playerShot()

end

-- Other functions
function interface:setCanvasVisible()
    self.menu.enabled = GameState == "menu"
    self.diffSelect.enabled = GameState == "diffSelect"
    self.game.enabled = GameState == "game"
end

function interface:updateGame()
    local delta = love.timer.getDelta()
    -- Weapon UI
    local w = Player.weapons[Player.slot]
    if w then
        -- Weapon Image
        self.game.weaponImg.source = assets.weapons[w.name .. "Img"]
        -- Weapon name
        self.game.weaponText.text = utils.capitalize(w.name)
        -- Mag ammo
        local len = #tostring(w.magAmmo)
        local t = w.magAmmo
        if Player.reloading then t = ". ." end
        self.game.magAmmo.text = t
        self.game.magAmmo.position.x = 25 - (len-1)*15
        self.game.ammoIcon.source = assets.ammoIconImg
        self.game.infAmmo.text = "∞"
    else
        self.game.weaponImg.source = nil
        self.game.weaponText.text = ""
        self.game.magAmmo.text = ""
        self.game.ammoIcon.source = nil
        self.game.infAmmo.text = ""
    end
    -- Inventory slots (rectangle)
    for i = 1, Player.slotCount do
        local element = self.game["slot"..i]
        local l = element.lineWidth
        if i == Player.slot then
            element.lineWidth = l + (6-l) / (250 * delta)
        else
            element.lineWidth = l + (3-l) / (250 * delta)
        end
    end
    -- Inventory slots (image)
    for i = 1, Player.slotCount do
        local element = self.game["slotW"..i]
        local w = Player.weapons[i]
        if w then
            element.source = assets.weapons[w.name .. "Img"]
        else
            element.source = nil
        end
    end
end

function interface:updateDiffSelect()
    if self.diffPreview then
        local t = "\nClick again to continue."
        self.diffSelect.preview.text = self.diffPreviewTexts[self.diffPreview] .. t
    else
        self.diffSelect.preview.text = ""
    end
end

function interface:updateDebug()
    self.debug.fps.text = "FPS: " .. love.timer.getFPS() .. " / " .. math.floor(1/love.timer.getAverageDelta())
    self.debug.enemyCount.text = "Enemy Count: " .. #EnemyManager.enemies
    self.debug.particleCount.text = "Particle Count: " .. #ParticleManager.particles
    self.debug.bulletCount.text = "Bullet Count: " .. #EnemyBullets + #Player.bullets
end

-- Event functions
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
    -- ***WEAPON UI***
    -- Weapon text
    self.game:newTextLabel(
        "weaponText", vec2.new(25, 470), "", 24, "x+", "left"
    )
    -- Magazine ammo
    self.game:newTextLabel(
        "magAmmo", vec2.new(25, 505), 0, 20, "x+", "left"
    )
    -- Ammo icon
    self.game:newImage(
        "ammoIcon", vec2.new(55, 518.5), 0, nil, 1, "x+"
    )
    -- "Infinite" symbol
    self.game:newTextLabel(
        "infAmmo", vec2.new(71, 503), "∞", 20, "x+", "left"
    )
    -- ***HEALTH AND INV UI***
    -- Slots
    local x = 900 ; local y = 480
    local j = 4
    for _ = 1, Player.slotCount do
        self.game:newRectangle("slot"..j, vec2.new(x, y), vec2.new(50, 50), "line", {1,1,1,1}, 3, "++")
        x = x - 64
        j = j - 1
    end
    -- Slot weapons
    x = 900+25 ; y = 480+25
    j = 4
    for _ = 1, Player.slotCount do
        self.game:newImage("slotW"..j, vec2.new(x, y), 0, nil, 1.5, "++")
        j = j - 1
        x = x - 64
    end
    
    -- Debug menu (game) ---------------------------------------------------------------------------------------
    self.debug = zerpgui:newCanvas()
    self.debug:newTextLabel("fps", vec2.new(), "", 14, "xx", "left", "JetBrainsMono")
    self.debug:newTextLabel("enemyCount", vec2.new(0, 15), "", 14, "xx", "left", "JetBrainsMono")
    self.debug:newTextLabel("particleCount", vec2.new(0, 30), "", 14, "xx", "left", "JetBrainsMono")
    self.debug:newTextLabel("bulletCount", vec2.new(0, 45), "", 14, "xx", "left", "JetBrainsMono")
end

function interface:update(delta)
    -- Change canvas based on GameState
    self:setCanvasVisible()
    -- Difficulty selection menu
    if GameState == "diffSelect" then
        self:updateDiffSelect()
    end
    -- Game
    if GameState == "game" then
        self:updateGame()
        self:updateDebug()
    end
    -- Zerpgui updating
    zerpgui:update(delta)
end

function interface:draw()
    zerpgui:draw()
end

return interface