local vec2 = require("lib/vec2")

local assets = require("scripts/assets")
local button = require("scripts/button")
local invSlot = require("scripts/invSlot")

local interface = {
    buttons = {};
    pauseScreenAlpha = 0;
    invSlots = {};
}

-- Pause key event
function love.keypressed(key)
    if key ~= "escape" then return end
    GamePaused = not GamePaused
end

function interface.drawImage(image, position, scale)
    local width = image:getWidth()
    local height = image:getHeight()
    love.graphics.draw(
	image, position.x, position.y, 0,
	scale, scale, width/2, height/2
    )
end

-- Event functions
function interface.gameLoad()
    interface.buttons = {}
    -- Pause menu buttons
    local pContinueButton = button.new()
    pContinueButton.position = vec2.new(480, 270)
    
    function pContinueButton.clickEvent()
	print("clicked!")
    end

    interface.buttons.pContinueButton = pContinueButton
    -- Inventory slots
    interface.invSlots = {}
    local x = 926 ; local y = 510;
    for i = 1, 3 do
	local s = invSlot.new()
	s.position.x = x ; s.position.y = y
	x = x - 60

	interface.invSlots[#interface.invSlots+1] = s
    end
end

function interface.update(delta)
    -- Change alpha of pause screen
    local a = interface.pauseScreenAlpha
    if GamePaused then
	interface.pauseScreenAlpha = a+(0.65-a) / (250 * delta) 
	interface.buttons.pContinueButton.update(delta)
    else
	interface.pauseScreenAlpha = a+(0-a) / (250 * delta)
    end
    -- Update inventory slots
    for _, v in ipairs(interface.invSlots) do
	v.update(delta)
    end
end

function interface.draw()
    -- FPS text
    love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 16)
    love.graphics.print(love.timer.getFPS() .. " FPS", 5, 5)
    --love.graphics.setColor(1, 1, 1, 1)
    -- Inventory slots
    for _, v in ipairs(interface.invSlots) do
	v.draw()
    end
    -- Health icon
    interface.drawImage(assets.healthIconImg, vec2.new(930, 452), 4)
    -- Health text
    love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 24)
    love.graphics.printf(tostring(Player.health), -95, 438, 1000, "right")

    -- Pause menu
    if GamePaused then
	-- Background
	love.graphics.setColor(0, 0, 0, interface.pauseScreenAlpha)
	love.graphics.rectangle("fill", 0, 0, 960, 540)
	-- Title
	love.graphics.setNewFont("fonts/Minecraftia-Regular.ttf", 32)
	love.graphics.setColor(1, 1, 1, interface.pauseScreenAlpha+0.35)
	love.graphics.print("GAME PAUSED", 355, 120)
	--- Buttons
	interface.buttons.pContinueButton.draw()

	love.graphics.setColor(1, 1, 1, 1)
    end
end

return interface
