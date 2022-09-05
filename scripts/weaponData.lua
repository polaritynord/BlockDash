local vec2 = require("lib/vec2")
local weapon = require("scripts/weapon")

local weaponData = {}

-- Pistol
local pistol = weapon.new()
pistol.name = "pistol"
--pistol.weaponType = "manual"
pistol.bulletSpeed = 560
pistol.bulletDamage = 10
pistol.bulletSpread = 0.15
pistol.reloadTime = 0.875
pistol.shootTime = 0.175
pistol.magSize = 13
pistol.bulletOffset = 15
pistol.recoil = 0.35

-- Assault Rifle
local ar = weapon.new()
ar.name = "assaultRifle"
ar.bulletSpeed = 585
ar.bulletDamage = 8.5
ar.bulletSpread = 0.24
ar.reloadTime = 1.0675
ar.magSize = 30
ar.bulletOffset = 20
ar.recoil = 0.65
ar.shootTime = 0.082

weaponData["pistol"] = pistol
weaponData["assaultRifle"] = ar 

return weaponData

