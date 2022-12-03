local vec2 = require("lib/vec2")
local collision = require("lib/collision")
local uniform = require("lib/uniform")
local utils   = require("utils")

local assets = require("scripts/assets")
local damageNumber = require("scripts/damageNumber")
local hitmarker = require("scripts/hitmarker")

local bullet = {}

function bullet.new()
    local b = {
    	position = vec2.new();
    	rotation = 0;
    	lifetime = 0;
    	speed = 500;
    	trails = {};
    	trailCooldown = 0;
    	damage = 10;
        parent = nil;
        target = nil;
    }

    -- Event functions
    function b.update(delta, i)
    	if GamePaused then return end
    	b.lifetime = b.lifetime + delta * MotionSpeed
    	-- Bullet despawning
    	if b.lifetime > 3.5 then
            local t = EnemyBullets
            if b.parent == Player then
                t = Player.bullets
                Player.missedBullets = Player.missedBullets + 1
            end
    	    table.remove(t, i)
    	    return
    	end
    	-- Check for collision
        local image = assets.bulletImg
        local w1 = image:getWidth()
        local h1 = image:getHeight()
        local eImg = assets.playerImg
        local w2 = eImg:getWidth()
        local h2 = eImg:getHeight()
        if b.parent == Player then
            for _, v in ipairs(EnemyManager.enemies) do
                if not v.deathAnim then
                    local p = b.position
                    local p2 = v.position
                    if collision(p.x-w1/2, p.y-h1/2, w1, h1, p2.x-w2/2, p2.y-h2/2, w2, h2) then
                        v.health = v.health - b.damage
                        -- Increment kill count
                        if v.health < 1 then
                            local index = utils.indexOf(StatNames, "Kills")
                            Stats[index] = Stats[index] + 1
                        end
                        table.remove(Player.bullets, i)
                        -- Create damage number
                        local damageNum = damageNumber.new()
                        damageNum.position = vec2.new(v.position.x+uniform(-10, 10), v.position.y+uniform(-10, 10))
                        damageNum.number = b.damage + math.random(-2, 2)
                        Interface.damageNums[#Interface.damageNums+1] = damageNum
                        Player.hitBullets = Player.hitBullets + 1
                        return
                    end
                end
            end
        elseif b.target == Player then
            local p = b.position
            local p2 = Player.position
            if collision(p.x-w1/2, p.y-h1/2, w1, h1, p2.x-w2/2, p2.y-h2/2, w2, h2) then
                Player.health = Player.health - b.damage
                -- Create hitmarker
                local newMarker = hitmarker.new()
                newMarker.rotation = b.rotation
                newMarker.position = vec2.new(
                    480-math.cos(newMarker.rotation)*70,
                    270-math.sin(newMarker.rotation)*70
                )
                Interface.hitmarkers[#Interface.hitmarkers+1] = newMarker
                Player.regenTimer = 0
                -- Play sound
                if Save.settings[utils.indexOf(SettingNames, "Sounds")] then
                    assets.sounds.damage:play()
                end
                -- Remove self
                table.remove(EnemyBullets, i)
                return
            end
        else
            local p = b.position
            local p2 = b.target.position
            if collision(p.x-w1/2, p.y-h1/2, w1, h1, p2.x-w2/2, p2.y-h2/2, w2, h2) then
                b.target.health = b.target.health - b.damage
                -- Remove self
                table.remove(EnemyBullets, i)
                return
            end
        end
    	-- Movement
    	b.position.x = b.position.x + math.cos(b.rotation) * b.speed * MotionSpeed * delta
    	b.position.y = b.position.y + math.sin(b.rotation) * b.speed * MotionSpeed * delta
    end

    function b.draw()
    	local image = assets.bulletImg
    	local width = image:getWidth()
    	local height = image:getHeight()
    	local x = (b.position.x - Camera.position.x) * Camera.zoom
    	local y = (b.position.y - Camera.position.y) * Camera.zoom

        if b.parent == Player then
            love.graphics.setColor(0.13, 0.34, 0.8, 1)
        else
            love.graphics.setColor(1, 0, 0, 1)
        end
        love.graphics.draw(
    	    image, x, y, b.rotation,
    	    Camera.zoom, Camera.zoom, width/2, height/2
    	)
        love.graphics.setColor(1, 1, 1, 1)
    end

    return b
end

return bullet
