local vec2 = require("lib/vec2")

local button = {}

function button.new()
    local b = {
	position = vec2.new();
	size = vec2.new(195, 70);
	text = "sample";
	scale = 1;
	lineWidth = 3;
	uppercaseText = true;
    }

    function b.update(delta)

    end

    function b.draw()
	-- Button base
	love.graphics.setLineWidth(b.lineWidth)
	love.graphics.line(b.position.x, b.position.y, b.position.x, b.position.y+b.size.y)
	love.graphics.line(b.position.x, b.position.y+b.size.y, b.position.x+b.size.x, b.position.y+b.size.y)
	love.graphics.line(b.position.x+b.size.x, b.position.y+b.size.y, b.position.x+b.size.x, b.position.y)
	love.graphics.line(b.position.x+b.size.x, b.position.y, b.position.x, b.position.y)
	-- Button text
	love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 24)
	local t = b.text
	if b.uppercaseText then t = string.upper(t) end
	-- Couldn't find a proper way to center the text in the rectangle, dammit
	-- Hope some dude with more than 2 braincells can figure a way out
	-- Probably won't happen but whatever
	love.graphics.print(t, b.position.x + 16, b.position.y + b.size.y/4)
    end

    return b
end

return button
