local vec2 = require("lib/vec2")
local assets = require("scripts/assets")

-- Thanks to @pgimeno at https://love2d.org/forums/viewtopic.php?f=4&t=93768&p=250899#p250899
local function setFont(fontname, size)
    local key = fontname .. "\0" .. size
    local font = assets.fonts[key]
    if font then
      love.graphics.setFont(font)
    else
      font = love.graphics.setNewFont(fontname, size)
      assets.fonts[key] = font
    end
    return font
end

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
            font = font or "Minecraftia";
        }

        function textLabel:draw()
            setFont("fonts/" .. self.font .. ".ttf", scale)

            local x = self.position.x
            local y = self.position.y
            -- Find x position
            -- X Aligning
            if self.align:sub(1, 1) == "-" then
                -- Left align
                x = x - (SC_WIDTH-960)
            elseif self.align:sub(1, 1) == "+" then
                -- Right align
                x = x + (SC_WIDTH-960)
            elseif self.align:sub(1, 1) == "0" then
                -- Center align
                x = x + (SC_WIDTH-960)/2
            end
            -- Y Aligning
            if self.align:sub(2, 2) == "-" then
                -- Up align
                y = y - (SC_HEIGHT-540)
            elseif self.align:sub(2, 2) == "+" then
                -- Down align
                y = y + (SC_HEIGHT-540)
            elseif self.align:sub(1, 1) == "0" then
                -- Center align
                y = y + (SC_HEIGHT-540)/2
            end

            love.graphics.printf(self.text, x, y, 1000, self.begin)
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