local utils = require("utils")
local vec2 = require("lib/vec2")
local uniform = require("lib/uniform")
local assets = require("scripts/assets")

local enemy = {}

function enemy.new()
    local e = {
	position = vec2.new();
	rotation = 0;
	health = 100;
	deathAnim = false;
	alpha = 1;
	scale = uniform(0.7, 1.15);
    }

    function e.update(delta, i)
	-- Check for death
	if e.health < 0.1 then
	    e.deathAnim = true end
	
	if e.deathAnim then
	    e.scale = e.scale - 0.42 * MotionSpeed * delta 
	    e.alpha = e.alpha - 0.55 * MotionSpeed * delta 
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
	    e.scale, e.scale, width/2, height/2
	)
	love.graphics.setColor(1, 1, 1, 1)
    end
    
    return e
end

return enemy
