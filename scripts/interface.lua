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
    statElements = {};
    text = love.filesystem.read("string", "howtoplay.txt");
}

-- Button events
function interface.playButtonClick()
    GameState = "diffSelect"
    interface.diffPreview = nil
end

function interface.aboutButtonClick()
    GameState = "about"
end

function interface:easyButtonClick()
    if interface.diffPreview == "easy" then
        Difficulty = 1
        GameLoad()
    else
        interface.diffPreview = "easy"
    end
end

function interface.mediumButtonClick()
    if interface.diffPreview == "medium" then
        Difficulty = 2
        GameLoad()
    else
        interface.diffPreview = "medium"
    end
end

function interface.hardButtonClick()
    if interface.diffPreview == "hard" then
        Difficulty = 3
        GameLoad()
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
    interface.menu.quit.sure = false
end

-- Call events
function interface:updateHitmarkers(delta)
    for i, v in ipairs(self.hitmarkers) do
        v.update(delta, i)
    end
end

function interface:drawHitmarkers()
    for _, v in ipairs(self.hitmarkers) do
        v.draw()
    end
end

function interface:updateDamageNums(delta)
    for i, v in ipairs(self.damageNums) do
        v.update(delta, i)
    end
end

function interface:drawDamageNums()
    for _, v in ipairs(self.damageNums) do
        v.draw()
    end
end

-- Canvas functions
function interface:setCanvasVisible()
    self.menu.enabled = GameState == "menu"
    self.diffSelect.enabled = GameState == "diffSelect"
    self.game.enabled = GameState == "game"
    self.pauseMenu.enabled = GameState == "game" and not CurrentShader and self.pauseMenu.alpha > 0.3
    self.deathMenu.enabled = GameState == "game" and self.deathMenu.alpha > 0.3
    self.about.enabled = GameState == "about"
end

function interface:updateGame()
    local delta = love.timer.getDelta()
    -- Wave text
    if WaveManager.preparation then
        self.game.wave.text = "PREPARE FOR WAVE " .. WaveManager.wave
    else
        self.game.wave.text = "WAVE " .. WaveManager.wave .. " - " .. #EnemyManager.enemies .. " ENEMIES LEFT"
    end
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
    -- TODO add actual game versioning
    self.debug.versionData.text = "BlockDash v1.0 (ZerpGUI 1.0, LÖVE " .. love.getVersion() .. ")"
    self.debug.fps.text = "FPS: " .. love.timer.getFPS() .. " / " .. math.floor(1/love.timer.getAverageDelta())
    self.debug.enemyCount.text = "Enemy Count: " .. #EnemyManager.enemies
    self.debug.particleCount.text = "Particle Count: " .. #ParticleManager.particles
    self.debug.bulletCount.text = "Bullet Count: " .. #EnemyBullets + #Player.bullets
    self.debug.wave.text = "Wave: " .. WaveManager.wave
end

function interface:updateMenu()
    if self.menu.quit.sure then
        self.menu.quit.text = "you sure?"
    else
        self.menu.quit.text = "quit"
    end
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
    self.pauseMenu.background.size = vec2.new(SC_WIDTH, SC_HEIGHT)
end

