local utils = require("utils")
local vec2 = require("lib/vec2")
local uniform = require("lib/uniform")
local collision = require("lib/collision")

local bullet = require("scripts/bullet")
local assets = require("scripts/assets")
local trail = require("scripts/trail")
local weaponData = require("scripts/weaponData")
local weaponSprite = require("scripts/weaponSprite")
local weaponDrop = require("scripts/weaponDrop")

local player = {}

function player.new()
    local p = {
        position = vec2.new();
        velocity = vec2.new();
    	facing = "right";
    	bullets = {};
    	trails = {};
    	weapons = {};
    	slotCount = 4;
    	slot = 1;
    	shootCooldown = 1000;
    	trailCooldown = 0;
    	weaponSprite = weaponSprite.new();
    	width = 1;
    	moving = false;
    	health = 100;
    	reloading = false;
    	reloadTimer = 0;
    	slotKeys = {false, false, false};
    	stamina = 100;
    	oldSlot = nil;
    	sprinting = false;
    	sprintCooldown = 3131;
    	invertShader = love.graphics.newShader[[ vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) { vec4 col = texture2D( texture, texture_coords ); return vec4(1-col.r, 1-col.g, 1-col.b, col.a); } ]];
    	dashVelocity = 0;
    	dashRot = 0;
    	dashCooldownTimer = 111;
		dashTimer = 999;
    	inReloadTimer = 0;
        dead = false;
        scale = 1;
        alpha = 1;
        deathTimer = 0;
        regenTimer = 0;
		hitBullets = 0;
		missedBullets = 0;
		aimLineWidth = 3;
    }

    -- Trail related functions
    function p.updateTrail(delta)
    	-- Draw existing trails
    	for i, v in ipairs(p.trails) do
    	    v.update(delta, i)
    	end
    	-- Add new trails
    	p.trailCooldown = p.trailCooldown + delta
		local cooldown = 0.05
		if p.dashVelocity > 0.1 then
			cooldown = 0
		end
    	if p.trailCooldown < cooldown or (not p.moving and CurrentShader) then return end
    	-- Instance trail
    	local newTrail = trail.new()
    	newTrail.position = vec2.new(p.position.x, p.position.y)
		local color = PlayerColors[Save.playerColorSlot]
		newTrail.r = color[1]
		newTrail.g = color[2]
		newTrail.b = color[3]
        newTrail.parent = p
		p.trailCooldown = 0
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
    function p.checkForDash()
        for _, v in ipairs(EnemyManager.enemies) do
            local image = assets.playerImg
            local w = image:getWidth()
            local h = image:getHeight()

            local a = p.position
            local b = v.position
            if collision(a.x-w/2, a.y-h/2, w, h, b.x-w/2, b.y-h/2, w, h) then
                -- Check if enemy is dashing
                if v.dashVelocity < 0.5 then return end
				local damageLowerer = (p.health/75)
                p.health = p.health - (25*damageLowerer)
				if Save.settings[utils.indexOf(SettingNames, "Sounds")] then
                	assets.sounds.dashDamage:play()
				end
            end
        end
    end

    function p.setFacing(delta)
    	-- Set facing value
    	local m = utils.getMousePosition()
    	if m.x > p.position.x then
    	    p.facing = "right" else
    	    p.facing = "left" end
    	    -- Change width
    	    local sm = 15 * delta
    	    if p.facing == "right" then
                p.width = p.width + (1-p.width) * sm * MotionSpeed
    	    else
                p.width = p.width + (-1-p.width) * sm * MotionSpeed
            end
    end

    function p.switchSlot()
    	--if p.reloading then return end
    	-- Switch slot
    	for i = 1, p.slotCount do
    	    if not p.slotKeys[i] and love.keyboard.isDown(tostring(i)) then
	    		p.oldSlot = p.slot
	    		p.slot = i
				p.reloading = false
    	    end
    	end
    	-- Quick slot switch
    	if not p.slotKeys[#p.slotKeys] and love.keyboard.isDown("q") and p.oldSlot then
    	    local newSlot = p.oldSlot
    	    p.oldSlot = p.slot
    	    p.slot = newSlot
    	end
    	-- Get key input
    	for i = 1, p.slotCount do
    	    p.slotKeys[i] = love.keyboard.isDown(tostring(i))
    	end
    	-- Get quick slot key input
    	p.slotKeys[#p.slotKeys] = love.keyboard.isDown("q")
        end

        function p.drop()
        	local w = p.weapons[p.slot]
        	if not w or not love.keyboard.isDown("v") or CurrentShader or p.reloading then return end
        	-- Instance weaponDrop
        	local newDrop = weaponDrop.new()
        	local rot = p.weaponSprite.rotation
        	if p.facing == "left" then rot = rot-135 end
        	newDrop.position = vec2.new(
        	    p.position.x+math.cos(rot) * 45,
        	    p.position.y+math.sin(rot) * 45
        	)
        	newDrop.weapon = w
        	WeaponDrops[#WeaponDrops+1] = newDrop
        	-- Clear current slot
        	p.weapons[p.slot] = nil
    end

    function p.shoot(delta)
    	-- Return if player isn't holding a weapon / reloading / out of ammo / slowmo mode
    	local w = p.weapons[p.slot]
    	if not w or w.magAmmo < 1 or MotionSpeed < 0.9 then return end
    	-- Increment timer
    	p.shootCooldown = p.shootCooldown + delta * MotionSpeed
    	if not love.mouse.isDown(1) or p.shootCooldown < w.shootTime then
    	    return end
        p.reloading = false
        local spread = 0
        if w.weaponType == "shotgun" then
            local spread = -w.bulletSpread
        end
        for i = 1, w.bulletPerShot do
        	-- Instance bullet
        	local newBullet = bullet.new()
        	newBullet.position = vec2.new(p.weaponSprite.position.x, p.weaponSprite.position.y)
        	newBullet.rotation = p.weaponSprite.realRot
        	-- Check where the player is facing
        	local t = 1
        	if p.facing == "left" then
        	    t = -1
        	    newBullet.rotation = newBullet.rotation + 135
        	end
        	-- Offset the bullet
        	newBullet.position.x = newBullet.position.x + math.cos(p.weaponSprite.realRot) * w.bulletOffset * t
        	newBullet.position.y = newBullet.position.y + math.sin(p.weaponSprite.realRot) * w.bulletOffset * t
        	-- Spread bullet
            if w.weaponType == "auto" then
    	        newBullet.rotation = newBullet.rotation + uniform(-1, 1) * w.bulletSpread
            else
                newBullet.rotation = newBullet.rotation + spread
                spread = spread + w.bulletSpread
            end
        	-- Reset timer
        	p.shootCooldown = 0
        	-- Decrease mag ammo
            if w.weaponType == "shotgun" then
                w.magAmmo = w.magAmmo - (1/w.bulletPerShot)
            else
                w.magAmmo = w.magAmmo - 1
            end
        	-- Shoot event for UI & Sprite
        	p.weaponSprite.parentShot()
        	-- Play sound
			if Save.settings[utils.indexOf(SettingNames, "Sounds")] then
        		assets.sounds.shoot:play()
			end
        	-- Special bullet attributes
        	newBullet.speed = w.bulletSpeed
            newBullet.damage = w.bulletDamage
            newBullet.parent = p
			-- Set target
            newBullet.target = "enemies"
        	-- Add to table
        	p.bullets[#p.bullets+1] = newBullet
			-- Set line width
			p.aimLineWidth = 5 
        	-- Particle effects
        	for i = 1, 4 do
        	    local particle = ParticleManager.new(
            		vec2.new(newBullet.position.x, newBullet.position.y),
            		vec2.new(8, 8),
            		0.5, {1, 0.36, 0}, p.shootParticleTick
        	    )
        	    particle.realRotation = p.weaponSprite.realRot + uniform(-0.35, 0.35)
        	    particle.speed = 250
        	    if p.facing == "left" then particle.speed = -particle.speed end
        	end
        end
    end

    function p.shootParticleTick(particle, delta)
    	particle.position.x = particle.position.x + math.cos(particle.realRotation) * particle.speed * MotionSpeed * delta
    	particle.position.y = particle.position.y + math.sin(particle.realRotation) * particle.speed * MotionSpeed * delta
    	particle.rotation = particle.rotation + (4 * delta) * MotionSpeed
    	particle.size.x = particle.size.x - (8 * delta) * MotionSpeed
    	particle.size.y = particle.size.y - (8 * delta) * MotionSpeed
    	particle.alpha = particle.alpha - (8.5 * delta) * MotionSpeed
    end

    function p.reload(delta)
    	if CurrentShader then return end
    	local w = p.weapons[p.slot]
    	if not w then return end
    	-- Increment timer
    	if p.reloading then
    	    p.reloadTimer = p.reloadTimer + delta * MotionSpeed
    	    if p.reloadTimer > w.reloadTime then
        		-- Reload current weapon
        		p.reloading = false
        		w.magAmmo = w.magSize
        		-- Play reload sound
				if Save.settings[utils.indexOf(SettingNames, "Sounds")] then
        			assets.sounds.reload:play()
				end
            end
    	else
    	    -- Get input
    	    if not love.mouse.isDown(1) and not CurrentShader and w.magAmmo < w.magSize then
				p.inReloadTimer = p.inReloadTimer + delta
		    end
    	    local intelliReload = w.magAmmo < w.magSize and not CurrentShader and Save.settings[utils.indexOf(SettingNames, "Auto Reload")]
    	    if (love.keyboard.isDown("r") or w.magAmmo < 1 or (intelliReload and p.inReloadTimer > 0.75 and not love.mouse.isDown(1))) and w.magAmmo < w.magSize then
				p.reloading = true
				p.reloadTimer = 0
				p.inReloadTimer = 0
    	    end
    	end
    end

    function p.movement(delta)
    	local speed = 235
    	p.velocity = vec2.new()
    	-- Get key input
    	if p.dashVelocity < 0.1 then
    	    if love.keyboard.isDown("right", "d") then
    		p.velocity.x = p.velocity.x + 1 end
    	    if love.keyboard.isDown("left", "a") then
    		p.velocity.x = p.velocity.x - 1 end
    	    if love.keyboard.isDown("up", "w") then
    		p.velocity.y = p.velocity.y - 1 end
    	    if love.keyboard.isDown("down", "s") then
    		p.velocity.y = p.velocity.y + 1 end
    	end
    	-- Set p.moving
    	p.moving = math.abs(p.velocity.x) > 0 or math.abs(p.velocity.y) > 0
    	-- Increment velocity by dash
		if p.dashTimer < 0.07 then
			p.dashVelocity = 28--0.25 / delta
		else
			p.dashVelocity = 0
		end
    	p.velocity.x = p.velocity.x + math.cos(p.dashRot) * p.dashVelocity
    	p.velocity.y = p.velocity.y + math.sin(p.dashRot) * p.dashVelocity
    	-- Normalize velocity
    	if math.abs(p.velocity.x) == math.abs(p.velocity.y) then
    	    p.velocity.x = p.velocity.x / 1.25
    	    p.velocity.y = p.velocity.y / 1.25
    	end
    	-- Move by velocity
    	p.position.x = p.position.x + speed * p.velocity.x * MotionSpeed * delta
    	p.position.y = p.position.y + speed * p.velocity.y * MotionSpeed * delta
    end

    function p.drawDashLine()
    	local w = 20
    	local pos = vec2.new((p.position.x-Camera.position.x)*Camera.zoom, (p.position.y-Camera.position.y)*Camera.zoom)
    	local mousePos = utils.getMousePosition()
    	local rot = p.weaponSprite.rotation
    	if p.facing == "left" then rot = rot - 135 end
    	-- Disable shader
    	love.graphics.setShader()
    	-- Draw
    	love.graphics.setColor(1, 0, 0, 1)
    	repeat
    	    love.graphics.setLineWidth(w)
    	    local oldPos = vec2.new(pos.x, pos.y)
    	    pos.x = pos.x + math.cos(rot) * 10
    	    pos.y = pos.y + math.sin(rot) * 10
    	    love.graphics.line(oldPos.x, oldPos.y, pos.x, pos.y)
    	    w = w - 3
    	until w < 0
    	love.graphics.setColor(1, 1, 1, 1)
    	-- Re-enable shader
    	love.graphics.setShader(CurrentShader)
    end

    function p.dash(delta)
    	p.dashCooldownTimer = p.dashCooldownTimer + delta
    	p.dashTimer = p.dashTimer + delta
    	if p.dashCooldownTimer < 2.5 then return end
    	if CurrentShader and not love.mouse.isDown(2) then
    	    p.dashCooldownTimer = 0
			p.dashTimer = 0
    	    p.dashRot = p.weaponSprite.rotation
    	    if p.facing == "left" then
	    		p.dashRot = p.dashRot - 135 end
			
			if Save.settings[utils.indexOf(SettingNames, "Sounds")] then
    			assets.sounds.dash:play()
			end
    	end
    end

    function p.motionControl(delta)
    	if GamePaused then return end
    	if love.mouse.isDown(2) and p.dashCooldownTimer > 2.5 then
    	    p.reloading = false
    	    MotionSpeed = 0.25
    	    CurrentShader = p.invertShader
    	else
    	    MotionSpeed = 1
    	    CurrentShader = nil
    	end
    end

    function p.deathParticleTick(particle, delta)
        particle.position.x = particle.position.x + math.cos(particle.rotation) * particle.velocity * MotionSpeed * delta
        particle.position.y = particle.position.y + math.sin(particle.rotation) * particle.velocity * MotionSpeed * delta
        -- Decrease velocity
        particle.velocity = particle.velocity - particle.velocity * (particle.speed * delta)
    end

    function p.regenerate(delta)
        -- Increment timer
        if p.health < 100 then
            p.regenTimer = p.regenTimer + MotionSpeed * delta
            -- Reset timer if player dashed
            if p.dashVelocity > 0.2 then
                p.regenTimer = 0 end
            -- Regenerate
            if p.regenTimer > 2.5 then
                p.health = p.health + 8 * MotionSpeed * delta
                if p.health > 100 then p.health = 100 end
            end
        else
            p.regenTimer = 0
        end
    end

	function p.drawLine()
		if not p.weapons[p.slot] or p.reloading or not Save.settings[utils.indexOf(SettingNames, "Aim Line")] then return end
		local x, y = love.mouse.getPosition()
		local pos = vec2.new(p.position.x-Camera.position.x, p.position.y-Camera.position.y)
		love.graphics.setColor(1, 1, 1, 0.1 + (p.aimLineWidth/3)-1)
		love.graphics.setLineStyle("smooth")
		love.graphics.setLineWidth(p.aimLineWidth)
		if utils.distanceTo(pos, vec2.new(x, y)) > 120 then
			local rot = p.weaponSprite.realRot
			if p.facing == "left" then
				rot = rot + math.pi
			end
			love.graphics.line({pos.x, pos.y, pos.x+math.cos(rot)*120, pos.y+math.sin(rot)*120})
		else
			love.graphics.line({pos.x, pos.y, x, y})
		end
	end
    -- Event functions
    function p.load()
        p.weaponSprite.parent = p
    	-- Generate weapon slots
    	for i = 1, p.slotCount do
    	    p.weapons[#p.weapons+1] = nil end
    	-- Create inputKeys table
    	for i = 1, #p.weapons do
    	    p.slotKeys[i] = false
    	end
    	-- Quick slot switch
    	p.slotKeys[#p.slotKeys+1] = false
    end

    function p.update(delta)
    	if GamePaused then return end
        if p.health >= 1 then
			Time = Time + delta
			p.aimLineWidth = p.aimLineWidth + (3-p.aimLineWidth) * (8.25 * delta)
        	p.switchSlot()
        	p.shoot(delta)
        	p.movement(delta)
        	p.setFacing(delta)
        	p.reload(delta)
        	p.dash(delta)
        	p.motionControl(delta)
        	p.drop()
        	p.updateTrail(delta)
        	p.updateBullets(delta)
            p.regenerate(delta)
            p.checkForDash()
            p.weaponSprite.update(delta)
        else
            -- Create particles
            if not p.dead then
                for i = 1, math.random(12, 25) do
                    local size = uniform(3, 7)
					local speed = uniform(8, 9.3)
                    local particle = ParticleManager.new(
                        vec2.new(p.position.x, p.position.y), vec2.new(size, size),
                        uniform(0.8, 1.7), {0.13, 0.34, 0.8, 1}, p.deathParticleTick
                    )
                    particle.velocity = uniform(75, 225)
                    particle.rotation = uniform(0, 360)
					particle.speed = speed
                end
            end
            -- Variables
            p.dead = true
            CurrentShader = nil
            MotionSpeed = 1
            p.deathTimer = p.deathTimer + delta
            -- Animation
            p.scale = p.scale + 2.5 * MotionSpeed * delta
    	    p.alpha = p.alpha - 6 * MotionSpeed * delta
        end
    end

    function p.draw()
    	if CurrentShader then
    	    p.drawDashLine() end

        if not p.dead then
	       p.drawTrail() end
		
		if not GamePaused and not CurrentShader and not p.dead then
			p.drawLine() end
    	-- Draw self
		local width = assets.playerImg:getWidth()
    	local height = assets.playerImg:getHeight()
    	local x = (p.position.x - Camera.position.x) * Camera.zoom
    	local y = (p.position.y - Camera.position.y) * Camera.zoom
		local color = PlayerColors[Save.playerColorSlot]
    	love.graphics.setColor(color[1], color[2], color[3], p.alpha)
    	love.graphics.draw(
    	    assets.playerImg, x, y, p.rotation,
    	    Camera.zoom * p.width * p.scale, Camera.zoom * p.scale, width/2, height/2
    	)
    	love.graphics.setColor(1, 1, 1, 1)
        if not p.dead then
    	       p.weaponSprite.draw() end
    	p.drawBullets()
    end

    return p
end

return player
