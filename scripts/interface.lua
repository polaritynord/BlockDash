local utils = require("utils")
local vec2 = require("lib/vec2")

local assets = require("scripts/assets")
local button = require("scripts/button")
local invSlot = require("scripts/invSlot")

local interface = {
    buttons = {};
    pauseScreenAlpha = 0;
    deathScreenAlpha = 0;
    invSlots = {};
    wScale = 1;
    wRot = 0;
    wAlpha = 1;
    logKeyPress = false;
    damageNums = {};
    hitmarkers = {};
    dashKillAlpha = 0;
    dashKillScale = 1;
}

function interface.drawImage(image, position, scale, rotation, alpha)
    local rotation = rotation or 0
    local alpha = alpha or 1
    local width = image:getWidth()
    local height = image:getHeight()
    love.graphics.draw(
    	image, position.x, position.y, rotation,
    	scale, scale, width/2, height/2
    )
end

function interface.playerShot()
    interface.wScale = 1.15
    interface.wRot = -0.12
end

-- Event functions
function interface.load()
    interface.buttons = {}
    -- Main menu - play button
    local mPlayButton = button.new()
    mPlayButton.position = vec2.new(480, 270)
    mPlayButton.text = "play"
    mPlayButton.uppercaseText = false

    function mPlayButton.clickEvent()
        GameState = "diffSelect"
    end

    -- Main menu - settings button
    local mSetButton = button.new()
    mSetButton.position = vec2.new(480, 310)
    mSetButton.text = "settings"
    mSetButton.uppercaseText = false

    function mSetButton.clickEvent()
       GameState = "settings"
    end

    -- Main menu - quit button
    local mQuitButton = button.new()
    mQuitButton.position = vec2.new(480, 350)
    mQuitButton.text = "quit"
    mQuitButton.uppercaseText = false

    function mQuitButton.clickEvent()
       love.event.quit()
    end

    -- Pause menu - continue button
    local pContinueButton = button.new()
    pContinueButton.position = vec2.new(480, 270)
    pContinueButton.size = vec2.new(175, 65);
    pContinueButton.text = "continue"
    pContinueButton.uppercaseText = false
    pContinueButton.style = 2

    function pContinueButton.clickEvent()
       GamePaused = false
    end
    -- Pause menu - quit button
    local pQuitButton = button.new()
    pQuitButton.position = vec2.new(480, 350)
    pQuitButton.size = vec2.new(175, 65);
    pQuitButton.text = "quit"
    pQuitButton.uppercaseText = false
    pQuitButton.style = 2

    function pQuitButton.clickEvent()
       GameState = "menu"
    end
    -- Settings menu - sound effects button
    local sSoundButton = button.new()
    sSoundButton.position = vec2.new(480, 150)
    local t = "ON"
    if not Settings.sound then t = "OFF" end
    sSoundButton.text = "sfx: " .. t
    sSoundButton.uppercaseText = false
    sSoundButton.style = 1

    function sSoundButton.clickEvent()
       Settings.sound = not Settings.sound
	local text = "ON"
	if not Settings.sound then
	    text = "OFF" end
	sSoundButton.text = "sfx: " .. text
    end
    -- Settings menu - quit button
    local sQuitButton = button.new()
    sQuitButton.position = vec2.new(480, 420)
    sQuitButton.text = "quit"
    sQuitButton.uppercaseText = false
    sQuitButton.style = 2

    function sQuitButton.clickEvent()
       GameState = "menu"
    end
    -- Settings menu - intelli-reload button
    local sReloadButton = button.new()
    sReloadButton.position = vec2.new(480, 185)
    local t = "ON"
    if not Settings.intelligentReload then t = "OFF" end
    sReloadButton.text = "intelligent reload: " .. t
    sReloadButton.uppercaseText = false
    sReloadButton.style = 1

    function sReloadButton.clickEvent()
    	Settings.intelligentReload = not Settings.intelligentReload
    	local text = "ON"
    	if not Settings.intelligentReload then
    	    text = "OFF" end
    	sReloadButton.text = "intelligent reload: " .. text
    end

    -- Diff menu - easy button
    local dEasyButton = button.new()
    dEasyButton.position = vec2.new(480, 240)
    dEasyButton.text = "easy"
    dEasyButton.uppercaseText = false
    dEasyButton.style = 2

    function dEasyButton.clickEvent()
        Difficulty = 1
        GameLoad()
    end

    -- Diff menu - medium button
    local dMediumButton = button.new()
    dMediumButton.position = vec2.new(480, 330)
    dMediumButton.text = "medium"
    dMediumButton.uppercaseText = false
    dMediumButton.style = 2

    function dMediumButton.clickEvent()
        Difficulty = 2
        GameLoad()
    end

    -- Diff menu - hard button
    local dHardButton = button.new()
    dHardButton.position = vec2.new(480, 420)
    dHardButton.text = "hard"
    dHardButton.uppercaseText = false
    dHardButton.style = 2

    function dHardButton.clickEvent()
        Difficulty = 3
        GameLoad()
    end

    -- Death menu - return button
    local deReturnButton = button.new()
    deReturnButton.position = vec2.new(480, 420)
    deReturnButton.text = "return"
    deReturnButton.uppercaseText = false
    deReturnButton.style = 2

    function deReturnButton.clickEvent()
        GameState = "menu"
    end

    interface.buttons.mPlayButton = mPlayButton
    interface.buttons.mSetButton = mSetButton
    interface.buttons.mQuitButton = mQuitButton
    interface.buttons.pContinueButton = pContinueButton
    interface.buttons.pQuitButton = pQuitButton
    interface.buttons.sSoundButton = sSoundButton
    interface.buttons.sReloadButton = sReloadButton
    interface.buttons.sQuitButton = sQuitButton
    interface.buttons.dEasyButton = dEasyButton
    interface.buttons.dMediumButton = dMediumButton
    interface.buttons.dHardButton = dHardButton
    interface.buttons.deReturnButton = deReturnButton
    -- Create inventory slots
    interface.invSlots = {}
    local x = 926 ; local y = 510;
    local j = Player.slotCount
    for i = 1, Player.slotCount do
    	local s = invSlot.new()
    	s.position.x = x ; s.position.y = y
    	s.slot = j
    	x = x - 60
    	j = j - 1

    	interface.invSlots[#interface.invSlots+1] = s
    end
end

function interface.updateGame(delta)
    interface.updateDamageNums(delta)
    interface.updateHitmarkers(delta)
    -- Change rot & scale of weapon image
    interface.wScale = interface.wScale + (1-interface.wScale) / (250 * delta)
    interface.wRot = interface.wRot + (-interface.wRot) / (250 * delta)
    -- Change scale & alpha of dash kill text
    interface.dashKillAlpha = interface.dashKillAlpha - 1 * delta
    interface.dashKillScale = interface.dashKillScale + (1-interface.dashKillScale) / (230 * delta)
    -- Change alpha of death screen
    local a = interface.deathScreenAlpha
    if Player.dead and Player.deathTimer > 1.5 then
        interface.deathScreenAlpha = a+(0.65-a) / (450 * delta)
        -- Update buttons
        interface.buttons.deReturnButton.update(delta)
    end
    -- Change alpha of pause screen
    a = interface.pauseScreenAlpha
    if GamePaused then
    	interface.pauseScreenAlpha = a+(0.65-a) / (250 * delta)
    	-- Update buttons
    	interface.buttons.pContinueButton.update(delta)
    	interface.buttons.pQuitButton.update(delta)
    else
        interface.pauseScreenAlpha = a+(0-a) / (250 * delta)
    end
    -- Update inventory slots
    for _, v in ipairs(interface.invSlots) do
	v.update(delta)
    end
    -- Update inventory slots
    for _, v in ipairs(interface.invSlots) do
	v.update(delta)
    end
end

function interface.updateDiffSelect(delta)
    interface.buttons.dEasyButton.update(delta)
    interface.buttons.dMediumButton.update(delta)
    interface.buttons.dHardButton.update(delta)
end

function interface.updateMenu(delta)
    interface.buttons.mPlayButton.update(delta)
    interface.buttons.mSetButton.update(delta)
    interface.buttons.mQuitButton.update(delta)
end

function interface.updateSettings(delta)
    interface.buttons.sSoundButton.update(delta)
    interface.buttons.sReloadButton.update(delta)
    interface.buttons.sQuitButton.update(delta)
    -- Secret key for enabling logging
    if not interface.logKeyPress and love.keyboard.isDown("q") then
        Settings.showLogs = not Settings.showLogs
        if Settings.showLogs then VD.log("Show logs toggled") end
    end
    interface.logKeyPress = love.keyboard.isDown("q")
end

function interface.update(delta)
    if GameState == "game" then
       interface.updateGame(delta)
    elseif GameState == "menu" then
       interface.updateMenu(delta)
    elseif GameState == "settings" then
       interface.updateSettings(delta)
   elseif GameState == "diffSelect" then
       interface.updateDiffSelect(delta)
   end
end

function interface.updateDamageNums(delta)
    for i, v in ipairs(interface.damageNums) do
        v.update(delta, i)
    end
end

function interface.drawDamageNums()
    for _, v in ipairs(interface.damageNums) do
        v.draw(delta)
    end
end

function interface.updateHitmarkers(delta)
    for i, v in ipairs(interface.hitmarkers) do
        v.update(delta, i)
    end
end

function interface.drawHitmarkers()
    for _, v in ipairs(interface.hitmarkers) do
        v.draw(delta)
    end
end

function interface.drawGame()
    interface.drawDamageNums()
    interface.drawHitmarkers()

    -- Inventory slots
    for _, v in ipairs(interface.invSlots) do
       v.draw()
    end
    -- Health icon
    interface.drawImage(assets.healthIconImg, vec2.new(930+(SC_WIDTH-960), 452+(SC_HEIGHT-540)), 4)
    -- Health text
    love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 24)
    love.graphics.printf(tostring(math.floor(Player.health)), -95+(SC_WIDTH-960), 438+(SC_HEIGHT-540), 1000, "right")

    -- Dash indicator
    if Player.dashTimer < 2.5 then
    	love.graphics.setColor(1, 1, 1, 0.45)
    	love.graphics.printf("CHARGING", -90+(SC_WIDTH-960), 382.5+(SC_HEIGHT-540), 1000, "right")
    	love.graphics.setColor(0.35, 0.35, 0.35, 1)
    else
    	love.graphics.setColor(1, 1, 1, 1)
    	love.graphics.printf("READY", -90+(SC_WIDTH-960), 382.5+(SC_HEIGHT-540), 1000, "right")
    end
    interface.drawImage(assets.dashIconImg, vec2.new(930+(SC_WIDTH-960), 400+(SC_HEIGHT-540)), 1.85)
    interface.drawImage(assets.rmbImg, vec2.new(800+(SC_WIDTH-960), 400+(SC_HEIGHT-540)), 2)

    love.graphics.setColor(1, 1, 1, 1)
    -- Weapon UI
    if Player.weapons[Player.slot] then
    	local w = Player.weapons[Player.slot]
    	-- Image
    	local image = assets.weapons[w.name .. "Img"]
    	interface.drawImage(image, vec2.new(60, 445+(SC_HEIGHT-540)), 3*interface.wScale, interface.wRot)
    	-- Name
    	love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 24)
    	love.graphics.print(utils.capitalize(w.name), 25, 470+(SC_HEIGHT-540))
    	-- Mag ammo
    	love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 20)
    	local t = w.magAmmo
    	local len = #tostring(t)
    	if Player.reloading then t = ". ." end
    	love.graphics.print(t, 25 - (len-1)*15, 505+(SC_HEIGHT-540))
    	-- Ammo icon
    	local image = assets.ammoIconImg
    	interface.drawImage(image, vec2.new(55, 518.5+(SC_HEIGHT-540)), 1)
    	-- Infinite text
    	love.graphics.print("∞", 71, 503+(SC_HEIGHT-540))
    end

    -- Dash text
    if CurrentShader then
       love.graphics.print("RELEASE RMB TO DASH", 327+(SC_WIDTH-960)/2, 360+(SC_HEIGHT-540)/2)
    end

    -- DashKill text
    if not CurrentShader then
        love.graphics.setColor(1, 1, 1, interface.dashKillAlpha)
        love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 30*interface.dashKillScale)
        love.graphics.print("DASH KILL!", 396+(SC_WIDTH-960)/2, 400+(SC_HEIGHT-540)/2)
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- Death screen
    if Player.dead and Player.deathTimer > 1.5 then
        -- Background
    	love.graphics.setColor(0, 0, 0, interface.deathScreenAlpha)
    	love.graphics.rectangle("fill", 0, 0, SC_WIDTH, SC_HEIGHT)
    	-- Title
    	love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 32)
    	love.graphics.setColor(1, 1, 1, interface.deathScreenAlpha+0.35)
    	love.graphics.print("ELIMINATED", 395+(SC_WIDTH-960)/2, 120+(SC_HEIGHT-540)/2)
        -- Stats title
        love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 20)
        love.graphics.print("Stats:", 465+(SC_WIDTH-960)/2, 160+(SC_HEIGHT-540)/2)
        -- Stat numbers
        love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 40)
        local x = -640 ; local y = 190
        for i in pairs(Stats) do
            love.graphics.printf(tostring(Stats[i]), x+(SC_WIDTH-960)/2, y+(SC_HEIGHT-540)/2, 1000, "right")
            y = y + 48
        end
        -- Stat names
        love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 20)
        x = 365.5 ; y = 190
        for i in pairs(StatNames) do
            love.graphics.print(tostring(StatNames[i]), x+(SC_WIDTH-960)/2, y+(SC_HEIGHT-540)/2)
            y = y + 52
        end
        -- Buttons
        interface.buttons.deReturnButton.draw()
    end

    -- Pause menu
    if GamePaused then
    	-- Background
    	love.graphics.setColor(0, 0, 0, interface.pauseScreenAlpha)
    	love.graphics.rectangle("fill", 0, 0, SC_WIDTH, SC_HEIGHT)
    	-- Title
    	love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 32)
    	love.graphics.setColor(1, 1, 1, interface.pauseScreenAlpha+0.35)
    	love.graphics.print("GAME PAUSED", 355+(SC_WIDTH-960)/2, 120+(SC_HEIGHT-540)/2)
    	--- Buttons
    	interface.buttons.pContinueButton.draw()
    	interface.buttons.pQuitButton.draw()
    end
