local vec2 = require("lib/vec2")

local utils = {}

function utils.getMousePosition()
    local mX, mY = love.mouse.getPosition()
    return vec2.new((mX + Camera.position.x) * Camera.zoom, (mY + Camera.position.y) * Camera.zoom)
end

return utils
