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
	w.position = vec2.new(Player.position.x, Player.position.y)	
    end

    function w.draw()
	local width = assets.playerImg:getWidth()
	local height = assets.playerImg:getHeight()
	local x = (w.position.x - Camera.position.x) * Camera.zoom	
	local y = (w.position.y - Camera.position.y) * Camera.zoom
	love.graphics.draw(
	    a, x, y, p.rotation,
	    Camera.zoom, Camera.zoom, width/2, height/2
	)
    end

    return w
end

return weaponSprite
