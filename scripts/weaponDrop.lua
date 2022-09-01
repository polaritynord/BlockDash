local utils = require("utils")
local vec2 = require("lib/vec2")

local assets = require("scripts/assets")

local weaponDrop = {}

function weaponDrop.new()
    local w = {
	position = vec2.new();
	scale = 1;
	weapon;
	beingObtained = false;
    }

    function w.update(delta, i)
	if not w.weapon then return end
	if beingObtained then

	else
	    local distance = utils.distanceTo(w.position, Player.position)
	    -- Change scale
	    if distance < 63 then
		w.scale = w.scale + (1.45-w.scale) / (250 * delta) else
		w.scale = w.scale + (1-w.scale) / (250 * delta) end
	end
    end

    function w.draw()
	if not w.weapon then return end
	local image = assets.weapons[w.weapon.name .. "Img"]
	local width = image:getWidth() ; local height = image:getHeight()
	local x = (w.position.x - Camera.position.x) * Camera.zoom
	local y = (w.position.y - Camera.position.y) * Camera.zoom
	love.graphics.draw(
	    image, x, y, w.rotation,
	    1.45*w.scale, 1.45*w.scale, width/2, height/2
	)
    end

    return w
end

return weaponDrop
