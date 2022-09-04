local vec2 = require("lib/vec2")

local assets = require("scripts/assets")

local bullet = {}

function bullet.new()
    local b = {
	position = vec2.new();
	rotation = 0;
	lifetime = 0;
	speed = 500;
	trails = {};
	trailCooldown = 0;
    }

    -- Event functions
    function b.update(delta, i)
	if GamePaused then return end
	b.lifetime = b.lifetime + delta
	-- Bullet despawning
	if b.lifetime > 3.5 then
	    table.remove(Player.bullets, i)
	    return
	end
	-- Movement
	b.position.x = b.position.x + math.cos(b.rotation) * b.speed * MotionSpeed * delta
	b.position.y = b.position.y + math.sin(b.rotation) * b.speed * MotionSpeed * delta
    end

    function b.draw()
	local image = assets.bulletImg
	local width = image:getWidth()
	local height = image:getHeight()	
	local x = (b.position.x - Camera.position.x) * Camera.zoom	
	local y = (b.position.y - Camera.position.y) * Camera.zoom
	love.graphics.draw(
	    image, x, y, b.rotation,
	    Camera.zoom, Camera.zoom, width/2, height/2
	)
    end

    return b
end

return bullet
