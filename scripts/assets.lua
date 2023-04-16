local assets = {}

function assets.load()
    -- Sounds
    assets.sounds = {}
    assets.sounds.buttonClick = love.audio.newSource("sounds/button_click.wav", "static")
    -- Fonts
    assets.fonts = {}
    --assets.font = love.graphics.newFont("fonts/Minecraftia-Regular.ttf", 24)
end

function assets.gameLoad()
    -- Cursors
    assets.cursorDefault = love.mouse.newCursor("images/cursor_default.png", 0, 0)
    assets.cursorCombat = love.mouse.newCursor("images/cursor_combat.png", 12, 12)
    assets.cursorCombatI = love.mouse.newCursor("images/cursor_combat_i.png", 12, 12)
    -- Other
    assets.playerImg = love.graphics.newImage("images/player.png")
    assets.bulletImg = love.graphics.newImage("images/bullet.png")
    assets.invSlotImg = love.graphics.newImage("images/inv_slot.png")
    assets.healthIconImg = love.graphics.newImage("images/health_icon.png")
    assets.ammoIconImg = love.graphics.newImage("images/ammo.png")
    assets.dashIconImg = love.graphics.newImage("images/dash_icon.png")
    assets.hitmarkerImg = love.graphics.newImage("images/hitmarker.png")
    assets.rmbImg = love.graphics.newImage("images/rmb.png")
    assets.dashKillImg = love.graphics.newImage("images/dashkill.png") 
    -- Weapon images
    assets.weapons = {}
    assets.weapons.pistolImg = love.graphics.newImage("images/weapons/pistol.png")
    assets.weapons.assaultRifleImg = love.graphics.newImage("images/weapons/assault_rifle.png")
    assets.weapons.shotgunImg = love.graphics.newImage("images/weapons/shotgun.png")
    -- Accessory images
    assets.accessories = {
        nil, love.graphics.newImage("images/accessories/glasses.png"),
        love.graphics.newImage("images/accessories/crown.png"),
        love.graphics.newImage("images/accessories/sunglasses.png")
    }
    -- Sounds
    assets.sounds.shoot = love.audio.newSource("sounds/shoot.wav", "static")
    assets.sounds.reload = love.audio.newSource("sounds/reload.wav", "static")
    assets.sounds.dash = love.audio.newSource("sounds/dash.wav", "static")
    assets.sounds.dashDamage = love.audio.newSource("sounds/dash_damage.wav", "static")
    assets.sounds.damage = love.audio.newSource("sounds/damage.wav", "static")
    assets.sounds.dashBegin = love.audio.newSource("sounds/dash_begin.wav", "static")
    assets.sounds.dashCancel = love.audio.newSource("sounds/dash_cancel.wav", "static")
end

function assets.menuLoad()

end

function assets.unloadAll()
    assets = {}
end

return assets
