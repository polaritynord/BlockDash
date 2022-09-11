local vec2 = require("lib/vec2")
local enemy = require("scripts/enemy")

local enemyManager = {
    spawnTimer = 0;
    enemies = {};
    spawnTime = 3.5;
}

function enemyManager.newEnemy(position)
    local newEnemy = enemy.new()
    newEnemy.position = position
    newEnemy.load()
    enemyManager.enemies[#enemyManager.enemies+1] = newEnemy
end

function enemyManager.spawnEnemies(delta)
    if Player.dead then return end
    -- Increment timer
    enemyManager.spawnTimer = enemyManager.spawnTimer + MotionSpeed * delta
    if enemyManager.spawnTimer < enemyManager.spawnTime then return end
    -- Spawn enemy
    enemyManager.newEnemy(vec2.new(math.random(-800, 800), math.random(-800, 800)))
    enemyManager.spawnTimer = 0
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
