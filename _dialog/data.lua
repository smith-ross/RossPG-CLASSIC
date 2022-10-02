--[[response conventions
0 = nothing, moves on to next given ID in table
1 - returns to FIGHT
2 - gives an item as second value in table
3 - recruits as teammate
4 - enemy runs away
5 - execute function (second value)
]]


local DialogData = {

	[1] = {
		["Speaker"] = "Enemy",
		["Text"] = {
				"Spare me! I'll do anything!"
			},
		["Responses"] = {
			["Join my cause."] = {0, 2},
			["Give me your possession."] = {2, "blade"},
			["No."] = {1, nil},
			["*Warning Shot*"] = {4, nil}
		}
	},

	[2] = {
		["Speaker"] = "Enemy",
		["Text"] = {
			"You want to recruit me?",
			"I'd rather die."
		},
		["Responses"] = {
			["You don't have a choice."] = {0, 3},
			["So be it."] = {1, nil},
			["*Warning Shot*"] = {4, nil}
		}
	},

	[3] = {
		["Speaker"] = "Enemy",
		["Text"] = {
			"I guess I don't then."
		},
		["Responses"] = {
			["Join me!"] = {3, nil}
		}
	},

	[4] = {
		["Speaker"] = "Wolf",
		["Text"] = {
				"Woof! Woof Woof!"
			},
		["Responses"] = {
			["BARK BARK"] = {3, nil},
			["*threaten*"] = {2, "Wolf's Tooth"},
			["*ignore*"] = {1, nil},
			["*Warning Shot*"] = {4, nil}
		}
	},

	[5] = {
		["Speaker"] = "Goblin",
		["Text"] = {
				"*pant* Me had enough..."
			},
		["Responses"] = {
			["Come with me."] = {0, 6},
			["I haven't."] = {1, nil},
			["Pass me your money!"] = {0, 7},
			["*Warning Shot*"] = {4, nil}
		}
	},

	[6] = {
		["Speaker"] = "Goblin",
		["Text"] = {
				"Only if you promise to be nice!"
			},
		["Responses"] = {
			["Sure."] = {3, nil},
			["I don't.*"] = {1, nil},
			["*Warning Shot*"] = {4, nil}
		}
	},

	[7] = {
		["Speaker"] = "Goblin",
		["Text"] = {
				"Me never surrender me gold!"
			},
		["Responses"] = {
			["Fair enough."] = {1, nil},
			["Then you die!"] = {4, nil},
			["I'm a tax collector."] = {0, 8}
		}
	},

	[7] = {
		["Speaker"] = "Goblin",
		["Text"] = {
				"Me no evade me taxes me promise!"
			},
		["Responses"] = {
			["Time for your tax returns!"] = {3, nil},
		}
	},

}

return DialogData