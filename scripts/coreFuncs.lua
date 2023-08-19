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
    humanoid.trailCooldown = humanoid.trailCooldown + delta*MotionSpeed
    local cooldown = 0.05
    if humanoid.dashVelocity and humanoid.dashVelocity > 0.1 then
        cooldown = 0
    end
    if humanoid.moving == nil then cooldown = 0.025 end
    if humanoid.trailCooldown < cooldown or (humanoid.moving ~= nil and not humanoid.moving) then return end
    -- Define the color, size for the trail
    local color, size
    size = vec2.new(22.4, 22.4)
    if humanoid == Player then
        -- Player trail
        color = PlayerColors[Save.playerColorSlot]
    elseif humanoid.hiyaImAnEnemy then
        -- Enemy trail
        color = {1, 0.12, 0.12}
    else
        -- Bullet trail
        size = vec2.new(6.4, 6.4)
        if humanoid.parent == Player then
            color = PlayerColors[Save.playerColorSlot]
        else
            color = {1, 0, 0}
        end
    end
    -- Create the particle 
    local particle = ParticleManager.new(
        vec2.new(humanoid.position.x, humanoid.position.y),
        size,
        0.315, color, coreFuncs.trailParticleTick
    )
    particle.velocity = vec2.new()
    humanoid.trailCooldown = 0
end

return coreFuncs