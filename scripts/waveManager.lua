local vec2 = require("lib/vec2")
local uniform = require("lib/uniform")

local waveManager = {
    wave = 1;
    waveTimer = 0;
    preparation = true;
    enemySpawnCount = 5;
    spawnTimer = 0;
    spawnedEnemies = 0;
    spawnCooldown = 0;
}

function waveManager.load()
    waveManager.wave = 1
    waveManager.waveTimer = 0
    waveManager.preparation = true
    waveManager.enemySpawnCount = 5
    waveManager.spawnTimer = 0
    waveManager.spawnedEnemies = 0
    waveManager.spawnCooldown = 0
end

function waveManager.update(delta)
    if Player.dead or GamePaused then return end
    if waveManager.preparation then
        -- Preparation phase
        waveManager.waveTimer = waveManager.waveTimer + MotionSpeed * delta
        if waveManager.waveTimer > 5.5 then
            waveManager.preparation = false
            waveManager.waveTimer = 0
            waveManager.spawnedEnemies = 0
            waveManager.spawnTimer = 0
            waveManager.spawnCooldown = uniform(0.8, 1.54)
            waveManager.enemySpawnCount = (waveManager.wave * 2) + 3
        end
    else
        if waveManager.spawnedEnemies < waveManager.enemySpawnCount then
            -- Spawn enemies
            waveManager.spawnTimer = waveManager.spawnTimer + MotionSpeed * delta
            if waveManager.spawnTimer > waveManager.spawnCooldown then
                waveManager.spawnCooldown = uniform(1.2, 2.14)
                local rot = uniform(0, 2*math.pi)
                local pos = vec2.new(
                    Player.position.x+math.cos(rot)*(200+uniform(0, 550)),
                    Player.position.y+math.sin(rot)*(200+uniform(0, 550))
                )
                EnemyManager.newEnemy(pos)
                waveManager.spawnTimer = 0
                waveManager.spawnedEnemies = waveManager.spawnedEnemies + 1
            end
        else
            -- Wait for the player to clear all enemies
            if #EnemyManager.enemies < 1 then
                waveManager.preparation = true
                waveManager.waveTimer = 0
            end
        end
    end
end

return waveManager
