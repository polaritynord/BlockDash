local interface = {}

-- Pause key event
function love.keypressed(key)
    if key ~= "escape" then return end
    GamePaused = not GamePaused
end

function interface.update()

end

function interface.draw()
    love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 16)
    love.graphics.print(love.timer.getFPS() .. " FPS", 5, 5)
end

return interface
