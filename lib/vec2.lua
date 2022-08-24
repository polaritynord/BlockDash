local vec2 = {}

function vec2.new(xAxis, yAxis)
    local xPos = xAxis or 0
    local yPos = yAxis or 0
    local v = {
        x = xPos; y = yPos;
    }
    return v
end

return vec2
