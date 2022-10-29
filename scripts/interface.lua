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
    };
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

function interface.quitButtonClick()
    if interface.menu.quit.sure then
        love.event.quit()
    else
        interface.menu.quit.sure = true
    end
end

function interface.continueButtonClick()
    GamePaused = false
end

function interface.titleButtonClick()
    interface.pauseMenu.alpha = 0
    GamePaused = false
    GameState = "menu"
end

-- Call events
function interface:playerShot()

end

-- Other functions
function interface:setCanvasVisible()
    self.menu.enabled = GameState == "menu"
    self.diffSelect.enabled = GameState == "diffSelect"
    self.game.enabled = GameState == "game"
    self.pauseMenu.enabled = GameState == "game"
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
    -- Health text
    self.game.healthText.text = math.floor(Player.health)
    -- Dash indicator text
    if Player.dashTimer < 2.5 then
        self.game.dashText.text = "CHARGING"
        self.game.dashIcon.position.x = 735
    else
        self.game.dashText.text = "READY"
        self.game.dashIcon.position.x = 785
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
    if not self.debug.enabled then return end
    self.debug.fps.text = "FPS: " .. love.timer.getFPS() .. " / " .. math.floor(1/love.timer.getAverageDelta())
    self.debug.enemyCount.text = "Enemy Count: " .. #EnemyManager.enemies
    self.debug.particleCount.text = "Particle Count: " .. #ParticleManager.particles
    self.debug.bulletCount.text = "Bullet Count: " .. #EnemyBullets + #Player.bullets
end

function interface:updateMenu()
    if self.menu.quit.sure then
        self.menu.sureText.text = "You sure?"
    else
        self.menu.sureText.text = ""
    end
end

-- Event functions
function interface:load()
    -- Main menu -------------------------------------------------------------------------------------------------
    self.menu = zerpgui:newCanvas()
    self.menu:newTextLabel(
        "title", vec2.new(0, 120), "Block Dash", 48, "00", "center"
    )
    self.menu:newButton(
        "play", vec2.new(380, 260), vec2.new(200, 70), 2, "play", 24, nil, self.playButtonClick, "00"
    )
    self.menu:newButton(
        "settings", vec2.new(380, 340), vec2.new(200, 70), 2, "settings", 24, nil, nil, "00"
    )
    self.menu:newButton(
        "quit", vec2.new(380, 420), vec2.new(200, 70), 2, "quit", 24, nil, self.quitButtonClick, "00"
    )
    self.menu.quit.sure = false
    self.menu:newTextLabel(
        "sureText", vec2.new(-20, 500), "", 14, "00", "center"
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
    x = 925 ; y = 505
    j = 4
    for _ = 1, Player.slotCount do
        self.game:newImage("slotW"..j, vec2.new(x, y), 0, nil, 1.5, "++")
        j = j - 1
        x = x - 64
    end
    -- Health icon & text
    self.game:newImage("healthIcon", vec2.new(925, 450), 0, assets.healthIconImg, 4, "++")
    self.game:newTextLabel("healthText", vec2.new(-100, 435), "100", 24, "++", "right")
    -- Dash right click icon
    self.game:newImage("rmb", vec2.new(925, 415), 0, assets.rmbImg, 2, "++")
    -- Dash indicator text
    self.game:newTextLabel("dashText", vec2.new(-100, 400), "READY", 24, "++", "right")
    -- Dash indicator icon
    self.game:newImage("dashIcon", vec2.new(785, 415), 0, assets.dashIconImg, 1.3, "++")
    
    -- Debug menu (game) ---------------------------------------------------------------------------------------
    self.debug = zerpgui:newCanvas()
    self.debug:newTextLabel("fps", vec2.new(), "", 14, "xx", "left", "JetBrainsMono")
    self.debug:newTextLabel("enemyCount", vec2.new(0, 15), "", 14, "xx", "left", "JetBrainsMono")
    self.debug:newTextLabel("particleCount", vec2.new(0, 30), "", 14, "xx", "left", "JetBrainsMono")
    self.debug:newTextLabel("bulletCount", vec2.new(0, 45), "", 14, "xx", "left", "JetBrainsMono")

    -- Pause menu (game) ---------------------------------------------------------------------------------------
    self.pauseMenu = zerpgui:newCanvas()
    self.pauseMenu:newRectangle(
        "background", vec2.new(), vec2.new(SC_WIDTH, SC_HEIGHT), "fill", {0, 0, 0, 1}, 0, "00"
    )
    self.pauseMenu:newTextLabel(
        "title", vec2.new(0, 120), "Game Paused", 48, "00", "center"
    )
    self.pauseMenu:newButton(
        "continue", vec2.new(380, 260), vec2.new(200, 70), 2, "continue", 24, nil, self.continueButtonClick, "00"
    )
    self.pauseMenu:newButton(
        "quit", vec2.new(380, 340), vec2.new(200, 70), 2, "title menu", 24, nil, self.titleButtonClick, "00"
    )
    self.pauseMenu.alpha = 0
end

function interface:updatePauseMenu()
    local delta = love.timer.getDelta()
    local a = self.pauseMenu.alpha
    if GamePaused then
    	self.pauseMenu.alpha = a+(1-a) / (250 * delta)
    else
        self.pauseMenu.alpha = a+(0-a) / (250 * delta)
    end
    self.pauseMenu.background.color[4] = self.pauseMenu.alpha-0.35
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
        self:updatePauseMenu()
    end
    -- Menu
    if GameState == "menu" then
        self:updateMenu()
    end
    -- Zerpgui updating
    zerpgui:update(delta)
end

function interface:draw()
    zerpgui:draw()
end

return interface