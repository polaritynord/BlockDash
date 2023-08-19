local vec2 = require("lib/vec2")

local assets = require("scripts/assets")

local particle = {}

function particle.new()
    local p = {
    	position = vec2.new();
    	size = vec2.new();
    	rotation = 0;
    	scale = 1;
    	alpha = 1;
    	lifetime = 2;
    	lifetimeTimer = 0;
    	tick;
    	r; g; b;
    }

    function p.update(delta, i)
    	if GamePaused then return end
    	-- Increment lifetime timer
    	p.lifetimeTimer = p.lifetimeTimer + delta * MotionSpeed
    	-- Despawning
    	if p.lifetime < p.lifetimeTimer then
    	    table.remove(ParticleManager.particles, i) end
		-- Call special function
    	if p.tick then p.tick(p, delta) end
    end

    function p.draw()
    	love.graphics.setColor(1, 1, 1, 1)
		local size = vec2.new(p.size.x*p.scale, p.size.y*p.scale)
    	local pos = vec2.new(p.position.x-size.x/2, p.position.y-size.y/2)
    	local x = (pos.x - Camera.position.x) * Camera.zoom
    	local y = (pos.y - Camera.position.y) * Camera.zoom
    	love.graphics.setColor(p.r, p.g, p.b, p.alpha)
		love.graphics.push()
			love.graphics.translate(x+size.x/2, y+size.y/2)
			love.graphics.rotate(p.rotation)
			love.graphics.rectangle("fill", -size.x/2, -size.y/2, size.x, size.y)
		love.graphics.pop()
    	love.graphics.setColor(1, 1, 1, 1)
    end

    return p
end

return particle
