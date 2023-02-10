local vec2 = require("lib/vec2")
local weapon = require("scripts/weapon")

local weaponData = {}

-- Pistol
local pistol = weapon.new()
pistol.name = "pistol"
pistol.weaponType = "auto"
pistol.bulletSpeed = 780
pistol.bulletDamage = 15
pistol.bulletSpread = 0.0485
pistol.bulletPerShot = 1
pistol.reloadTime = 0.875
pistol.shootTime = 0.18
pistol.magSize = 13
pistol.bulletOffset = 15
pistol.recoil = 0.35

-- Assault Rifle
local ar = weapon.new()
ar.name = "assaultRifle"
ar.weaponType = "auto"
ar.bulletSpeed = 795
ar.bulletDamage = 8.5
ar.bulletSpread = 0.065
ar.bulletPerShot = 1
ar.reloadTime = 1.0675
ar.magSize = 30
ar.bulletOffset = 20
ar.recoil = 0.65
ar.shootTime = 0.1

-- Shotgun
local shotgun = weapon.new()
shotgun.name = "shotgun"
shotgun.weaponType = "shotgun"
shotgun.bulletSpeed = 780
shotgun.bulletDamage = 22
shotgun.bulletSpread = 0.25
shotgun.bulletPerShot = 4
shotgun.reloadTime = 1.4
shotgun.shootTime = 0.22
shotgun.magSize = 7
shotgun.bulletOffset = 15
shotgun.recoil = 0.45

weaponData["pistol"] = pistol
weaponData["assaultRifle"] = ar
weaponData["shotgun"] = shotgun

return weaponData
