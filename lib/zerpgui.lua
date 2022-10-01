local vec2 = require("lib/vec2")
local collision = require("lib/collision")
local assets = require("scripts/assets")

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

-- Thanks to @pgimeno at https://love2d.org/forums/viewtopic.php?f=4&t=93768&p=250899#p250899
function SetFont(fontname, size)
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

-- Zerpgui functions
function zerpgui:newCanvas(pos)
    local canvas = {
        position = pos or vec2.new();
        elements = {};
        enabled = true;
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
            SetFont("fonts/" .. self.font .. ".ttf", self.size)

            local p = calculateAlign(self.position, self.align)
            
            love.graphics.printf(self.text, p.x, p.y, 1000, self.begin)
        end

        self[name] = textLabel
        self.elements[#self.elements+1] = textLabel
    end

    function canvas:newImage(name, position, rotation, source, scale, align)
        local image = {
            position = position or vec2.new();
            rotation = rotation or 0;
            source = source or nil;
            scale = scale or 1;
            align = align or "--";
        }

        function image:draw()
            if not self.source then return end
            local p = calculateAlign(self.position, self.align)
            local width = self.source:getWidth()
            local height = self.source:getHeight()
            love.graphics.draw(
                self.source, p.x, p.y, self.rotation,
                self.scale, self.scale, width/2, height/2
            )
        end

        self[name] = image
        self.elements[#self.elements+1] = image
    end

    function canvas:newButton(name, position, size, style, text, textSize, hoverEvent, clickEvent, align)
        local button = {
            position = position or vec2.new();
            style = style or 1;
            text = text or "Button";
            font = font or "Minecraftia";
            align = align or "--";
            mouseHover = false;
            size = size or vec2.new(45, 150);
            textSize = textSize or 24;
            hoverEvent = hoverEvent;
            clickEvent = clickEvent;
            mouseClick = false;
            lineWidth = 3;
        }

        function button:update(delta)
            -- Click event
            if not love.mouse.isDown(1) and self.mouseHover and self.mouseClick and self.clickEvent then
                if Settings.sound then assets.sounds.buttonClick:play() end
                self.clickEvent()
            end
            local p = calculateAlign(self.position, self.align)
            local mx = love.mouse.getX()
            local my = love.mouse.getY()
            if self.style == 1 then
                -- Check for hover
                if my > p.y and my < p.y + self.textSize then
                    self.mouseHover = true
                    self.mouseClick = love.mouse.isDown(1)
                else
                    self.mouseHover = false
                    self.mouseClick = false
                end
            else
                if mx > p.x and mx < p.x + self.size.x and my > p.y and my< p.y + self.size.y then
                    self.lineWidth = self.lineWidth + (8-self.lineWidth) / (250 * delta)
                    self.mouseHover = true
                    self.mouseClick = love.mouse.isDown(1)
                else
                    self.lineWidth = self.lineWidth + (3-self.lineWidth) / (250 * delta)
                    self.mouseHover = false
                    self.mouseClick = false
                end
            end
        end

        function button:draw()
            local p = calculateAlign(self.position, self.align)
            if self.style == 1 then
                -- Draw text
                local t = ""
                if self.mouseHover then
                    t = "> "
                end
                t = t .. self.text
                
                SetFont("fonts/" .. self.font .. ".ttf", self.textSize)
                love.graphics.printf(t, p.x, p.y, 1000, "left")
            else
                -- Draw base
                love.graphics.setLineWidth(self.lineWidth)
                love.graphics.rectangle("line", p.x, p.y, self.size.x, self.size.y)

                -- Draw text
                SetFont("fonts/" .. self.font .. ".ttf", self.textSize)
                love.graphics.printf(self.text, p.x + #self.text*self.textSize/2, p.y+self.size.y/4, 1000, "left")
            end
        end

        self[name] = button
        self.elements[#self.elements+1] = button
    end

    -- Canvas events
    function canvas:update(delta)
        -- Update elements
        for _, v in ipairs(self.elements) do
            if v.update then v:update(delta) end
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
        if v.enabled then v:update(delta) end
    end
end

function zerpgui:draw()
    -- Draw canvases
    for _, v in ipairs(self.canvases) do
        if v.enabled then v:draw() end
    end
end

return zerpgui