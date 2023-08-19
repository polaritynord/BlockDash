local coreFuncs = {}

function coreFuncs.trailParticleTick(p, delta)
    p.alpha = p.alpha - 3.5 * MotionSpeed * delta
    p.scale = p.scale - 2.7 * MotionSpeed * delta
    p.rotation = p.rotation + 5 * MotionSpeed * delta
    p.position.x = p.position.x + p.velocity.x * delta
    p.position.y = p.position.y + p.velocity.y * delta
end

return coreFuncs