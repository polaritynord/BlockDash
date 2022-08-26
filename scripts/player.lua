local vec2 = require("lib/vec2")
local uniform = require("lib/uniform")

local utils = require("utils")
local bullet = require("scripts/bullet")
local playerTrail = require("scripts/playerTrail")
local weaponData = require("scripts/weaponData")

local player = {}

function player.new()
    local p = {
        position = vec2.new();
        velocity = vec2.new();
	rotation = 0;
        image = love.graphics.newImage("images/player.png");
	bullets = {};
	trails = {};
	-- TODO: implement inventory & weapon system
	weapons = {nil, nil, nil};
	slot = 1;
	shootCooldown = 1000;
	trailCooldown = 0;
    }

    -- Trail related functions
    function p.updateTrail(delta)
	-- Draw exsiting trails
	for i, v in ipairs(p.trails) do
	    v.update(delta, i)
	end
	-- Add new trails
	p.trailCooldown = p.trailCooldown + delta
	if p.trailCooldown < 0.1 then return end
	-- Instance trail
	local newTrail = playerTrail.new()
	newTrail.position = vec2.new(p.position.x, p.position.y)
	-- Add instance to table
	p.trails[#p.trails+1] = newTrail
    end

    function p.drawTrail()
	for _, v in ipairs(p.trails) do
	    v.draw()
	end
    end

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
	-- Return player isn't holding a weapon
	if not p.weapons[p.slot] then return end
	-- Increment timer
	p.shootCooldown = p.shootCooldown + delta
	local w = p.weapons[p.slot]
	if not love.mouse.isDown(1) or p.shootCooldown < w.shootTime then
	    return end
	-- Instance bullet
	local newBullet = bullet.new()
	newBullet.position = vec2.new(p.position.x, p.position.y)
	newBullet.rotation = p.rotation
	-- Offset the bullet a bit
	newBullet.position.x = newBullet.position.x + math.cos(p.rotation) * 25
	newBullet.position.y = newBullet.position.y + math.sin(p.rotation) * 25
	-- Spread bullet
	newBullet.rotation = newBullet.rotation + uniform(-1, 1) * w.bulletSpread
	-- Reset timer
	p.shootCooldown = 0
	-- TODO special bullet attributes
	-- Add to table
	p.bullets[#p.bullets+1] = newBullet
    end

    function p.movement(delta)
	local speed = 200
	p.velocity = vec2.new()
	-- Get key input
	if love.keyboard.isDown("right", "d") then
	    p.velocity.x = p.velocity.x + 1 end
	if love.keyboard.isDown("left", "a") then
	    p.velocity.x = p.velocity.x - 1 end
	if love.keyboard.isDown("up", "w") then
	    p.velocity.y = p.velocity.y - 1 end
	if love.keyboard.isDown("down", "s") then
	    p.velocity.y = p.velocity.y + 1 end
	-- Normalize velocity
	if math.abs(p.velocity.x) == math.abs(p.velocity.y) then
	    p.velocity.x = p.velocity.x / 1.25
	    p.velocity.y = p.velocity.y / 1.25
	end
	-- Move by velocity
	p.position.x = p.position.x + speed * p.velocity.x * delta
	p.position.y = p.position.y + speed * p.velocity.y * delta
    end

    -- Event functions
    function p.load()
	p.weapons[1] = weaponData.pistol	
    end

    function p.update(delta)
	if GamePaused then return end
	-- Point towards mouse
	local m = utils.getMousePosition()
	p.rotation = math.atan2(m.y - p.position.y, m.x - p.position.x)
	-- Functions
	p.shoot(delta)
	p.movement(delta)
	p.updateTrail(delta)
	p.updateBullets(delta)
    end

    function p.draw()
	p.drawTrail()
	local width = p.image:getWidth()
	local height = p.image:getHeight()
	local x = (p.position.x - Camera.position.x) * Camera.zoom	
	local y = (p.position.y - Camera.position.y) * Camera.zoom
	love.graphics.draw(
	    p.image, x, y, p.rotation,
	    Camera.zoom, Camera.zoom, width/2, height/2
	)
	p.drawBullets()
    end

    return p
end

return player
