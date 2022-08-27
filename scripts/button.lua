local vec2 = require("lib/vec2")

local button = {}

function button.new()
    local b = {
	position = vec2.new();
	size = vec2.new(50, 50);
	text = "Sample";
	scale = 1;
    }

    function b.update(delta)

    end

    function b.draw()
	-- Button base
	love.graphics.rectangle("line", b.position.x, b.position.y, 3, 3)
    end

    return b
end

return button
