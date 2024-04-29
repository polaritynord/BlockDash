local vec2 = require("lib/vec2")

local assets = require("scripts/assets")

local hitmarker = {}

function hitmarker.new()
    local h = {
        position = vec2.new();
        scale = 1;
        rotation = 0;
    }

    function h.update(delta, i)
        -- Change scale
        h.scale = h.scale - 8 * delta
        -- Despawn
        if h.scale < 0.2 then
            table.remove(Interface.hitmarkers, i)
        end
    end

    function h.draw()
        local image = assets.hitmarkerImg
        local width = image:getWidth()
        local height = image:getHeight()
        love.graphics.push()
            love.graphics.setColor(PlayerColors[Save.playerColorSlot])
            love.graphics.draw(
                image, h.position.x, h.position.y, h.rotation,
                1.3*h.scale, 1.3*h.scale, width/2, height/2
            )
        love.graphics.pop()
    end

    return h
end

return hitmarker
