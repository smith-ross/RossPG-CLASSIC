local Ally = require("_ally/ally")
local Player = setmetatable({}, {__index = Ally})
local io = require("_misc/additionalconsole")

Player.__index = Player

require("_misc/ansicolors")

function Player.new(DataTable)
  local newPlayer = setmetatable(Ally.new(DataTable), Player)
  
  newPlayer.Bag = DataTable.Bag or {}
	newPlayer.CurrentFloor = DataTable.CurrentLevel or 1
	newPlayer.UnlockedFloors = DataTable.UnlockedFloors or {newPlayer.CurrentFloor}


  return newPlayer
end

function Player:UnlockFloor(Floor)
	table.insert(self.UnlockedFloors, Floor)
	self.CurrentFloor = Floor
end

function Player:Give(itemName)
	table.insert(self.Bag, itemName)
	print(ansicolors.yellow .. ansicolors.bright .. itemName.. " was added to your bag!" .. ansicolors.reset)
end

function Player:Take(itemName)
	for i, v in pairs(self.Bag) do
		if v == itemName then
			table.remove(self.Bag, i)
			break
		end
	end
end

function Player:SetName(newName)
	self.Name = newName
	print("You have chosen the name '" .. ansicolors.cyan .. newName .. ansicolors.reset .. "'!" )
end


return Player
  