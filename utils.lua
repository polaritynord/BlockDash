local vec2 = require("lib/vec2")

local utils = {}

function utils.getMousePosition()
    local mX, mY = love.mouse.getPosition()
    local pos = vec2.new((mX + Camera.position.x) / Camera.zoom, (mY + Camera.position.y) / Camera.zoom)
    return pos
end

function utils.vec2Add(a, b)
    local c = vec2.new();
    c.x = a.x + b.x ; c.y = a.y + b.y
    return c
end

function utils.distanceTo(vec1, vec2)
    local x = vec1.x - vec2.x
    local y = vec1.y - vec2.y
    return math.sqrt(x*x + y*y)
end

-- Taken from https://stackoverflow.com/questions/38282234/returning-the-index-of-a-value-in-a-lua-table
function utils.indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

-- Thanks to https://stackoverflow.com/questions/2421695/first-character-uppercase-lua
function utils.capitalize(str)
    return (str:gsub("^%l", string.upper))
end


return utils
