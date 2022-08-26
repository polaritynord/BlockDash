local weapon = require("scripts/weapon")

local weaponData = {}

-- Pistol
local pistol = weapon.new()
pistol.name = "Pistol"
pistol.weaponType = "manual"
pistol.bulletSpeed = 200
pistol.bulletDamage = 10
pistol.bulletSpread = 0.15
pistol.reloadTime = 1.54
pistol.shootTime = 0.25
pistol.magSize = 13

weaponData["pistol"] = pistol

return weaponData
