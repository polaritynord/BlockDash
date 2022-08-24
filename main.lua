local player = require("scripts/player")

function love.load()
    love.graphics.setBackgroundColor(0.07, 0.07, 0.07, 1)
    -- Set custom cursor
    local cursor = love.mouse.newCursor("images/cursor.png", 12, 12)
    love.mouse.setCursor(cursor)
    -- Global images
    BulletImage = love.graphics.newImage("images/bullet.png")
    -- Setup player
    Player = player.new()
    Player.position.x = 480
    Player.position.y = 270
end

function love.update(delta)
    Player.update(delta)
end

function love.draw()
    Player.draw()
end

