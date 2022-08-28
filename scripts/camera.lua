local vec2 = require("lib/vec2")

local camera = {}

function camera.new()
    local c = {
	position = vec2.new();
	zoom = 1;
	lockedTarget = nil;
	smoothness = 250;
    }
    
    function c.update(delta)
	if GamePaused then return end
	-- Camera following
	if not c.lockedTarget then return end
	c.position.x = c.position.x + (c.lockedTarget.position.x - c.position.x-(SC_WIDTH/2)/c.zoom) / (c.smoothness * delta)
	c.position.y = c.position.y + (c.lockedTarget.position.y - c.position.y-(SC_HEIGHT/2)/c.zoom) / (c.smoothness * delta)
	--c.zoom = c.zoom - 0.0015
    end
    
    return c
end

return camera
