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
	mouseClick = false;
    }

    function b.update(delta)
	local mx, my = love.mouse.getPosition()
	-- Check for mouse collision
	local w = b.size.x * b.scale ; local h = b.size.y * b.scale
	local x = mx > b.position.x-w/2+(SC_WIDTH-960)/2 and mx < b.position.x+(SC_WIDTH-960)/2 + w/2
	local y = my > b.position.y-h/2+(SC_HEIGHT-540)/2 and my < b.position.y+(SC_HEIGHT-540)/2 + h/2
	-- Click event
	if not love.mouse.isDown(1) and (x and y) and b.mouseClick and b.clickEvent then
	    b.clickEvent()
	end
	-- Hover animation
	local sm = 250 * delta
	if x and y then
	    b.scale = b.scale + (1.08-b.scale) / sm
	    -- Click animation
	    if love.mouse.isDown(1) then
		b.scale = b.scale + (1.03-b.scale) / sm	
		b.mouseClick = true
	    else b.mouseClick = false end
	else
	    b.scale = b.scale + (1-b.scale) / sm
	    b.mouseClick = false
	end
    end

    function b.draw()
	-- Button base
	love.graphics.setLineWidth(b.lineWidth)
	local w = b.size.x * b.scale ; local h = b.size.y * b.scale
	local x = b.position.x + (SC_WIDTH-960)/2
	local y = b.position.y + (SC_HEIGHT-540)/2

	love.graphics.line(x-w/2, y-h/2, x-w/2, y+h-h/2)
	love.graphics.line(x-w/2, y+h-h/2, x+w-w/2, y+h-h/2)
	love.graphics.line(x+w-w/2, y+h-h/2, x+w-w/2, y-h/2)
	love.graphics.line(x+w-w/2, y-h/2, x-w/2, y-h/2)
	-- Button text
	love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 24)
	local t = b.text
	if b.uppercaseText then t = string.upper(t) end
	-- Couldn't find a proper way to center the text in the rectangle, dammit
	-- Hope some dude with more than 2 braincells can figure a way out
	-- Probably won't happen but whatever
	love.graphics.print(t, x-w/2 + 16*b.scale, y-h/2 + (b.size.y/4)*b.scale)
    end

    return b
end

return button
