local vec2 = require("lib/vec2")
local uniform = require("lib/uniform")

local bullet = require("scripts/bullet")

local player = {}

function player.new()
    local p = {
        position = vec2.new();
        rotation = 0;
        image = love.graphics.newImage("images/player.png");
	bullets = {};
	-- TODO: implement inventory & weapon system
	shootCooldown = 0;
    }

    -- Bullet related functions
    function p.updateBullets(delta)
	for i, v in ipairs(p.bullets) do
	    v.update(delta, i)
	end
    end

    function p.drawBullets()
	for _, v in ipairs(p.bullets) do
	    v.draw()
	end
    end

    -- Player related functions
    function p.shoot(delta)
	p.shootCooldown = p.shootCooldown + delta
	if not love.mouse.isDown(1) or p.shootCooldown < 0.05 then
	    return end
	-- Instance bullet
	local newBullet = bullet.new()
	newBullet.position = vec2.new(p.position.x, p.position.y)
	newBullet.rotation = p.rotation
	-- Offset the bullet a bit
	newBullet.position.x = newBullet.position.x + math.cos(p.rotation) * 25
	newBullet.position.y = newBullet.position.y + math.sin(p.rotation) * 25
	-- Spread bullet
	newBullet.rotation = newBullet.rotation + uniform(-1, 1) * 0.25
	-- Reset timer
	p.shootCooldown = 0
	-- Add to table
	p.bullets[#p.bullets+1] = newBullet
    end

    -- Event functions
    function p.update(delta)
	-- Point towards mouse
	mX, mY = love.mouse.getPosition()
	p.rotation = math.atan2(mY - p.position.y, mX - p.position.x)
	-- Functions
	p.shoot(delta)
	p.updateBullets(delta)
    end

    function p.draw()
	local width = p.image:getWidth()
	local height = p.image:getHeight()
	love.graphics.draw(
	    p.image, p.position.x, p.position.y, p.rotation,
	    1, 1, width/2, height/2
	)
	p.drawBullets()
    end

    return p
end

return player
