local particle = require("scripts/particle")

local particleManager = { particles = {} }

function particleManager.update(delta)
    for i, v in ipairs(particleManager.particles) do
       v.update(delta, i)
    end
end

function particleManager.draw()
    for _, v in ipairs(particleManager.particles) do
       v.draw()
    end
end

function particleManager.new(position, size, lifetime, color, tick)
    local p = particle.new()
    p.position = position
    p.size = size
    p.lifetime = lifetime
    p.tick = tick
    p.r = color[1] ; p.g = color[2] ; p.b = color[3]
    particleManager.particles[#ParticleManager.particles+1] = p
    return p
end

return particleManager
