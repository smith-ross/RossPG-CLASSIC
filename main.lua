require("_misc/ansicolors")
local pHandler = require("_player/player")
local Enemy = require("_enemy/enemy")
local Ally = require("_ally/ally")
local Encrypter = require("_data/encoder")
local Combat = require("_combat/main")
local JSON = require("_data/json")
local input = require("_misc/inputhandler")
local Item = require("_item/itemData")
local io = require("_misc/additionalconsole")
local floorEnemies = require("_enemy/floorEnemies")
local Party = require("_ally/partyHandler")

--require("test")
math.randomseed(os.time())
math.random() math.random() math.random()
io.clear() -- CLEAR OUTPUT FOR GAME START
local Player = pHandler.new({})


Player:SetName(input.get("Please enter your name: "))

Party:AddMember(Player)
Party:AddMember(Ally.new( {Name = "Good Guy #2"} ))

local game_options = {
	["FIGHT"] = function() 
		local enemies = {}
		for i = 1, math.random(1, 3) do
			local enemyN = floorEnemies[Player.CurrentFloor][math.random(1, #floorEnemies[Player.CurrentFloor])]
			table.insert(enemies, Enemy.new(enemyN, math.random(Player.Level > 2 and Player.Level - 2 or 1, Player.Level + 2)));
		end
		
		local newCombat = Combat.new( Party:GetMembers(), enemies)
		newCombat:Begin()
	end,
	["TEAM"] = function() end,	
	["BAG"] = function() end,
	["HEAL"] = function() end,
}

local options = {"FIGHT","TEAM","BAG", "HEAL"}

function game_loop()
	local concat_st = table.concat(options, ansicolors.blue .. " | " .. ansicolors.cyan)
	print(ansicolors.cyan .. concat_st .. ansicolors.reset)
	local option = input.get("Please enter an option: ")
	while not game_options[option:upper()] do
		print("Invalid option!")
		option = input.get("Please enter an option: ")
	end

	game_options[option:upper()]()

	game_loop()
end

game_loop()
