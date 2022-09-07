local vec2 = require("lib/vec2")
local enemy = require("scripts/enemy")

local enemyManager = {
    spawnTimer = 0;
    enemies = {};
    spawnTime = 3.5;
}

function enemyManager.spawnEnemies(delta)
    -- Increment timer
    enemyManager.spawnTimer = enemyManager.spawnTimer + MotionSpeed * delta
    if enemyManager.spawnTimer < enemyManager.spawnTime then return end
    -- Spawn enemy
    local newEnemy = enemy.new()
end

function enemyManager.load()
    enemyManager.enemies = {}
    enemyManager.spawnTimer = 0
end

function enemyManager.update(delta)
    if GamePaused then return end
    enemyManager.spawnEnemies(delta)
    -- Update enemies
    for i, v in ipairs(enemyManager.enemies) do
	v.update(delta, i)
    end
end

function enemyManager.draw()
    for _, v in ipairs(enemyManager.enemies) do
	v.draw()
    end
end

return enemyManager
