local vec2 = require("lib/vec2")

local coreFuncs = {}

function coreFuncs.trailParticleTick(p, delta)
    p.alpha = p.alpha - 3.5 * MotionSpeed * delta
    p.scale = p.scale - 2.7 * MotionSpeed * delta
    p.rotation = p.rotation + 5 * MotionSpeed * delta
    p.position.x = p.position.x + p.velocity.x * delta
    p.position.y = p.position.y + p.velocity.y * delta
end

function coreFuncs.spawnHumanoidTrails(humanoid, delta)
    -- Increment timer
    humanoid.trailCooldown = humanoid.trailCooldown + delta
    local cooldown = 0.05
    if humanoid.dashVelocity > 0.1 then
        cooldown = 0
    end
    if humanoid.trailCooldown < cooldown or not humanoid.moving then return end
    -- Define the color for the trail
    local color
    if humanoid == Player then
        color = {1, 0.36, 0}
    else
        color = {1, 0.12, 0.12}
    end
    -- Create the particle 
    local particle = ParticleManager.new(
        vec2.new(humanoid.position.x, humanoid.position.y),
        vec2.new(22.4, 22.4),
        0.315, color, coreFuncs.trailParticleTick
    )
    particle.velocity = vec2.new()
    humanoid.trailCooldown = 0
end

return coreFuncs