function interface:updateDeathMenu()
    local a = self.deathMenu.alpha
    local delta = love.timer.getDelta()
    if Player.dead and Player.deathTimer > 1.5 then
    	self.deathMenu.alpha = a+(1-a) / (250 * delta)
    else
        self.deathMenu.alpha = a+(0-a) / (250 * delta)
    end
    self.deathMenu.background.color[4] = self.deathMenu.alpha-0.35
    self.deathMenu.background.size = vec2.new(SC_WIDTH, SC_HEIGHT)
    -- Update statistics
    print(Stats.kills, Stats.dashKills, Stats.waves)
    for _, v in ipairs(self.statElements) do
        v.text = Stats[v.statName]
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
        "about", vec2.new(380, 340), vec2.new(200, 70), 2, "help", 24, nil, self.aboutButtonClick, "00"
    )
    self.menu:newButton(
        "quit", vec2.new(380, 420), vec2.new(200, 70), 2, "quit", 24, nil, self.quitButtonClick, "00"
    )
    self.menu.quit.sure = false
    self.menu:newTextLabel(
        "versionInfo", vec2.new(5, 516), "v" .. Version .. " - Made by Zerpnord", 14, "x+", "left"
    )
    -- About menu ----------------------------------------------------------------------------------------------
    self.about = zerpgui:newCanvas()
    self.about:newTextLabel(
        "title", vec2.new(0, 120), "How to Play", 48, "00", "center"
    )
    self.about:newTextLabel(
        "keyControls", vec2.new(180, 220), self.text, 16, "00", "left"
    )
    self.about:newButton(
        "return", vec2.new(380, 420), vec2.new(200, 70), 2, "return", 24, nil, self.titleButtonClick, "00"
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
    -- Wave text
    self.game:newTextLabel(
        "wave", vec2.new(0, 20), "WAVE 1", 24, "0x", "center"
    )
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
    self.debug:newTextLabel("versionData", vec2.new(), "", 14, "xx", "left", "JetBrainsMono")
    self.debug:newTextLabel("fps", vec2.new(0, 15), "", 14, "xx", "left", "JetBrainsMono")
    self.debug:newTextLabel("enemyCount", vec2.new(0, 30), "", 14, "xx", "left", "JetBrainsMono")
    self.debug:newTextLabel("particleCount", vec2.new(0, 45), "", 14, "xx", "left", "JetBrainsMono")
    self.debug:newTextLabel("bulletCount", vec2.new(0, 60), "", 14, "xx", "left", "JetBrainsMono")
    self.debug:newTextLabel("wave", vec2.new(0, 75), "", 14, "xx", "left", "JetBrainsMono")

    -- Pause menu (game) ---------------------------------------------------------------------------------------
    self.pauseMenu = zerpgui:newCanvas()
    self.pauseMenu:newRectangle(
        "background", vec2.new(), vec2.new(SC_WIDTH, SC_HEIGHT), "fill", {0, 0, 0, 1}, 0, "xx"
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
    -- Death menu (game) ---------------------------------------------------------------------------------------
    self.deathMenu = zerpgui:newCanvas()
    self.deathMenu:newRectangle(
        "background", vec2.new(), vec2.new(SC_WIDTH, SC_HEIGHT), "fill", {0, 0, 0, 1}, 0, "xx"
    )
    self.deathMenu:newTextLabel(
        "title", vec2.new(0, 120), "Eliminated", 48, "00", "center"
    )
    self.deathMenu:newButton(
        "return", vec2.new(380, 420), vec2.new(200, 70), 2, "title menu", 24, nil, self.titleButtonClick, "00"
    )
    self.deathMenu:newTextLabel(
        "statsTitle", vec2.new(0, 200), "Statistics:", 20, "00", "center"
    )
    -- Stat numbers
    local pos = vec2.new(-640, 230)
    for i in pairs(Stats) do
        self.deathMenu:newTextLabel(
            "stat"..i, vec2.new(pos.x, pos.y), "0", 40, "00", "right"
        )
        self.deathMenu["stat"..i].statName = i
        self.statElements[#self.statElements+1] = self.deathMenu["stat"..i]
        pos.y = pos.y + 48
    end
    -- Stat names
    pos = vec2.new(365.5, 240)
    for i in pairs(StatNames) do
        self.deathMenu:newTextLabel(
            "statN"..i, vec2.new(pos.x, pos.y), StatNames[i], 20, "00", "left"
        )
        pos.y = pos.y + 52
    end
    self.deathMenu.alpha = 0
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
        self:updateDeathMenu()
        self:updateHitmarkers(delta)
        self:updateDamageNums(delta)
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
    self:drawHitmarkers()
    self:drawDamageNums()
end

return interface