local vec2 = require("lib/vec2")
local weapon = require("scripts/weapon")

local weaponData = {}

-- Pistol
local pistol = weapon.new()
pistol.name = "pistol"
pistol.weaponType = "manual"
pistol.bulletSpeed = 200
pistol.bulletDamage = 10
pistol.bulletSpread = 0.15
pistol.reloadTime = 1.54
pistol.shootTime = 0.25
pistol.magSize = 13
pistol.bulletOffset = 15
pistol.recoil = 0.35

weaponData["pistol"] = pistol

return weaponData

