local assets = {}

function assets.gameLoad()
    assets.playerImg = love.graphics.newImage("images/player.png")
    assets.bulletImg = love.graphics.newImage("images/bullet.png")
    assets.invSlotImg = love.graphics.newImage("images/inv_slot.png")
    assets.healthIconImg = love.graphics.newImage("images/health_icon.png")
    assets.ammoIconImg = love.graphics.newImage("images/ammo.png")
    -- Weapon images
    assets.weapons = {}
    assets.weapons.pistolImg = love.graphics.newImage("images/weapons/pistol.png")
end

function assets.menuLoad()

end

function assets.unloadAll()
    assets = {}
end

return assets
