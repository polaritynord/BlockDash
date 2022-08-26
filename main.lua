local player = require("scripts/player")
local interface = require("scripts/interface")
local camera = require("scripts/camera")

function love.load()
    love.graphics.setBackgroundColor(0.07, 0.07, 0.07, 1)
    -- Set custom cursor
    local cursor = love.mouse.newCursor("images/cursor.png", 12, 12)
    love.mouse.setCursor(cursor)
    -- Globals
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
    Player.update(delta)
    interface.update()
    Camera.update(delta)
end

function love.draw()
    Player.draw()
    interface.draw()
end

