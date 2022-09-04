local assets = require("scripts/assets")
local player = require("scripts/player")
Interface = require("scripts/interface")
ParticleManager = require("scripts/particleManager")
local camera = require("scripts/camera")
local weaponDrop = require("scripts/weaponDrop")
local weaponData = require("scripts/weaponData")

local fullscreen = false
local currentShader

function love.keypressed(key, unicode)
    -- Pause key
    if key == "escape" and GameState == "game" then
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
    local temp = weaponDrop.new()
    temp.weapon = weaponData.pistol.new()
    temp.weapon.magAmmo = 13
    temp.position.x = 600 ; temp.position.y = 300
    WeaponDrops[#WeaponDrops+1] = temp
    -- Setup interface
    Interface.gameLoad()
    GamePaused = false
    -- Setup camera
    Camera = camera.new()
    Camera.lockedTarget = Player
    -- Shaders (test)
    InvertShader = love.graphics.newShader[[ vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) { vec4 col = texture2D( texture, texture_coords ); return vec4(1-col.r, 1-col.g, 1-col.b, col.a); } ]]
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

local function motionControl(delta)
    if GamePaused then return end
    if love.keyboard.isDown("space") then
	MotionSpeed = MotionSpeed + (0.25-MotionSpeed) / (200*delta)
	currentShader = InvertShader
    else
	MotionSpeed = MotionSpeed + (1-MotionSpeed) / (200*delta)
	currentShader = nil
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
	if currentShader then
	    love.mouse.setCursor(assets.cursorCombatI) else
	    love.mouse.setCursor(assets.cursorCombat) end
    end

    Interface.update(delta)
    if GameState == "game" then
	Player.update(delta)
	Camera.update(delta)
	updateWeaponDrops(delta, i)
	motionControl(delta)
	ParticleManager.update(delta)
    else end
end

function love.draw()
    if currentShader then
	love.graphics.setBackgroundColor(1-0.07, 1-0.07, 1-0.07, 1)
    else
	love.graphics.setBackgroundColor(0.07, 0.07, 0.07, 1)
    end
    love.graphics.setShader(currentShader)
    if GameState == "game" then
	drawWeaponDrops()
	Player.draw()
	ParticleManager.draw()
    end
    Interface.draw()
end

