local Weapon = require("_weapon/weaponData")
local Items = setmetatable({

	
	["Thief Blade"] = {
		SellValue = 5,
	},

	["Wolf's Tooth"] = {
		SellValue = 1,
	}






}, {__index = Weapon})





return Items