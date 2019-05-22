local defaults = {
	guardLength = 0,
	comboLength = 2,
	swingSpeed = .6,
	postComboSwingSpeed =1,
	wieldSpeedModifier = 0,
	damage = 5,
	shieldWalkspeed = 15,
	swingWalkspeed = 14,
	knockback = 2,
	angle = 80,
	range = 5,
	chargeTime = .5,
	guardDamage = 1,
	damageSound = "Damaged",
	swingSound = "HeavyWhoosh",
	chopPower = 1,
	minePower = 1,
}

local weapons = {
	Stick = {
		comboLength = 4,
		swingSpeed = .6,
		postComboSwingSpeed = 1,
		wieldSpeedModifier = 0,
		angle = 80,
		damage = 10,
		range = 8,
	},
	Bone = {
		comboLength = 5,
		swingSpeed = .6,
		postComboSwingSpeed = 1,
		wieldSpeedModifier = 0,
		angle = 80,
		damage = 13,
		range = 8.3,
	},
	Handle = {
		comboLength = 5,
		swingSpeed = .4,
		postComboSwingSpeed = 1.5,
		wieldSpeedModifier = 4,
		angle = 80,
		damage = 9,
		range = 6,
		guardDamage = .25,
		damageSound = "HitSlap",
		knockback = .25,
		swingSound = "SwordWhip",
		swingWalkspeed = 18,
	},
	Shield = {
		damage = 20,
		comboLength = 1,
		swingSpeed = .8,
		guardLength = 2,
		angle = 80,
		shieldWalkspeed = 1,
		range = 6.5,
		guardDamage = 3,
		knockback = 3,
		swingSound = "DeepWhip",
		wieldSpeedModifier = -2
	},
	["Reinforced Shield"] = {
		damage = 25,
		comboLength = 1,
		swingSpeed = .8,
		guardLength = 3,
		angle = 80,
		shieldWalkspeed = 1,
		range = 6.5,
		guardDamage = 3,
		knockback = 3,
		swingSound = "DeepWhip",
		wieldSpeedModifier = -2
	},
	["Shell Piece"] = {
		damage = 20,
		comboLength = 1,
		swingSpeed = .8,
		guardLength = 4,
		angle = 80,
		shieldWalkspeed = 1,
		range = 6.5,
		guardDamage = 3,
		knockback = 3,
		swingSound = "DeepWhip",
		wieldSpeedModifier = -2
	},
	Axe = {
		chopPower = 2.5,
		comboLength = 5,
		swingSpeed = .6,
		wieldSpeedModifier = 2,
		guardDamage = 1,
		damage = 12
	},
	Pickaxe = {
		minePower = 2.5,
		comboLength = 4,
		swingSpeed = .6,
		wieldSpeedModifier = 2,
		guardDamage = 1,
		damage = 14
	},
	Badsword = {
		comboLength = 3,
		swingSpeed = .5,
		postComboSwingSpeed = 1,
		wieldSpeedModifier = -1,
		angle = 90,
		damage = 17,
		range = 8.5,
	},
	Hammer = {
		comboLength = 3,
		swingSpeed = .6,
		postComboSwingSpeed = 1.1,
		wieldSpeedModifier = -1,
		angle = 95,
		damage = 22,
		range = 8.25,
	},
	Default = defaults,
}

for _, dataTable in pairs(weapons) do
	for prop, value in pairs(defaults) do
		if not dataTable[prop] then
			dataTable[prop] = value
		end
	end
end

return weapons
