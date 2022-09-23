local vec2 = require("lib/vec2")
local assets = require("scripts/assets")

local zerpgui = {
    canvases = {};
}

-- Zerpgui functions
function zerpgui:newCanvas(pos)
    local canvas = {
        position = pos or vec2.new();
        elements = {};
    }

    -- Elements
    function canvas:newTextLabel(name, position, text, scale, align, begin, font)
        local textLabel = {
            name = name;
            position = position or vec2.new();
            text = text or "Sample";
            scale = scale or 1;
            align = align or "--"; -- "- -" means it will get aligned in bottom left of screen
            begin = begin or "left";
            font = font or assets.font;
        }

        function textLabel:draw()
            love.graphics.scale(self.scale)
            love.graphics.setFont(self.font)
            love.graphics.printf(self.text, self.position.x, self.position.y, 1000, self.begin)
            love.graphics.scale(1)
        end

        self.elements[#self.elements+1] = textLabel
    end

    function canvas:newImage()
        
    end

    function canvas:newRectangle()
        
    end

    -- Canvas events
    function canvas:update(delta)
       -- Update elements
        for _, v in ipairs(self.elements) do
            
        end
    end

    function canvas:draw()
        -- Draw elements
        for _, v in ipairs(self.elements) do
            v:draw()
        end
    end

    -- Add to table
    self.canvases[#self.canvases+1] = canvas
    return canvas
end

-- Zerpgui events
function zerpgui:update(delta)
    -- Update canvases
    for _, v in ipairs(self.canvases) do
        v:update(delta)
    end
end

function zerpgui:draw()
    -- Draw canvases
    for _, v in ipairs(self.canvases) do
        v:draw()
    end
end

return zerpgui