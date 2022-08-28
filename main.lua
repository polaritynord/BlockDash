local assets = require("scripts/assets")
local player = require("scripts/player")
local interface = require("scripts/interface")
local camera = require("scripts/camera")

local fullscreen = false

function love.keypressed(key, unicode)
    -- Pause key (TODO add game state check)
    if key == "escape" then
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


function love.load()
    love.graphics.setBackgroundColor(0.07, 0.07, 0.07, 1)
    love.graphics.setDefaultFilter("nearest", "nearest")
    -- Set custom cursor
    local cursor = love.mouse.newCursor("images/cursor.png", 12, 12)
    love.mouse.setCursor(cursor)
    -- Globals
    assets.gameLoad()
    interface.gameLoad()
    BulletImage = love.graphics.newImage("images/bullet.png")
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

function love.update(delta)
    SC_WIDTH, SC_HEIGHT = love.graphics.getDimensions()
    Player.update(delta)
    interface.update(delta)
    Camera.update(delta)
end

function love.draw()
    Player.draw()
    interface.draw()
end

