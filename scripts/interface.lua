local interface = {}

function interface.update()

end

function interface.draw()
    love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 16)
    love.graphics.print(love.timer.getFPS() .. " FPS", 5, 5)
end

return interface
