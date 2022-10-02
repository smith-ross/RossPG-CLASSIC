local Moves = {

	["FLAMESHOT"] = {
		HitsAll = false,
		BaseDamage = 2,
		UnlockLevel = nil,
		ManaCost = 3,
		ApplyEffect = nil
	},

	["JAB"] = {
		HitsAll = false,
		BaseDamage = 2,
		UnlockLevel = nil,
		ManaCost = 3,
		ApplyEffect = nil
	},

	["TACKLE"] = {
		HitsAll = false,
		BaseDamage = 1,
		UnlockLevel = nil,
		ManaCost = 2,
		ApplyEffect = nil
	},

	["BITE"] = {
		HitsAll = false,
		BaseDamage = 1,
		UnlockLevel = nil,
		ManaCost = 3,
		ApplyEffect = {"BLEED", 3, 1}
	},

	["KICK"] = {
		HitsAll = false,
		BaseDamage = 2,
		UnlockLevel = nil,
		ManaCost = 3,
		ApplyEffect = nil,
	},

	["CLOBBER"] = {
		HitsAll = false,
		BaseDamage = 2,
		UnlockLevel = nil,
		ManaCost = 5,
		ApplyEffect = {"STUN", 1, nil}
	},

	







}

return Moves