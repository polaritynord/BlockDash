local vec2 = require("lib/vec2")
local collision = require("lib/collision")

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
    	damage = 10;
    }

    -- Event functions
    function b.update(delta, i)
    	if GamePaused then return end
    	b.lifetime = b.lifetime + delta * MotionSpeed
    	-- Bullet despawning
    	if b.lifetime > 3.5 then
    	    table.remove(Player.bullets, i)
    	    return
    	end
    	-- Check for collision for enemies
    	for _, v in ipairs(EnemyManager.enemies) do
    	    local image = assets.bulletImg
    	    local w1 = image:getWidth()
    	    local h1 = image:getHeight()
    	    local eImg = assets.playerImg
    	    local w2 = eImg:getWidth() * v.scale
    	    local h2 = eImg:getHeight() * v.scale

    	    local p = b.position
    	    local p2 = v.position
    	    if collision(p.x, p.y, w1, h1, p2.x, p2.y, w2, h2) then
                v.health = v.health - b.damage
                table.remove(Player.bullets, i)
    		    return
    	    end
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
