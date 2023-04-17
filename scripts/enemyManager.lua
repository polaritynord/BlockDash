local vec2 = require("lib/vec2")
local enemy = require("scripts/enemy")

local enemyManager = {
    spawnTimer = 0;
    enemies = {};
    spawnTime = 0.25;
}

function enemyManager.getCount()
    return #enemyManager.enemies
end

function enemyManager.newEnemy(position)
    local newEnemy = enemy.new()
    newEnemy.position = position
    newEnemy.load(#enemyManager.enemies+1)
    enemyManager.enemies[#enemyManager.enemies+1] = newEnemy
end

function enemyManager.spawnSimEnemies(delta)
    -- Increment timer
    enemyManager.spawnTimer = enemyManager.spawnTimer + delta
    if enemyManager.spawnTimer < enemyManager.spawnTime then return end
    -- Spawn enemy
    enemyManager.newEnemy(vec2.new(math.random(0, SC_WIDTH), math.random(0, SC_HEIGHT)))
    enemyManager.spawnTimer = 0
end

function enemyManager.load()
    enemyManager.enemies = {}
    enemyManager.spawnTimer = 0
end

function enemyManager.update(delta)
    if GamePaused then return end
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
