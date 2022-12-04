local vec2 = require("lib/vec2")
local uniform = require("lib/uniform")
local ser = require("lib/ser")
local utils   = require("utils")

local assets = require("scripts/assets")
local player = require("scripts/player")
Interface = require("scripts/interface")
ParticleManager = require("scripts/particleManager")
local camera = require("scripts/camera")
local weaponDrop = require("scripts/weaponDrop")
local weaponData = require("scripts/weaponData")
EnemyManager = require("scripts/enemyManager")
WaveManager = require("scripts/waveManager")

local fullscreen = false
CurrentShader = nil
local starPositions = {}

local function dropWeapon(weapon, position)
    local newWeapon = weapon.new()
    local drop = weaponDrop.new()
    drop.weapon = newWeapon
    drop.position = position
    WeaponDrops[#WeaponDrops+1] = drop
end

function love.keypressed(key, unicode)
    -- Pause key
    if key == "escape" and GameState == "game" and not CurrentShader and not Player.dead then
        GamePaused = not GamePaused end
    -- Fullscreen key
    if key == "f11" then
       fullscreen = not fullscreen
          love.window.setFullscreen(fullscreen, "desktop")
        -- Set window dimensions to default
    	if not fullscreen then
    	    love.window.setMode(960, 540, {resizable=true})
        end
    end
    -- Toggle debug menu
    if key == "f1" and GameState == "game" then
        Interface.debug.enabled = not Interface.debug.enabled
    end
end

local function drawStars()
    for i in pairs(starPositions) do
        love.graphics.rectangle("fill", starPositions[i][1]-Camera.position.x, starPositions[i][2]-Camera.position.y, starPositions[i][3], starPositions[i][4])
    end
end

function GameLoad()
    GameState = "game"
    -- Globals
    MotionSpeed = 1
    Time = 0
    EnemyBullets = {}
    StatNames = {"Time", "Waves", "Accuracy", "Kills", "Dash Kills"}
    Stats = {0, 0, 0, 0, 0}
    -- Setup player
    Player = player.new()
    Player.load()
    -- Weapon drops
    WeaponDrops = {}
    dropWeapon(weaponData.pistol, vec2.new(100, 100))
    dropWeapon(weaponData.assaultRifle, vec2.new(150, 100))
    dropWeapon(weaponData.shotgun, vec2.new(100, 150))
    -- Enemies
    EnemyManager.load()
    WaveManager.load()
    -- Setup interface
    -- Setup camera
    Camera = camera.new()
    Camera.lockedTarget = Player
    drawStars()
    --Player.health = 0
end

function SaveGame()
    love.filesystem.write("save", ser(Save))
end

local function updateWeaponDrops(delta)
    for i, v in ipairs(WeaponDrops) do
	       v.update(delta, i)
    end
end

local function drawWeaponDrops()
    for _, v in ipairs(WeaponDrops) do
	       v.draw()
    end
end

local function updateEBullets(delta)
    for i, v in ipairs(EnemyBullets) do
        v.update(delta, i)
    end
end

local function drawEBullets(delta)
    for _, v in ipairs(EnemyBullets) do
        v.draw()
    end
end

local function loadSave()
    -- SAVE FILE MANAGEMENT
    SettingNames = {"Sounds", "Auto Reload"}
    Save = nil
    if love.filesystem.getInfo("save") then
        print("Existing save detected, reading file...")
        -- Read from save
        local data = love.filesystem.load("save")()
        Save = data
    else
        print("Creating a new save file...")
        -- Create new save file
        Save = {
            settings = {};
            highScores = {};
        }
        for i = 1, #SettingNames do
            Save.settings[i] = true
        end
        -- Write to save
        love.filesystem.write("save", ser(Save))
    end
end

local function setStats(delta)
    -- Waves
    Stats[utils.indexOf(StatNames, "Waves")] = WaveManager.wave - 1
    -- Accuracy
    local num = math.floor((Player.hitBullets / (Player.hitBullets + Player.missedBullets))*100)
    if tostring(num) == "nan" then
        num = 0
    end
    Stats[utils.indexOf(StatNames, "Accuracy")] = "%" .. num
    -- Time
    local min = math.floor(Time / 60)
    local sec = math.floor(Time - min*60)
    local index = utils.indexOf(StatNames, "Time")
    Stats[index] = min .. "m" .. sec .. "s"
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    -- Set custom cursor
    assets.load()
    assets.gameLoad()
    GameLoad()
    GameState = "menu"
    loadSave()
    Interface:load()
    GamePaused = false
    -- Create star positions
    for _ = 1, 700 do
        local size = uniform(1.7, 3.45)
        starPositions[#starPositions+1] = {uniform(-1920, 1920), uniform(-1080, 1080), size, size}
    end
end

function love.update(delta)
    setStats(delta)
    SC_WIDTH, SC_HEIGHT = love.graphics.getDimensions()
    -- Set cursor
    if GameState ~= "game" or GamePaused then
        love.mouse.setCursor(assets.cursorDefault)
    else
		if CurrentShader then
	    	love.mouse.setCursor(assets.cursorCombatI) else
	    	love.mouse.setCursor(assets.cursorCombat) end
    end

    Interface:update(delta)
    if GameState == "game" then
		Player.update(delta)
		Camera.update(delta)
		updateWeaponDrops(delta)
		EnemyManager.update(delta)
        WaveManager.update(delta)
		ParticleManager.update(delta)
        updateEBullets(delta)
    end
    -- Hide debug menu if no in-game
    if GameState ~= "game" then
        Interface.debug.enabled = false
    end
end

function love.draw()
    if CurrentShader then
		love.graphics.setBackgroundColor(0.93, 0.93, 0.93, 1)
    else
		love.graphics.setBackgroundColor(0.07, 0.07, 0.07, 1)
    end
    love.graphics.setShader(CurrentShader)
    if GameState == "game" then
        drawStars()
		drawWeaponDrops()
		Player.draw()
		EnemyManager.draw()
        drawEBullets()
        ParticleManager.draw()
    end
    Interface:draw()
end
