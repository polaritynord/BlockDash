local utils = require("utils")
local vec2 = require("lib/vec2")
local uniform = require("lib/uniform")

local bullet = require("scripts/bullet")
local assets = require("scripts/assets")
local playerTrail = require("scripts/playerTrail")
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
	dashTimer = 0;
	invertShader = love.graphics.newShader[[ vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) { vec4 col = texture2D( texture, texture_coords ); return vec4(1-col.r, 1-col.g, 1-col.b, col.a); } ]];
	dashVelocity = 0;
	dashRot = 0;
	dashTimer = 111;
	dashTrailTimer = 0;
    }

    -- Trail related functions
    function p.updateTrail(delta)
	-- Draw existing trails
	for i, v in ipairs(p.trails) do
	    v.update(delta, i)
	end
	-- Add new trails
	p.trailCooldown = p.trailCooldown + delta
	if p.trailCooldown < 0.1 or (not p.moving and CurrentShader) then return end
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
    function p.setFacing(delta)
	-- Set facing value
	local m = utils.getMousePosition()
	if m.x > p.position.x then
	    p.facing = "right" else
	    p.facing = "left" end
	    -- Change width
	    local sm = 250 * delta
	    if p.facing == "right" then
		p.width = p.width + (1-p.width) / sm * MotionSpeed
	    else
		p.width = p.width + (-1-p.width) / sm * MotionSpeed
	    end
    end

    function p.sprint(delta)
	-- Increment timer
	p.sprintCooldown = p.sprintCooldown + delta 
	-- Get key input
	if love.keyboard.isDown("lshift") and p.moving and p.sprintCooldown > 3.5 and p.stamina > 0 then
	    p.sprinting = true
	    p.stamina = p.stamina - (30 * delta)
	    -- Reset timer
	    if p.stamina < 0 then
		p.sprintCooldown = 0 
		p.sprinting = false
	    end
	else
	    p.sprinting = false
	    -- Increase stamina
	    p.stamina = p.stamina + (24 * delta)
	    if p.stamina > 100 then p.stamina = 100 end
	end
    end

    function p.switchSlot()
	if p.reloading then return end
	-- Switch slot
	for i = 1, p.slotCount do
	    if not p.slotKeys[i] and love.keyboard.isDown(tostring(i)) then
		p.oldSlot = p.slot
		p.slot = i
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
	if not w or not love.keyboard.isDown("v") then return end
	-- Instance weaponDrop
	local newDrop = weaponDrop.new()
	newDrop.position = vec2.new(
	    p.position.x+math.cos(p.weaponSprite.rotation) * 45,
	    p.position.y+math.sin(p.weaponSprite.rotation) * 45
	)
	newDrop.weapon = w
	WeaponDrops[#WeaponDrops+1] = newDrop
	-- Clear current slot
	p.weapons[p.slot] = nil
    end

    function p.shoot(delta)
	-- Return if player isn't holding a weapon / reloading / out of ammo / slowmo mode
	local w = p.weapons[p.slot]
	if not w or p.reloading or w.magAmmo < 1 or MotionSpeed < 0.9 then return end
	-- Increment timer
	p.shootCooldown = p.shootCooldown + delta * MotionSpeed
	if not love.mouse.isDown(1) or p.shootCooldown < w.shootTime then
	    return end
	-- Instance bullet
	local newBullet = bullet.new()
	newBullet.position = vec2.new(p.weaponSprite.position.x, p.weaponSprite.position.y)
	newBullet.rotation = p.weaponSprite.rotation
	-- Check where the player is facing
	local t = 1
	if p.facing == "left" then
	    t = -1
	    newBullet.rotation = newBullet.rotation + 135
	end
	-- Offset the bullet
	newBullet.position.x = newBullet.position.x + math.cos(p.weaponSprite.rotation) * w.bulletOffset * t
	newBullet.position.y = newBullet.position.y + math.sin(p.weaponSprite.rotation) * w.bulletOffset * t
	-- Spread bullet
	newBullet.rotation = newBullet.rotation + uniform(-1, 1) * w.bulletSpread
	-- Reset timer
	p.shootCooldown = 0
	-- Decrease mag ammo
	w.magAmmo = w.magAmmo - 1
	-- Shoot event for UI & Sprite
	Interface.playerShot()
	p.weaponSprite.playerShot()
	-- Play sound
	assets.sounds.shoot:play()
	-- TODO special bullet attributes
	-- Add to table
	p.bullets[#p.bullets+1] = newBullet
	-- Particle effects
	for i = 1, 4 do
	    local particle = ParticleManager.new(
		vec2.new(newBullet.position.x, newBullet.position.y),
		vec2.new(8, 8),
		0.5, {1, 0.36, 0}, p.shootParticleTick
	    )
	    particle.realRotation = p.weaponSprite.rotation + uniform(-0.35, 0.35)
	    particle.speed = 250
	    if p.facing == "left" then particle.speed = -particle.speed end
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
		assets.sounds.reload:play()
	    end
	else
	    -- Get input
	    if (love.keyboard.isDown("r") or w.magAmmo < 1) and w.magAmmo < w.magSize then
		p.reloading = true
		p.reloadTimer = 0
	    end
	end
    end

    function p.movement(delta)
	-- Decrease dash velocity
	p.dashVelocity = p.dashVelocity - p.dashVelocity / (225 * delta)	
	
	if CurrentShader then return end
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
	-- Set p.moving
	p.moving = math.abs(p.velocity.x) > 0 or math.abs(p.velocity.y) > 0
	-- Increment velocity by dash
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
	love.graphics.setShader(nil)
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
	p.dashTimer = p.dashTimer + delta
	if p.dashTimer < 2.5 then return end
	if CurrentShader and love.mouse.isDown(1) then
	    p.dashTimer = 0
	    p.dashVelocity = 50
	    p.dashRot = p.weaponSprite.rotation
	    if p.facing == "left" then
		p.dashRot = p.dashRot - 135 end
	end
    end

    function p.motionControl(delta)
	if GamePaused or p.reloading then return end
	if love.keyboard.isDown("space") and p.dashTimer > 2.5 then
	    MotionSpeed = MotionSpeed + (0.25-MotionSpeed) / (200*delta)
	    CurrentShader = p.invertShader
	else
	    MotionSpeed = MotionSpeed + (1-MotionSpeed) / (200*delta)
	    CurrentShader = nil
	end
    end

    -- Event functions
    function p.load()
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
	-- Functions
	p.switchSlot()
	p.shoot(delta)
	p.movement(delta)
	p.setFacing(delta)
	p.reload(delta)
	p.motionControl(delta)
	p.dash(delta)
	p.drop()
	p.updateTrail(delta)
	p.updateBullets(delta)
	p.weaponSprite.update(delta)
    end

    function p.draw()
	if CurrentShader then
	    p.drawDashLine() end
	
	p.drawTrail()
	local width = assets.playerImg:getWidth()
	local height = assets.playerImg:getHeight()
	local x = (p.position.x - Camera.position.x) * Camera.zoom	
	local y = (p.position.y - Camera.position.y) * Camera.zoom
	love.graphics.setColor(0.13, 0.34, 0.8, 1)
	love.graphics.draw(
	    assets.playerImg, x, y, p.rotation,
	    Camera.zoom * p.width, Camera.zoom, width/2, height/2
	)
	love.graphics.setColor(1, 1, 1, 1)
	p.weaponSprite.draw()
	p.drawBullets()
    end

    return p
end

return player
