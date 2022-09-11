local vec2 = require("lib/vec2")

local assets = require("scripts/assets")

local trail = {}

function trail.new()
    local p = {
    	position = vec2.new();
    	alpha = 0.7;
    	scale = 0.7;
    	rotation = 0;
        r = 0.12 ; g = 0.12, b = 1;
        parent;
    }

    function p.update(delta, i)
    	if GamePaused then return end
    	p.alpha = p.alpha - 1.5 * MotionSpeed * delta
    	p.scale = p.scale - 2 * MotionSpeed * delta
    	p.rotation = p.rotation + 5 * MotionSpeed * delta
    	-- Despawn trail
    	if p.scale < 0 then
    	    table.remove(p.parent.trails, i)
    	end
    end

    function p.draw()
    	local width = assets.playerImg:getWidth()
    	local height = assets.playerImg:getHeight()
    	local x = (p.position.x - Camera.position.x) * Camera.zoom
    	local y = (p.position.y - Camera.position.y) * Camera.zoom
    	love.graphics.setColor(p.r, p.g, p.b, p.alpha)
    	love.graphics.draw(
    	    assets.playerImg, x, y, p.rotation,
    	    p.scale*Camera.zoom*Player.width, p.scale*Camera.zoom, width/2, height/2
    	)
    	love.graphics.setColor(1, 1, 1, 1)
    end

    return p
end

return trail
