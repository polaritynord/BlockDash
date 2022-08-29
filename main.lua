local assets = require("scripts/assets")
local player = require("scripts/player")
local interface = require("scripts/interface")
local camera = require("scripts/camera")

local fullscreen = false

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
	    love.window.setMode(960, 540) end
    end
end

function GameLoad()
    GameState = "game"
    -- Globals
    assets.gameLoad()
    interface.gameLoad()
    GamePaused = false
    -- Setup player
    Player = player.new()
    Player.position.x = 480
    Player.position.y = 270
    Player.load()
    -- Setup camera
    Camera = camera.new()
    Camera.lockedTarget = Player
end

function love.load()
    love.graphics.setBackgroundColor(0.07, 0.07, 0.07, 1)
    love.graphics.setDefaultFilter("nearest", "nearest")
    -- Set custom cursor
    GameLoad()
    GameState = "menu"
end

function love.update(delta)
    SC_WIDTH, SC_HEIGHT = love.graphics.getDimensions()
    -- Set cursor
    if GameState == "menu" or GamePaused then
	love.mouse.setCursor(assets.cursorDefault)	
    else love.mouse.setCursor(assets.cursorCombat) end

    interface.update(delta)
    if GameState == "game" then
	Player.update(delta)
	Camera.update(delta)
    else end
end

function love.draw()
    if GameState == "game" then
	Player.draw()
    end
    interface.draw()
end

