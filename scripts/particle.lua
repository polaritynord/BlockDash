local vec2 = require("lib/vec2")

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
	p.lifetimeTimer = p.lifetimeTimer + delta
	-- Despawning
	if p.lifetime < p.lifetimeTimer then
	    table.remove(ParticleManager.particles, i) end
	-- Call special function
	if p.tick then p.tick(delta) end
    end

    function p.draw()
	local pos = vec2.new(p.position.x-p.size.x/2, p.position.y-p.size.y/2)
	local x = (pos.x - Camera.position.x) * Camera.zoom	
	local y = (pos.y - Camera.position.y) * Camera.zoom
	love.graphics.setColor(p.r, p.g, p.b, p.alpha)
	love.graphics.rectangle("fill", x, y, p.size.x, p.size.y)
	love.graphics.setColor(1, 1, 1, 1)
    end

    return p
end

return particle
