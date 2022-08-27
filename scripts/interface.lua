local vec2 = require("lib/vec2")

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

-- Event functions
function interface.gameLoad()
    interface.buttons = {}
    -- Pause menu buttons
    local pContinueButton = button.new()
    pContinueButton.position = vec2.new(50, 50)

    interface.buttons.pContinueButton = pContinueButton
    -- Inventory slots (test)
    interface.invSlots[1] = invSlot.new()
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
    love.graphics.setColor(1, 1, 1, 1)
    -- Inventory slots
    for _, v in ipairs(interface.invSlots) do
	v.draw()
    end

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
