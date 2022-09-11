local utils = require("utils")
local vec2 = require("lib/vec2")

local assets = require("scripts/assets")

local weaponSprite = {}

function weaponSprite.new()
    local w = {
    	position = vec2.new();
    	rotation = 0;
        realRot = 0;
    	width = 1;
    	recoil = 0;
        parent;
    }

    function w.parentShot()
    	local weapon = w.parent.weapons[w.parent.slot]
    	local recoil = weapon.recoil
    	if w.parent.facing == "right" then recoil = -recoil end
    	w.recoil = recoil
    end

    function w.update(delta)
    	-- Decrease recoil rotation
    	w.recoil = w.recoil - w.recoil / (250 * delta) / MotionSpeed
    	-- Set position
    	if w.parent.facing == "right" then
    	    w.position.x = w.parent.position.x + 12.5
    	    w.width = 1
    	else
    	    w.position.x = w.parent.position.x - 12.5
    	    w.width = -1
    	end
    	w.position.y = w.parent.position.y + 3

        local target
        if w.parent == Player then
            target = utils.getMousePosition()
        else
            target = Player.position
        end

        local rot = math.atan((target.y - w.position.y)/(target.x - w.position.x))
        w.realRot = w.realRot + (rot-w.realRot) / (200 * delta)
    	if w.parent.reloading then
    	    -- Reload animation
    	    w.rotation = w.rotation + 12 * MotionSpeed * delta
    	else
    	    w.rotation = w.realRot
    	end
    end

    function w.draw()
    	local weapon = w.parent.weapons[w.parent.slot]
        local dash = CurrentShader and w.parent == Player
    	if not weapon or dash then return end

    	-- Get image
    	local image = assets.weapons[weapon.name .. "Img"]

    	local width = image:getWidth()
    	local height = image:getHeight()
    	local x = (w.position.x - Camera.position.x) * Camera.zoom
    	local y = (w.position.y - Camera.position.y) * Camera.zoom

    	love.graphics.draw(
    	    image, x, y, w.rotation+w.recoil,
    	    Camera.zoom*1.7*w.width, Camera.zoom*1.7, width/2, height/2
    	)
    	love.graphics.setColor(1, 1, 1, 1)
    end

    return w
end

return weaponSprite
