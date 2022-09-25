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

local function calculateAlign(position, align)
    local x = position.x
    local y = position.y
    -- Find x position
    -- X Aligning
    if align:sub(1, 1) == "-" then
        -- Left align
        x = x - (SC_WIDTH-960)
    elseif align:sub(1, 1) == "+" then
        -- Right align
        x = x + (SC_WIDTH-960)
    elseif align:sub(1, 1) == "0" then
        -- Center align
        x = x + (SC_WIDTH-960)/2
    end
    -- Y Aligning
    if align:sub(2, 2) == "-" then
        -- Up align
        y = y - (SC_HEIGHT-540)
    elseif align:sub(2, 2) == "+" then
        -- Down align
        y = y + (SC_HEIGHT-540)
    elseif align:sub(2, 2) == "0" then
        -- Center align
        y = y + (SC_HEIGHT-540)/2
    end

    return vec2.new(x, y)
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
    function canvas:newTextLabel(name, position, text, size, align, begin, font)
        local textLabel = {
            position = position or vec2.new();
            text = text or "Sample";
            size = size or 24;
            align = align or "--"; -- "- -" means it will get aligned in bottom left of screen
            begin = begin or "left";
            font = font or "Minecraftia";
        }

        function textLabel:draw()
            setFont("fonts/" .. self.font .. ".ttf", self.size)

            local p = calculateAlign(self.position, self.align)
            
            love.graphics.printf(self.text, p.x, p.y, 1000, self.begin)
        end

        self[name] = textLabel
        self.elements[#self.elements+1] = textLabel
    end

    function canvas:newButton(name, position, size, style, text, textSize, align)
        local button = {
            position = position or vec2.new();
            style = style or 1;
            text = text or "Button";
            font = font or "Minecraftia";
            align = align or "--";
            mouseHover = false;
            size = size or vec2.new(45, 150);
            textSize = textSize or 24;
        }

        function button:update(delta)
        end

        function button:draw()
            if self.style == 1 then
                -- Draw text
                local t = ""
                if self.mouseHover then
                    t = "> "
                end
                t = t .. self.text
                
                setFont("fonts/" .. self.font .. ".ttf", self.textSize)
                local p = calculateAlign(self.position, self.align)
                love.graphics.printf(self.text, p.x, p.y, 1000, "left")
            else

            end
        end

        self.elements[name] = button
        self.elements[#self.elements+1] = button
    end

    -- Canvas events
    function canvas:update(delta)
       -- Update elements
        for _, v in ipairs(self.elements) do
            --if v.update then v:update(delta) end
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