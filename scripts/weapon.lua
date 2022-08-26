local weapon = {}

function weapon.new()
    local w = {
	name;
	weaponType;
	bulletSpeed;
	bulletDamage;
	bulletSpread;
	reloadTime;
	shootTime;
	magSize;
	magAmmo = 0;
    }

    return w
end

return weapon
