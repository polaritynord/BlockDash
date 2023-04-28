local utils = require("utils")
local vec2 = require("lib/vec2")
local zerpgui = require("lib/zerpgui")

local assets = require("scripts/assets")

local weaponDrop = {}

function weaponDrop.new()
    local w = {
	position = vec2.new();
	scale = 1;
	weapon = nil;
	beingObtained = false;
	nearPlayer = false;
        alpha = 1;
    }

    function w.obtain()
        local slot
        -- Try to find an empty slot at player
        if Player.weapons[Player.slot] then
            for i = 1, Player.slotCount do
                if not Player.weapons[i] then
                    slot = i
                    break
                end
            end
        else slot = Player.slot end
        if slot then
            -- Add weapon to existing empty slot
            Player.weapons[slot] = w.weapon
        end
        w.beingObtained  = true
    end

    function w.update(delta, i)
		if GamePaused then return end
		if not w.weapon or Player.nearWeapon then return end
		local distance = utils.distanceTo(w.position, Player.position)
		if w.beingObtained then
			-- Move towards player
			local p = Player.position
			w.rotation = math.atan2(p.y - w.position.y, p.x - w.position.x)
			local speed = distance / 0.12
			w.position.x = w.position.x + math.cos(w.rotation) * (speed * delta)
			w.position.y = w.position.y + math.sin(w.rotation) * (speed * delta)
			w.alpha = distance / 65
			-- Despawn if near player
			if distance < 15 then
			table.remove(WeaponDrops, i) end
			else
			w.nearPlayer = distance < 63
			-- Change scale
			if w.nearPlayer then
				w.scale = w.scale + (1.45-w.scale) * (10 * delta)
					-- Check for key press
					if love.keyboard.isScancodeDown("e") then
						w.obtain() end
			else
				w.scale = w.scale + (1-w.scale) * (10 * delta)
			end
		end
    end

    function w.draw()
		if not w.weapon then return end
		local image = assets.weapons[w.weapon.name .. "Img"]
		local width = image:getWidth() ; local height = image:getHeight()
		local x = (w.position.x - Camera.position.x) * Camera.zoom
		local y = (w.position.y - Camera.position.y) * Camera.zoom
		love.graphics.setColor(1, 1, 1, w.alpha)
			love.graphics.draw(
			image, x, y, 0,
			1.45*w.scale, 1.45*w.scale, width/2, height/2
		)
			love.graphics.setColor(1, 1, 1, 1)
		-- Draw preview text
		if not w.nearPlayer or w.beingObtained then return end
		SetFont("fonts/Minecraftia.ttf", 14)
		love.graphics.print(string.upper(w.weapon.name), x-width, y-height/2-25)
    end

    return w
end

return weaponDrop
