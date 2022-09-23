local vec2 = require("lib/vec2")

local zerpgui = {
    canvases = {};
}

function zerpgui:newCanvas(pos)
    local canvas = {
        position = pos or vec2.new();
        elements = {};
    }

    function canvas:update(delta)
       -- Update elements
        for _, v in ipairs(self.elements) do
            v:update(delta)
        end
    end

    function canvas:draw()
        -- Draw elements
        for _, v in ipairs(self.elements) do
            v:draw()
        end
    end

    return canvas
end

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