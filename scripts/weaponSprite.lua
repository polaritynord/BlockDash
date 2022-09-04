local utils = require("utils")
local vec2 = require("lib/vec2")

local assets = require("scripts/assets")

local weaponSprite = {}

function weaponSprite.new()
    local w = {
	position = vec2.new();
	rotation = 0;
	width = 1;
	shootRot = 0;
    }

    function w.playerShot()
	local weapon = Player.weapons[Player.slot]
	local recoil = weapon.recoil
	if Player.facing == "right" then recoil = -recoil end
	w.shootRot = recoil
    end
    
    function w.update(delta)
	-- Decrease recoil rotation
	w.shootRot = w.shootRot - w.shootRot / (250 * delta) / MotionSpeed
	-- Set position
	if Player.facing == "right" then
	    w.position.x = Player.position.x + 12.5
	    w.width = 1
	else
	    w.position.x = Player.position.x - 12.5
	    w.width = -1
	end
	w.position.y = Player.position.y + 3
	
	if Player.reloading then
	    -- Reload animation
	    w.rotation = w.rotation + 12 * MotionSpeed * delta
	else
	    -- Point towards mouse
	    local m = utils.getMousePosition()
	    w.rotation = math.atan2(m.y - w.position.y, m.x - w.position.x)
	    -- Invert rotation if player is facing left
	    if Player.facing == "left" then 
		w.rotation = w.rotation + 135 
		-- This works just fine but I'm not sure its the best way to do this
	    end
	end
    end

    function w.draw()
	local weapon = Player.weapons[Player.slot]
	if not weapon then return end

	-- Get image
	local image = assets.weapons[weapon.name .. "Img"]
	
	local width = image:getWidth()
	local height = image:getHeight()
	local x = (w.position.x - Camera.position.x) * Camera.zoom	
	local y = (w.position.y - Camera.position.y) * Camera.zoom
	
	love.graphics.draw(
	    image, x, y, w.rotation+w.shootRot,
	    Camera.zoom*1.7*w.width, Camera.zoom*1.7, width/2, height/2
	)
	love.graphics.setColor(1, 1, 1, 1)
    end

    return w
end

return weaponSprite
