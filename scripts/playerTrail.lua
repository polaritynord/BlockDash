local vec2 = require("lib/vec2")

local playerTrail = {}

function playerTrail.new()
    local p = {
	position = vec2.new();
	alpha = 1;
	scale = 0.7;
	rotation = 0;
    }

    function p.update(delta, i)
	p.alpha = p.alpha - 1 * delta
	p.scale = p.scale - 2 * delta
	p.rotation = p.rotation + 5 * delta
	-- Despawn trail
	if p.scale < 0 then
	    table.remove(Player.trails, i)
	end
    end

    function p.draw()
	local width = Player.image:getWidth()
	local height = Player.image:getHeight()
	local x = (p.position.x - Camera.position.x) * Camera.zoom	
	local y = (p.position.y - Camera.position.y) * Camera.zoom
	love.graphics.setColor(0.6, 0.6, 0.6, p.alpha)
	love.graphics.draw(
	    Player.image, x, y, p.rotation,
	    p.scale*Camera.zoom, p.scale*Camera.zoom, width/2, height/2
	)
	love.graphics.setColor(1, 1, 1, 1)
    end

    return p
end

return playerTrail
