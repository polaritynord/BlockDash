local vec2 = require("lib/vec2")

local bulletTrail = {}

function bulletTrail.new()
    local b = {
	position = vec2.new();
	alpha = 1;
	scale = 1;
    }
    
    function b.update(delta)

    end

    function b.draw()

    end

    return b
end

return bulletTrail
