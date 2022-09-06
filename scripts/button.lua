local vec2 = require("lib/vec2")

local assets = require("scripts/assets")

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
	style = 1;
	mouseHover = false; -- only used for style 1
    }

    function b.update(delta)
	local mx, my = love.mouse.getPosition()
	if b.style == 1 then
	    -- Check for mouse collision
	    local t = b.text
	    if b.uppercaseText then t = string.upper(t) end
	    local w = b.size.x * b.scale ; local h = b.size.y * b.scale
	    -- Click event
	    if not love.mouse.isDown(1) and b.mouseHover and b.mouseClick and b.clickEvent then
		if Settings.sound then
		    assets.sounds.buttonClick:play() end
		b.clickEvent()
	    end
	    -- Hovering
	    if my > b.position.y+(SC_HEIGHT-540)/2 and my < b.position.y+(SC_HEIGHT-540)/2 + 24 then
		b.mouseHover = true
		if love.mouse.isDown(1) then
		    b.mouseClick = true else
		    b.mouseClick = false end
	    else
		b.mouseHover = false
		--b.mouseClick = false
	    end
	elseif b.style == 2 then
	    -- Check for mouse collision
	    local w = b.size.x * b.scale ; local h = b.size.y * b.scale
	    local x = mx > b.position.x-w/2+(SC_WIDTH-960)/2 and mx < b.position.x+(SC_WIDTH-960)/2 + w/2
	    local y = my > b.position.y-h/2+(SC_HEIGHT-540)/2 and my < b.position.y+(SC_HEIGHT-540)/2 + h/2
	    -- Click event
	    if not love.mouse.isDown(1) and (x and y) and b.mouseClick and b.clickEvent then
		if Settings.sound then
		    assets.sounds.buttonClick:play() end
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
    end

    function b.draw()
	if b.style == 1 then
	    -- Text
	    love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 22)
	    local t = b.text
	    if b.uppercaseText then t = string.upper(t) end
	    
	    local x = b.position.x + (SC_WIDTH-960)/2
	    local y = b.position.y + (SC_HEIGHT-540)/2
	    local w = 13 * #t
	    love.graphics.print(t, x-w/2, y)
	    
	    -- Arrow (when hovering)
	    if not b.mouseHover then return end
	    love.graphics.print(">", x-w/2-22, y)
	
	elseif b.style == 2 then
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
    end

    return b
end

return button
