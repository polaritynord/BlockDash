local utils = require("utils")
local vec2 = require("lib/vec2")
local collision = require("lib/collision")
local uniform = require("lib/uniform")
local assets = require("scripts/assets")
local weaponSprite = require("scripts/weaponSprite")
local weaponData = require("scripts/weaponData")
local bullet = require("scripts/bullet")
local trail = require("scripts/trail")

local enemy = {}

function enemy.new()
    local e = {
    	position = vec2.new();
    	rotation = 0;
    	health = math.random(45, 70);
    	deathAnim = false;
    	alpha = 1;
    	scale = 1;
        weapons = {};
        weaponSprite = weaponSprite.new();
        slot = 1;
        facing = "right";
        width = 1;
        moveCooldown = 0;
        shootCooldown = 0;
        reloading = false;
        reloadTimer = 0;
        r = uniform(0.45, 1);
        trails = {};
        trailCooldown = 0;
        moving = false;
        dashVelocity = 0;
        dashTimer = 0;
        dashRot = 0;
        target = Player;
        dead = false;
        oldHealth = 100;
    }

    function e.dash(delta)
        -- Increment timer
    	e.dashTimer = e.dashTimer + delta
    	if e.dashTimer < 2.5 then return end
        local distance = utils.distanceTo(e.target.position, e.position)
        local w = e.weapons[e.slot]

        -- If far away from e.target and has a reasonable amount of ammo
        local farAway = distance > 370 and w.magAmmo > w.magSize / 3 and Difficulty > 1
        -- If e.target is reloading & near enemy (this shi sounds cool af)
        local huntTheHunter = distance < 212 and e.target.reloading and Difficulty > 2 and uniform(0, 1) < 0.7
        -- If low HP (escape combat)
        local escapeCombat = distance < 200 and e.health < e.firstHealth / 2
        -- If the player constantly shooting (flee from bullets)
        local bulletDodge = e.oldHealth > e.health and Difficulty > 2
        -- If near player & has low ammunition
        local fleeForReload =distance < 230 and w.magAmmo < w.magSize /3 and Difficulty > 1
        e.oldHealth = e.health
    	if farAway or huntTheHunter or escapeCombat or bulletDodge or fleeForReload then
    	    e.dashTimer = 0
    	    e.dashVelocity = 4200 * delta
            if not escapeCombat then
                e.dashRot = e.weaponSprite.rotation
            elseif bulletDodge then
                e.dashRot = e.weaponSprite.rotation + uniform(-math.pi/2, math.pi/2)
            else
                e.dashRot = e.weaponSprite.rotation + math.pi + uniform(-math.pi/9, math.pi/9)
            end
            e.reloading = false
    	    if e.facing == "left" then
	    		e.dashRot = e.dashRot - 135 end
    		assets.sounds.dash:play()
    	end
    end

    -- Trail related functions
    function e.updateTrail(delta)
    	-- Draw existing trails
    	for i, v in ipairs(e.trails) do
    	    v.update(delta, i)
    	end
    	-- Add new trails
    	e.trailCooldown = e.trailCooldown + delta
    	if e.trailCooldown < 0.025 or not e.moving then return end
    	-- Instance trail
    	local newTrail = trail.new()
    	newTrail.position = vec2.new(e.position.x, e.position.y)
        newTrail.parent = e
        newTrail.r = 1 ; newTrail.g = 0.12 ; newTrail.b = 0.12
        e.trailCooldown = 0
    	-- Add instance to table
    	e.trails[#e.trails+1] = newTrail
    end

    function e.drawTrail()
    	for _, v in ipairs(e.trails) do
    	    v.draw()
    	end
    end

    -- Enemy related functions
    function e.checkForDash()
        local pos = e.target.position
        local img = assets.playerImg
        local w = img:getWidth()
        local h = img:getHeight()
        local distance = utils.distanceTo(e.position, e.target.position)
        if distance < 50 and e.target.dashVelocity > 0.1 then
            -- Damage enemy
            local index = utils.indexOf(StatNames, "Dash Kills")
            e.health = e.health - 100
            Stats[index] = Stats[index] + 1
            index = utils.indexOf(StatNames, "Kills")
            Stats[index] = Stats[index] + 1
            Interface.dashKillAlpha = 1
            Interface.dashKillScale = 1.8
        end
    end

    function e.deathParticleTick(particle, delta)
        particle.position.x = particle.position.x + math.cos(particle.rotation) * particle.velocity * MotionSpeed * delta
        particle.position.y = particle.position.y + math.sin(particle.rotation) * particle.velocity * MotionSpeed * delta
        -- Decrease velocity
        particle.velocity = particle.velocity - particle.velocity * (particle.speed * delta)
    end

    function e.createDeathParticle()
        for i = 1, math.random(12, 25) do
            local size = uniform(3, 7)
            local speed = uniform(8, 9.3)
            local particle = ParticleManager.new(
                vec2.new(e.position.x, e.position.y), vec2.new(size, size),
                uniform(0.8, 1.7), {e.r, 0, 0, 1}, e.deathParticleTick
            )
            particle.velocity = uniform(75, 225)
            particle.rotation = uniform(0, 360)
            particle.speed = speed
        end
    end

    function e.setFacing(delta)
    	-- Set facing value
    	local m = e.target.position
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

    function e.shoot(delta)
        local distance = utils.distanceTo(e.target.position, e.position)
        if distance > 450 then return end
        -- Return if enemy isn't holding a weapon / reloading / out of ammo
    	local w = e.weapons[e.slot]
    	if not w or e.reloading or w.magAmmo < 1 then return end
    	-- Increment timer
        local speed = 2 / (Difficulty - 0.1)
    	e.shootCooldown = e.shootCooldown + delta * MotionSpeed / speed
    	if e.shootCooldown < w.shootTime then
    	    return end

        local spread = 0
        if w.weaponType == "shotgun" then
            local spread = -w.bulletSpread
        end
        for i = 1, w.bulletPerShot do
            -- Instance bullet
            local newBullet = bullet.new()
            newBullet.position = vec2.new(e.weaponSprite.position.x, e.weaponSprite.position.y)
            newBullet.rotation = e.weaponSprite.realRot
            -- Check where the enemy is facing
            local t = 1
            if e.facing == "left" then
                t = -1
                newBullet.rotation = newBullet.rotation + 135
            end
            -- Offset the bullet
            newBullet.position.x = newBullet.position.x + math.cos(e.weaponSprite.realRot) * w.bulletOffset * t
            newBullet.position.y = newBullet.position.y + math.sin(e.weaponSprite.realRot) * w.bulletOffset * t
            -- Spread bullet
            newBullet.rotation = newBullet.rotation + uniform(-1, 1) * w.bulletSpread
            -- Reset timer
            e.shootCooldown = 0
            -- Decrease mag ammo
            if w.weaponType == "shotgun" then
                w.magAmmo = w.magAmmo - (1/w.bulletPerShot)
            else
                w.magAmmo = w.magAmmo - 1
            end
            -- Shoot event for UI & Sprite
            e.weaponSprite.parentShot()
            -- Play sound
            assets.sounds.shoot:play()
            -- Special bullet attributes
            newBullet.speed = w.bulletSpeed
            newBullet.damage = w.bulletDamage
            newBullet.parent = e
            -- Set target
            newBullet.target = e.target
            -- Add to table
            EnemyBullets[#EnemyBullets+1] = newBullet
            -- Particle effects
            for i = 1, 4 do
                local particle = ParticleManager.new(
                    vec2.new(newBullet.position.x, newBullet.position.y),
                    vec2.new(8, 8),
                    0.5, {1, 0.36, 0}, e.shootParticleTick
                )
                particle.realRotation = e.weaponSprite.realRot + uniform(-0.35, 0.35)
                particle.speed = 250
                if e.facing == "left" then particle.speed = -particle.speed end
            end
        end
    end

    function e.shootParticleTick(particle, delta)
    	particle.position.x = particle.position.x + math.cos(particle.realRotation) * particle.speed * MotionSpeed * delta
    	particle.position.y = particle.position.y + math.sin(particle.realRotation) * particle.speed * MotionSpeed * delta
    	particle.rotation = particle.rotation + (4 * delta) * MotionSpeed
    	particle.size.x = particle.size.x - (8 * delta) * MotionSpeed
    	particle.size.y = particle.size.y - (8 * delta) * MotionSpeed
    	particle.alpha = particle.alpha - (8.5 * delta) * MotionSpeed
    end

    function e.move(delta)
        local distance = utils.distanceTo(e.target.position, e.position)
        local oldPos = vec2.new(e.position.x, e.position.y)
        -- Move by dash
        e.position.x = e.position.x + math.cos(e.dashRot) * e.dashVelocity * MotionSpeed
    	e.position.y = e.position.y + math.sin(e.dashRot) * e.dashVelocity * MotionSpeed
        if distance > 225 then
            local speed = 245
            e.position.x = e.position.x + math.cos(e.rotation) * speed * MotionSpeed * delta
            e.position.y = e.position.y + math.sin(e.rotation) * speed * MotionSpeed * delta
        end
        e.moving = oldPos.x ~= e.position.x and oldPos.y ~= e.position.y
    end

    function e.reload(delta)
    	local w = e.weapons[e.slot]
    	if not w then return end
    	-- Increment timer
    	if e.reloading then
    	    e.reloadTimer = e.reloadTimer + delta * MotionSpeed
    	    if e.reloadTimer > w.reloadTime then
        		-- Reload current weapon
        		e.reloading = false
        		w.magAmmo = w.magSize
            end
    	else
    	    if w.magAmmo < 1 then
        		e.reloading = true
        		e.reloadTimer = 0
    	    end
    	end
    end

    function e.load()
        e.weaponSprite.parent = e
        e.weaponSprite.position = vec2.new(e.position.x, e.position.y)
        e.firstHealth = e.health
        -- Define weapon
        local shotgunWave = math.floor(9 / Difficulty)
        local ARWave = math.floor(15 / Difficulty)
        local w
        if WaveManager.wave > ARWave then
            local c = math.random()
            if c < 0.25 then
                w = weaponData.shotgun.new()
            elseif c < 0.55 then
                w = weaponData.assaultRifle.new()
            else
                w = weaponData.pistol.new()
            end
        elseif WaveManager.wave > shotgunWave then
            local c = math.random()
            if c < 0.25 then
                w = weaponData.shotgun.new()
            else
                w = weaponData.pistol.new()
            end
        else
            w = weaponData.pistol.new()
        end
        e.weapons[e.slot] = w
        e.weapons[e.slot].magAmmo = e.weapons[e.slot].magSize
    end

    function e.update(delta, i)
    	-- Check for death
    	if e.health < 0.1 and not e.deathAnim then
    	    e.deathAnim = true
            e.dead = true
            -- Create death particles
            e.createDeathParticle()
        end

    	if e.deathAnim then
    	    e.scale = e.scale + 2.5 * MotionSpeed * delta
    	    e.alpha = e.alpha - 6 * MotionSpeed * delta
    	    -- Despawn
    	    if e.alpha < 0 then
		          table.remove(EnemyManager.enemies, i) end
            elseif e.target then
            e.rotation = math.atan2(e.target.position.y - e.position.y, e.target.position.x - e.position.x)
            -- Decrease dash velocity
        	e.dashVelocity = e.dashVelocity - e.dashVelocity * (delta / 0.06)
            if not e.target.dead then
                e.setFacing(delta)
                e.shoot(delta)
                e.move(delta)
                e.dash(delta)
                e.checkForDash()
                e.updateTrail(delta)
            else
                if e.target ~= Player then
                    -- Find a new dude to attack
                    for i = 1, EnemyManager.getCount() do
                        if EnemyManager.enemies[i] ~= e then
                            e.target = EnemyManager.enemies[i]
                            return
                        end
                    end
                end
            end
            e.reload(delta)
            e.weaponSprite.update(delta)
    	end
    end

    function e.draw()
    	local image = assets.playerImg
    	local width = image:getWidth()
    	local height = image:getHeight()
    	local x = (e.position.x - Camera.position.x) * Camera.zoom
    	local y = (e.position.y - Camera.position.y) * Camera.zoom
        e.drawTrail()
    	love.graphics.setColor(e.r, 0, 0, e.alpha)
    	love.graphics.draw(
    	    image, x, y, 0,
    	    e.scale*e.width, e.scale, width/2, height/2
    	)
    	love.graphics.setColor(1, 1, 1, 1)
        e.weaponSprite.draw()
    end

    return e
end

return enemy
