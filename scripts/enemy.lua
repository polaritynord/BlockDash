local utils = require("utils")
local vec2 = require("lib/vec2")
local collision = require("lib/collision")
local uniform = require("lib/uniform")
local assets = require("scripts/assets")
local weaponSprite = require("scripts/weaponSprite")
local weaponData = require("scripts/weaponData")

local enemy = {}

function enemy.new()
    local e = {
    	position = vec2.new();
    	rotation = 0;
    	health = 100;
    	deathAnim = false;
    	alpha = 1;
    	scale = uniform(0.7, 1.15);
        weapons = {weaponData.pistol.new()};
        weaponSprite = weaponSprite.new();
        slot = 1;
        facing = "right";
        width = 1;
    }

    function e.checkForDash()
        local pos = Player.position
        local img = assets.playerImg
        local w = img:getWidth()
        local h = img:getHeight()
        local c = collision(pos.x-(w*e.scale)/2, pos.y-(h*e.scale)/2, w, h, e.position.x-w/2, e.position.y-h/2, w, h)
        if c and Player.dashVelocity > 0.5 then
            -- Damage enemy
            e.health = e.health - 100
        end
    end

    function e.deathParticleTick(particle, delta)
        particle.position.x = particle.position.x + math.cos(particle.rotation) * particle.velocity * MotionSpeed * delta
        particle.position.y = particle.position.y + math.sin(particle.rotation) * particle.velocity * MotionSpeed * delta
        -- Decrease velocity
        particle.velocity = particle.velocity - particle.velocity / (250 * delta)
    end

    function e.createDeathParticle()
        for i = 1, math.random(12, 25) do
            local size = uniform(3, 7)
            local particle = ParticleManager.new(
                vec2.new(e.position.x, e.position.y), vec2.new(size, size),
                uniform(0.8, 1.7), {1, 0, 0, 1}, e.deathParticleTick
            )
            particle.velocity = uniform(75, 225)
            particle.rotation = uniform(0, 360)
        end
    end

    function e.setFacing(delta)
    	-- Set facing value
    	local m = Player.position
    	if m.x > e.position.x then
    	    e.facing = "right" else
    	    e.facing = "left" end
	    -- Change width
	    local sm = 250 * delta
	    if e.facing == "right" then
            e.width = e.width + (1-e.width) / sm * MotionSpeed
	    else
            e.width = e.width + (-1-e.width) / sm * MotionSpeed
        end
    end

    function e.load()
        e.weaponSprite.parent = e
    end

    function e.update(delta, i)
    	-- Check for death
    	if e.health < 0.1 and not e.deathAnim then
    	    e.deathAnim = true
            -- Create death particles
            e.createDeathParticle()
        end

        e.checkForDash()
    	if e.deathAnim then
    	    e.scale = e.scale + 2.5 * MotionSpeed * delta
    	    e.alpha = e.alpha - 6 * MotionSpeed * delta
    	    -- Despawn
    	    if e.alpha < 0 then
		          table.remove(EnemyManager.enemies, i) end
    	else
    	    -- Point towards player
    	    local pos = Player.position
    	    e.rotation = math.atan2(pos.y - e.position.y, pos.x - e.position.x)
    	    -- Move towards payer if far away
    	    -- IDEA: Hard difficulty enemies have the ability to dash
    	    local distance = utils.distanceTo(Player.position, e.position)
    	    if distance > 225 then
        		local speed = 245
        		e.position.x = e.position.x + math.cos(e.rotation) * speed * MotionSpeed * delta
        		e.position.y = e.position.y + math.sin(e.rotation) * speed * MotionSpeed * delta
    	    end
            e.setFacing(delta)
            e.weaponSprite.update(delta)
    	end
    end

    function e.draw()
    	local image = assets.playerImg
    	local width = image:getWidth()
    	local height = image:getHeight()
    	local x = (e.position.x - Camera.position.x) * Camera.zoom
    	local y = (e.position.y - Camera.position.y) * Camera.zoom
    	love.graphics.setColor(1, 0, 0, e.alpha)
    	love.graphics.draw(
    	    image, x, y, e.rotation,
    	    e.scale*e.width, e.scale, width/2, height/2
    	)
    	love.graphics.setColor(1, 1, 1, 1)
        e.weaponSprite.draw()
    end

    return e
end

return enemy
