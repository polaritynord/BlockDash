local vec2 = require("lib/vec2")
local bulletTrail = require("scripts/bulletTrail")

local bullet = {}

function bullet.new()
    local b = {
	position = vec2.new();
	rotation = 0;
	lifetime = 0;
	speed = 500;
	trails = {};
    }

    -- Trail related functions
    function b.updateTrail(delta)

    end

    function b.drawTrail()

    end

    -- Event functions
    
    function b.update(delta, i)
	b.lifetime = b.lifetime + delta
	-- Bullet despawning
	if b.lifetime > 3.5 then
	    table.remove(Player.bullets, i)
	    return
	end
	-- Movement
	b.position.x = b.position.x + math.cos(b.rotation) * b.speed * delta
	b.position.y = b.position.y + math.sin(b.rotation) * b.speed * delta
    end

    function b.draw()
	b.drawTrail()
	local width = BulletImage:getWidth()
	local height = BulletImage:getHeight()	
	local x = (b.position.x - Camera.position.x) * Camera.zoom	
	local y = (b.position.y - Camera.position.y) * Camera.zoom
	love.graphics.draw(
	    BulletImage, x, y, b.rotation,
	    Camera.zoom, Camera.zoom, width/2, height/2
	)
    end

    return b
end

return bullet
