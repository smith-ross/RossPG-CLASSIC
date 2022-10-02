local Combat = {}
Combat.__index = Combat

local Moves = require("_moves/moveData")
local io = require("_misc/additionalconsole")
local input = require("_misc/inputhandler")
local Dialog = require("_dialog/main")
local Party = require("_ally/partyHandler")
local EnemyCore = require("_enemy/enemyCoreData")
local AllyMod = require("_ally/ally")

local ESCAPE_ODDS = 2

require("_misc/ansicolors")

function sleep (a) 
    local sec = tonumber(os.clock() + a); 
    while (os.clock() < sec) do 
    end 
end

function Combat.new(AllyTable, EnemyTable, ...)
	local Arguments = {...}
	local newCombat = {}
	setmetatable(newCombat, Combat)

	for _, v in pairs(AllyTable) do 
		if v.Bag ~= nil then newCombat.Player = v end
	end
	newCombat.AllyTable = AllyTable
	newCombat.Enemies = EnemyTable
	newCombat.Arguments = Arguments
	newCombat.Fighting = false
	newCombat.Winner = nil

	return newCombat
end

function Combat:ShowTeams()
	print()
	--preview ally team
	print(ansicolors.blue .. ansicolors.onwhite .. ansicolors.bright  .. ansicolors.reverse .. ansicolors.underscore .. " ALLY TEAM " .. ansicolors.reset )
	for _, ally in pairs(self.AllyTable) do
		print(ansicolors.cyan .. ally.Name .. ansicolors.bright .. " [ LVL " .. ally.Level .. " ]".. ansicolors.reset)
	end
	--

	print()

	--preview enemy team
	print(ansicolors.red .. ansicolors.onwhite .. ansicolors.bright .. ansicolors.reverse .. ansicolors.underscore .. " ENEMY TEAM " .. ansicolors.reset )
	for _, enemy in pairs(self.Enemies) do
		print(ansicolors.red .. enemy.Type .. ansicolors.bright .. " [ LVL " .. enemy.Level .. " ]".. ansicolors.reset)
	end
	--

end

local effect_types = {
	["BLEED"] = function(Character, Value)
								Character:TakeDamage(Value, "BLEED")
							end;
	
	["STUN"] = function(Character)
						 	Character.Stunned = true
						 end;


	
}

function Combat:ManageEffect(Character)
	for Effect, Method in pairs(effect_types) do
		if Character:HasTag(Effect) then
			Method(Character, Character.Status_Effects[Effect][2])
		end
	end
end

function Combat:Tick()
	for _, ally in pairs(self.AllyTable) do
		self:ManageEffect(ally)
		ally:Tick()
	end

	for _, enemy in pairs(self.Enemies) do
		self:ManageEffect(enemy)
		enemy:Tick()
	end

end

function Combat:Begin()
	--io.clear()
	self.Fighting = true
	local newDialog = Dialog.new(1, self.Enemies[1], self.Player)
	--newDialog:Start()
	print()
	print(ansicolors.red.. "A battle was engaged!" .. ansicolors.reset)
	self:ShowTeams()


	while self.Fighting do
		print()
		self:AllyTeamTurn()
		if self.Fighting then
			print()
			self:EnemyTeamTurn()
		end
	end

	return self

end

function Combat:CheckDead(Entity, originalTableName)
	if Entity.HP <= 0 then
		local foundindex = nil
		for index, v in pairs(self[originalTableName]) do
			if v == Entity then foundindex = index end
		end
		table.remove(self[originalTableName], foundindex)
		print(ansicolors.red .. ansicolors.bright .. Entity.Name .. " died!" .. ansicolors.reset)

		if originalTableName == "AllyTable" and Entity == self.Player then
			self.Fighting = false
			print(ansicolors.red .. ansicolors.bright .. "YOU LOST THE BATTLE!" .. ansicolors.reset)
			self.Winner = "enemy"
		elseif originalTableName == "Enemies" and #self.Enemies <= 0 then
			self.Fighting = false
			print(ansicolors.yellow .. ansicolors.bright .. "YOU WON THE BATTLE!" .. ansicolors.reset)
			self.Winner = "ally"
		else
			self:ShowTeams()
		end

		

		return true
	else return false
	end
