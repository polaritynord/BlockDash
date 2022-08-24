local vec2 = require("lib/vec2")

local bullet = {}

function bullet.new()
    local b = {
	position = vec2.new();
	rotation = 0;
	lifetime = 0;
	speed = 500;
    }
    
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
	local width = BulletImage:getWidth()
	local height = BulletImage:getHeight()
	love.graphics.draw(
	    BulletImage, b.position.x, b.position.y, b.rotation,
	    1, 1, width/2, height/2
	)
    end

    return b
end

return bullet
