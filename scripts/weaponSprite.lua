local utils = require("utils")
local vec2 = require("lib/vec2")

local assets = require("scripts/assets")

local weaponSprite = {}

function weaponSprite.new()
    local w = {
	position = vec2.new();
	rotation = 0;
    }
    
    function w.update()
	-- Point towards mouse
	local m = utils.getMousePosition()
	w.rotation = math.atan2(m.y - w.position.y, m.x - w.position.x)
	-- Set position
	w.position = vec2.new(Player.position.x + 12.5, Player.position.y + 3)	
    end

    function w.draw()
	local weapon = Player.weapons[Player.slot]
	if not weapon then return end

	-- Get image
	local image = assets.weapons[weapon.name .. "ImgI"]
	
	local width = image:getWidth()
	local height = image:getHeight()
	local x = (w.position.x - Camera.position.x) * Camera.zoom	
	local y = (w.position.y - Camera.position.y) * Camera.zoom
	--love.graphics.setColor(0, 0, 0, 1)	
	love.graphics.draw(
	    image, x, y, w.rotation,
	    Camera.zoom*1.7, Camera.zoom*1.7, width/2, height/2
	)
	love.graphics.setColor(1, 1, 1, 1)
    end

    return w
end

return weaponSprite
