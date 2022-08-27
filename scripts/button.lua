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
	local w = #t * 24
	print(w)
	love.graphics.print(t, b.position.x+(b.size.x/2)-(w/2), b.position.y+b.size.y/4)
	-- TODO figure out a way to center the text (maybe printf?)
    end

    return b
end

return button
