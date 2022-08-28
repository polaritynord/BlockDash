local vec2 = require("lib/vec2")

local assets = require("scripts/assets")

local invSlot = {}

function invSlot.new()
    local s = {
	position = vec2.new();
    }

    function s.update(delta)

    end

    function s.draw()	
	local width = assets.invSlotImg:getWidth()
	local height = assets.invSlotImg:getHeight()
	love.graphics.draw(
	    assets.invSlotImg, s.position.x+(SC_WIDTH-960), s.position.y+(SC_HEIGHT-540), 0,
	    2, 2, width/2, height/2
	)
    end

    return s
end

return invSlot
