local vec2 = require("lib/vec2")

local assets = require("scripts/assets")
local player = require("scripts/player")
Interface = require("scripts/interface")
ParticleManager = require("scripts/particleManager")
Settings = require("scripts/settings")
local camera = require("scripts/camera")
local weaponDrop = require("scripts/weaponDrop")
local weaponData = require("scripts/weaponData")
EnemyManager = require("scripts/enemyManager")

local fullscreen = false
local invertShader 
CurrentShader = nil

function dropWeapon(weapon, position)
    local newWeapon = weapon.new()
    local drop = weaponDrop.new()
    drop.weapon = newWeapon
    drop.position = position
    WeaponDrops[#WeaponDrops+1] = drop
end

function love.keypressed(key, unicode)
    -- Pause key
    if key == "escape" and GameState == "game" and not CurrentShader then
	GamePaused = not GamePaused end
    -- Fullscreen key
    if key == "f11" then
	fullscreen = not fullscreen
	love.window.setFullscreen(fullscreen, "desktop")
	-- Set window dimensions to default
	if not fullscreen then
	    love.window.setMode(960, 540, {resizable=true}) end
    end
end

function GameLoad()
    GameState = "game"
    -- Globals
    assets.load()
    assets.gameLoad()
    MotionSpeed = 1
    -- Setup player
    Player = player.new()
    Player.position.x = 480
    Player.position.y = 270
    Player.load()
    -- Weapon drops
    WeaponDrops = {}
    dropWeapon(weaponData.pistol, vec2.new(600, 450))
    dropWeapon(weaponData.assaultRifle, vec2.new(650, 450))
    -- Enemies
    EnemyManager.load()
    -- Setup interface
    Interface.gameLoad()
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

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    -- Set custom cursor
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

    Interface.update(delta)
    if GameState == "game" then
	Player.update(delta)
	Camera.update(delta)
	updateWeaponDrops(delta, i)
	EnemyManager.update(delta)
	ParticleManager.update(delta)
    else end
end

function love.draw()
    if CurrentShader then
	love.graphics.setBackgroundColor(1-0.07, 1-0.07, 1-0.07, 1)
    else
	love.graphics.setBackgroundColor(0.07, 0.07, 0.07, 1)
    end
    love.graphics.setShader(CurrentShader)
    if GameState == "game" then
	drawWeaponDrops()
	Player.draw()
	EnemyManager.draw()
	ParticleManager.draw()
    end
    Interface.draw()
end

