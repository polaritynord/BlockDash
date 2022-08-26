local weapon = {}

function weapon.new()
    local w = {
	name;
	weaponType;
	bulletType;
	ammoType;
	bulletSpeed;
	bulletDamage;
	bulletSpread;
	reloadTime;
	shootTime;
	magSize;
	magAmmo = 0;
	rarity;
    }

    return w
end

return weapon
