local assets = {}

function assets.gameLoad()
    assets.playerImg = love.graphics.newImage("images/player.png")
    assets.bulletImg = love.graphics.newImage("images/bullet.png")
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
