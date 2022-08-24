local vec2 = require("lib/vec2")

local player = {}

function player.new()
    local p = {
        position = vec2.new();
        rotation = 0;
        image = love.graphics.newImage("images/player.png");
    }

    function p.update(delta)

    end

    function p.draw()
	local width = p.image:getWidth()
	local height = p.image:getHeight()
	love.graphics.draw(
	    p.image, p.position.x, p.position.y, p.rotation,
	    1, 1, width/2, height/2
	)
    end

    return p
end

return player
