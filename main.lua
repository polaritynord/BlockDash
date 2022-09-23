local vec2 = require("lib/vec2")
local gradient = require("lib/gradient")
local zerpgui = require("lib/zerpgui")

local assets = require("scripts/assets")
local player = require("scripts/player")
Interface = require("scripts/interface")
ParticleManager = require("scripts/particleManager")
Settings = require("scripts/settings")
local camera = require("scripts/camera")
local weaponDrop = require("scripts/weaponDrop")
local weaponData = require("scripts/weaponData")
EnemyManager = require("scripts/enemyManager")
WaveManager = require("scripts/waveManager")
VD = require("lib/vd")

local fullscreen = false
CurrentShader = nil

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
end

function GameLoad()
    GameState = "game"
    -- Globals
    MotionSpeed = 1
    EnemyBullets = {}
    StatNames = {"Kills", "Dash Kills"}
    Stats = {
        kills = 0;
        dashKills = 0;
    }
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
    Interface.load()
    GamePaused = false
    -- Setup camera
    Camera = camera.new()
    Camera.lockedTarget = Player
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

local function drawWalls()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", (-700-Camera.position.x)*Camera.zoom, (-700-Camera.position.y)*Camera.zoom, 12, 1400)
    love.graphics.rectangle("fill", (-700-Camera.position.x)*Camera.zoom, (700-Camera.position.y)*Camera.zoom, 1400, 12)
    love.graphics.rectangle("fill", (700-Camera.position.x)*Camera.zoom, (-700-Camera.position.y)*Camera.zoom, 12, 1400)
    love.graphics.rectangle("fill", (-700-Camera.position.x)*Camera.zoom, (-700-Camera.position.y)*Camera.zoom, 1400, 12)
    love.graphics.setColor(1, 1, 1, 1)
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

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    -- Set custom cursor
    assets.load()
    assets.gameLoad()
    GameLoad()
    GameState = "menu"
end

function love.update(delta)
    SC_WIDTH, SC_HEIGHT = love.graphics.getDimensions()
    -- Set cursor
    if GameState == "menu" or GameState == "settings" or GamePaused then
        love.mouse.setCursor(assets.cursorDefault)
    else
		if CurrentShader then
	    	love.mouse.setCursor(assets.cursorCombatI) else
	    	love.mouse.setCursor(assets.cursorCombat) end
    end

    --Interface.update(delta)
    zerpgui:update(delta)
    if GameState == "game" then
		Player.update(delta)
		Camera.update(delta)
		updateWeaponDrops(delta)
		EnemyManager.update(delta)
        WaveManager.update(delta)
		ParticleManager.update(delta)
        updateEBullets(delta)
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
		drawWeaponDrops()
		Player.draw()
		EnemyManager.draw()
        drawEBullets()
        ParticleManager.draw()
        drawWalls()
    end
    --Interface.draw()
    zerpgui:draw()
    VD.draw()
end