end

function Combat:SelectAlly()
	local finString = ansicolors.underscore .. ansicolors.green .. ansicolors.bright
	for _, v in pairs(self.AllyTable) do
		local HpString = " [" .. v.HP .. "/" .. v.MaxHP .. "]"
		for i = 1, #v.Type + 8 + #HpString do
			finString = finString .. " "
		end
	end
	finString = finString .. ansicolors.reset
	print(finString)
	finString = ansicolors.underscore .. ansicolors.red .. ansicolors.bright .. "|"
	for i, v in pairs(self.AllyTable) do
		local HpString = " [" .. v.HP .. "/" .. v.MaxHP .. "]"
		finString = finString .. " " .. i .. " - ".. v.Type:upper() .. HpString .. " |"
	end
	finString = finString .. ansicolors.reset
	print(finString)

	local chosenAlly

	repeat
		chosenAlly = input.get(ansicolors.blue .. "ENTER THE TARGET ALLY NUMBER: " .. ansicolors.reset)
	until self.AllyTable[tonumber(chosenEnemy)]
	
	return tonumber(chosenAlly)
end

function Combat:SelectEnemy()
	local finString = ansicolors.underscore .. ansicolors.red .. ansicolors.bright
	for _, v in pairs(self.Enemies) do
		local HpString = " [" .. v.HP .. "/" .. v.MaxHP .. "]"
		for i = 1, #v.Type + 8 + #HpString do
			finString = finString .. " "
		end
	end
	finString = finString .. ansicolors.reset
	print(finString)
	finString = ansicolors.underscore .. ansicolors.red .. ansicolors.bright .. "|"
	for i, v in pairs(self.Enemies) do
		local HpString = " [" .. v.HP .. "/" .. v.MaxHP .. "]"
		finString = finString .. " " .. i .. " - ".. v.Type:upper() .. HpString .. " |"
	end
	finString = finString .. ansicolors.reset
	print(finString)

	local chosenEnemy

	repeat
		chosenEnemy = input.get("ENTER THE TARGET ENEMY NUMBER: ")
	until self.Enemies[tonumber(chosenEnemy)]
	
	return tonumber(chosenEnemy)
end

function findInTable(tab, value)
	for i, v in pairs(tab) do
		if v == value then return true end
	end
	return false
end

