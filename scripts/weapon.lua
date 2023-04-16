local weapon = {}

function weapon.new()
    local w = {
    	name;
    	weaponType;
    	bulletSpeed;
    	bulletDamage;
    	bulletSpread;
        bulletPerShot;
    	reloadTime;
    	shootTime;
    	magSize;
    	recoil;
    	magAmmo = 0;
		screenShakeIntensity = 0;
    }

    function w.new()
        -- Taken from http://lua-users.org/wiki/CopyTable/
    	local orig = w
    	local orig_type = type(orig)
    	local copy
    	if orig_type == 'table' then
    	    copy = {}
    	    for orig_key, orig_value in pairs(orig) do
    		copy[orig_key] = orig_value
    	    end
    	else -- number, string, boolean, etc
    	    copy = orig
    	end
    	return copy
    end

    return w
end

return weapon
