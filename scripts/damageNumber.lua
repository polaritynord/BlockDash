local vec2 = require("lib/vec2")

local damageNumber = {}

function damageNumber.new()
    local d = {
        position = vec2.new();
        scale = 1.8;
        alpha = 1;
        number = 10;
    }

    function d.update(delta, i)
        -- Despawn number
        if d.alpha < 0 then
            table.remove(Interface.damageNums, i)
            return
        end
        -- Update alpha & scale
        d.alpha = d.alpha - 2.2 * MotionSpeed * delta
        d.scale = d.scale - 1.8 * MotionSpeed * delta
        -- Move up
        d.position.y = d.position.y - 35 * MotionSpeed * delta
    end

    function d.draw()
        SetFont("fonts/Minecraftia.ttf", 20)
        love.graphics.setColor(1, 1, 1, d.alpha)
        local x = (d.position.x - Camera.position.x) * Camera.zoom
        local y = (d.position.y - Camera.position.y) * Camera.zoom
        love.graphics.print(tostring(math.floor(d.number)), x, y)
        love.graphics.setColor(1, 1, 1, 1)
    end

    return d
end

return damageNumber