end

function interface.drawDiffSelect()
    -- Title
    love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 38)
    love.graphics.printf("Difficulty Select", (SC_WIDTH-960)/2, 45+(SC_HEIGHT-540)/2, 1000, "center")
    -- Buttons
    interface.buttons.dEasyButton.draw()
    interface.buttons.dMediumButton.draw()
    interface.buttons.dHardButton.draw()
end

function interface.drawMenu()
    -- Title
    love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 38)
    love.graphics.printf("Block Dash", (SC_WIDTH-960)/2, 45+(SC_HEIGHT-540)/2, 1000, "center")
    -- Buttons
    interface.buttons.mPlayButton.draw()
    interface.buttons.mSetButton.draw()
    interface.buttons.mQuitButton.draw()
end

function interface.drawSettings()
    -- Title
    love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 38)
    love.graphics.printf("Settings", (SC_WIDTH-960)/2, 45+(SC_HEIGHT-540)/2, 1000, "center")
    -- Buttons
    interface.buttons.sSoundButton.draw()
    interface.buttons.sReloadButton.draw()
    interface.buttons.sQuitButton.draw()
end

function interface.draw()
    if GameState == "game" then
       interface.drawGame()
    elseif GameState == "menu" then
       interface.drawMenu()
    elseif GameState == "settings" then
       interface.drawSettings()
   elseif GameState == "diffSelect" then
       interface.drawDiffSelect()
   end

    love.graphics.setColor(1, 1, 1, 1)
end

return interface
