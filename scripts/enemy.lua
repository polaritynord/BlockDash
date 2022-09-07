local utils = require("utils")
local vec2 = require("lib/vec2")
local assets = require("scripts/assets")

local enemy = {}

function enemy.new()
    local e = {
	position = vec2.new();
	rotation = 0;
	health = 100;
    }

    function c.update(delta)
    
    end

    function c.draw()

    end
    
    return e
end

return enemy