function Combat:EnemyTurn(Enemy)
	if self.Fighting == true then
		if Enemy:HasTag("STUN") == false then
			print(ansicolors.bright .. ansicolors.yellow .. Enemy.Name .. "'s " .. ansicolors.reset .. ansicolors.yellow .. " turn! :: " .. ansicolors.reset .. ansicolors.bright ..  ansicolors.red  .. "[ HP: " .. Enemy.HP .. "/".. Enemy.MaxHP .. " ] " .. ansicolors.reset)
			local Move = Enemy:SelectMove()
			if Moves[Move].HitsAll == false then
				local Target = math.random(1, #self.AllyTable)
				
				self.AllyTable[Target] = Enemy:UseMove(Move, self.AllyTable[Target])
				if Moves[Move].Method then Moves[Move].Method(self) end
				self:CheckDead(self.AllyTable[Target], "AllyTable")
			else
				print(ansicolors.bright ..ansicolors.underscore .. ansicolors.red .. "The move hit everyone!" .. ansicolors.reset)
				for _, Target in pairs(self.AllyTable) do
					local Target = math.random(1, #self.AllyTable)
				
					self.AllyTable[Target] = Enemy:UseMove(Move, self.AllyTable[Target])
					if Moves[Move].Method then Moves[Move].Method(self) end
					self:CheckDead(self.AllyTable[Target], "AllyTable")
				end
			end
		else print(ansicolors.yellow .. ansicolors.bright .. Enemy.Type .. ansicolors.dim .. " was stunned and couldn't move!" .. ansicolors.reset)
		end
		Enemy:Tick()
	end

end




function Combat:AllyTurn(Ally)
	if self.Fighting == true then
		if Ally:HasTag("STUN") == false then
			if Ally:HasTag("STUN") == true then print(ansicolors.yellow .. ansicolors.bright .. Ally.Name .. ansicolors.dim .. " was stunned and couldn't move!" .. ansicolors.reset)  return end
			local isPlayer = (Ally.Bag ~= nil)
			local MoveOptions = {
			["MELEE"] = function() 
				local chosenEnemyNumber = self:SelectEnemy()
				self.Enemies[chosenEnemyNumber] = Ally:Melee(self.Enemies[chosenEnemyNumber])
				self:CheckDead(self.Enemies[chosenEnemyNumber], "Enemies")
			end,

			["MAGIC"] = function() 
				local moveSelect = ansicolors.magenta .. ansicolors.bright .. ansicolors.underscore .. "|"
				local length = "|"
				print(ansicolors.bright .. ansicolors.blue .. "[ MANA: " .. Ally.Mana .. "/" .. Ally.MaxMana .. " ] " .. ansicolors.reset)
				for _, v in pairs(Ally.Moves) do
					moveSelect = moveSelect .. " " .. v .. ansicolors.reset .. ansicolors.blue ..  "[" .. Moves[v].ManaCost .. "MP]" .. ansicolors.reset .. ansicolors.magenta .. ansicolors.bright .. ansicolors.underscore .. " |"
					length = length .. " " .. v  ..  "[" ..  Moves[v].ManaCost .. "MP]" .. " |"
				end
				local underLine = ansicolors.magenta .. ansicolors.bright .. ansicolors.underscore

				for _ = 1, #length do
					underLine = underLine .. " "
				end
				moveSelect = moveSelect .. ansicolors.reset
				print(underLine)
				print(moveSelect)

				local selectedMove
				repeat
					if selectedMove ~= nil and Moves[selectedMove:upper()] and Moves[selectedMove:upper()].ManaCost > Ally.Mana then 			print("NOT ENOUGH MANA")
					end
					selectedMove = input.get("ENTER WHAT MOVE TO USE (NONE TO GO BACK): ")
				until (findInTable(Ally.Moves, selectedMove:upper()) == true and Moves[selectedMove:upper()].ManaCost <= Ally.Mana) or selectedMove:upper() == "NONE"

				if selectedMove:upper() ~= "NONE" then
					Ally.Mana = Ally.Mana - Moves[selectedMove:upper()].ManaCost
					local chosenEnemyNumber = self:SelectEnemy()
					self.Enemies[chosenEnemyNumber] = Ally:UseMove(selectedMove:upper(), self.Enemies[chosenEnemyNumber])
					self:CheckDead(self.Enemies[chosenEnemyNumber], "Enemies")
				else
					print("GOING BACK ...")
					self:AllyTurn(Ally)
				end
			
	end,

	["CHARGE"] = function()
		print(ansicolors.blue .. ansicolors.bright .. "CHARGING MANA ..." .. ansicolors.reset)
		if Ally.Mana ~= Ally.MaxMana then
			local Difference = math.floor(Ally.MaxMana / 5)
			if Ally.Mana + Difference > Ally.MaxMana then
				Difference = Ally.MaxMana - Ally.Mana
			end
			Ally.Mana = Ally.Mana + Difference
			print(Ally.Name .. " gained " .. ansicolors.blue .. ansicolors.bright .. Difference .. ansicolors.reset .." Mana!")
		else
			print(ansicolors.blue .. ansicolors.bright .. Ally.Name .. " ALREADY HAS MAX MANA!" .. ansicolors.reset)
		end
	end,

	["BAG"]  = function() 
		if isPlayer == true then
		
		else
			print("THIS CHARACTER HAS NO BAG!")
		end
	end,
	
	["RUN"] = function() 
		local randomResult = math.random(1, ESCAPE_ODDS)
		if randomResult == 1 then
			
		end
	end,
	}	

	local OptionsPlayer = {
		[true] = {
			[1] = "                                      ",
			[2] = "| MELEE | MAGIC | CHARGE | BAG | RUN |"
		},
		[false] = {
			[1] = "                                ",
			[2] = "| MELEE | MAGIC | CHARGE | RUN |"
		}
	}

	if #self.Enemies == 1 and self.Enemies[1].HP <= self.Enemies[1].MaxHP / 10 then
		for _, v in pairs(OptionsPlayer) do
			v[2] = v[2] .. " TALK |"
			v[1] = v[1] .. "       "
		end
		MoveOptions["TALK"] = function()
			local CoreChosenEnemy = EnemyCore[self.Enemies[1].Name]
			local EnemyChosen = self.Enemies[1]
			local newDialog = Dialog.new(CoreChosenEnemy.DialogId, self.Enemies[1], self.Player)

			local returnProtocol = newDialog:Start()
			if returnProtocol[1] == "recruit" then
				local dT = {
					Name = EnemyChosen.Name,
					MaxHP = EnemyChosen.MaxHP,
					HP = EnemyChosen.MaxHP,
					Moves = EnemyChosen.Moves,
					Speed = EnemyChosen.Speed,
					Level = EnemyChosen.Level
				}
				local convertedAlly = AllyMod.new(dT)
				Party:AddMember(convertedAlly)
				self.Fighting = false
				self.Winner = "ally"
			elseif returnProtocol[1] == "run" then
				self.Fighting = false
				self.Winner = "none"
				print(ansicolors.yellow .. ansicolors.bright .. EnemyChosen.Name .. " ran away!")
			elseif returnProtocol[1] == "giveitem" then
				self.Fighting = true
				self.Winner = "ally"
				self.Player:Give(returnProtocol[2])
			end
		end



	end

	print(ansicolors.bright .. ansicolors.cyan .. Ally.Name .. "'s " .. ansicolors.reset .. ansicolors.blue .. " turn! :: " .. ansicolors.reset .. ansicolors.bright ..  ansicolors.green  .. "[ HP: " .. Ally.HP .. "/".. Ally.MaxHP .. " ] " .. ansicolors.reset .. ansicolors.bright .. ansicolors.blue .. "[ MANA: " .. Ally.Mana .. "/" .. Ally.MaxMana .. " ] " .. ansicolors.reset)

	print(ansicolors.magenta .. ansicolors.underscore .. ansicolors.bright .. OptionsPlayer[Ally.Bag ~= nil][1] .. ansicolors.reset)
	print(ansicolors.magenta .. ansicolors.underscore .. ansicolors.bright .. OptionsPlayer[Ally.Bag ~= nil][2] .. ansicolors.reset)
	print()
	
	local chosenMove

	repeat 
		chosenMove = input.get("ENTER YOUR MOVE: "):upper()
	until MoveOptions[chosenMove]

	MoveOptions[chosenMove](Ally)

	print()

	else print(ansicolors.yellow .. ansicolors.bright .. Ally.Name .. ansicolors.dim .. " was stunned and couldn't move!" .. ansicolors.reset)
	end
	Ally:Tick()
	end

end

function Combat:EnemyTeamTurn()
	for _, Enemy in pairs(self.Enemies) do
		self:EnemyTurn(Enemy)
	end
end

function Combat:AllyTeamTurn()
	for _, Ally in pairs(self.AllyTable) do
		self:AllyTurn(Ally)
	end
end

function Combat:SummonEnemy(EnemyEntity)
	table.insert(self.Enemies, EnemyEntity)
	print(ansicolors.red .. EnemyEntity.Type .. " was summoned to the battle!" .. ansicolors.reset)
end


return Combat