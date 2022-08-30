local vec2 = require("lib/vec2")

local assets = require("scripts/assets")

local invSlot = {}

function invSlot.new()
    local s = {
	position = vec2.new();
	slot = 1;
	scale = 1;
    }

    function s.update(delta)
	-- Set scale
	if s.slot == Player.slot then
	    s.scale = s.scale + (1.15-s.scale) / (250 * delta) else
	    s.scale = s.scale + (1-s.scale) / (250 * delta) end
    end

    function s.draw()	
	local w = Player.weapons[s.slot]
	local width = assets.invSlotImg:getWidth()
	local height = assets.invSlotImg:getHeight()
	-- Draw base
	love.graphics.draw(
	    assets.invSlotImg, s.position.x+(SC_WIDTH-960), s.position.y+(SC_HEIGHT-540), 0,
	    2*s.scale, 2*s.scale, width/2, height/2
	)
	-- Draw slot weapon
	if not w then return end
	local image = assets.weapons[w.name.. "Img"]
	love.graphics.draw(
	    image, s.position.x+(SC_WIDTH-960)+4*s.scale, s.position.y+(SC_HEIGHT-540)+8*s.scale, 0,
	    1.5*s.scale, 1.5*s.scale, width/2, height/2
	)
    end

    return s
end

return invSlot
