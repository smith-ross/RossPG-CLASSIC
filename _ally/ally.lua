local Ally = {}
Ally.__index = Ally

local Weapons = require("_weapon/weaponData")
local Moves = require("_moves/moveData")
local io = require("_misc/additionalconsole")

require("_misc/ansicolors")

function Ally.new(DataTable)
  local newAlly = {}
  setmetatable(newAlly, Ally)
  
	newAlly.Name = DataTable.Name or "Protagonist"
  newAlly.MaxHP = DataTable.MaxHP or 100
  newAlly.HP = DataTable.HP or 100
  newAlly.Speed = DataTable.Speed or 3
	newAlly.Weapon = DataTable.Weapon or "Stick"
  newAlly.Moves = DataTable.Moves or {"FLAMESHOT", "CLOBBER"}
  newAlly.Level = DataTable.Level or 1
	newAlly.Mana = DataTable.Mana or 10 * (newAlly.Level == 1 and 1 or 1.5)
	newAlly.MaxMana = DataTable.MaxMana or 10 * (newAlly.Level == 1 and 1 or 1.5)
	newAlly.Stunned = false
	newAlly.EXP_Progress = DataTable.EXPProgress or 0
  newAlly.EXP_Needed = DataTable.EXPNeeded or 20 * (newAlly.Level == 1 and 1 or 1.5)
	newAlly.Status_Effects = {}
	newAlly.cache = {}

  return newAlly
end

function Ally:Tick()
	for eff, _ in pairs(self.cache) do
		self.cache[eff] = nil
	end

	for effect, duration in pairs(self.Status_Effects) do 
		if self.Status_Effects[effect][1] - 1 <= 0  then
			self.Status_Effects[effect] = nil
			self.cache[effect] = true
		else
			self.Status_Effects[effect][1] = self.Status_Effects[effect][1] - 1
		end
	end
end

function Ally:HasTag(tag_name)
	return self.Status_Effects[tag_name] ~= nil
end

function Ally:AddTag(effect_name, duration, ...)
	if self.cache[effect_name] == nil then
		self.Status_Effects[effect_name] = (self.Status_Effects[effect_name] and self.Status_Effects[effect_name] or {duration, ({...})[1]})
		print(ansicolors.red .. effect_name .. " WAS APPLIED ON " .. self.Name .. ansicolors.reset)
	else
		print(ansicolors.red .. "THE EFFECT WAS UNSUCCESSFUL!")
	end
end

function Ally:LevelUp()
	self.Level = self.Level + 1
	self.EXP_Needed = self.EXP_Needed * 2.1
	print(ansicolors.blue .. ansicolors.bright .. self.Name .. " leveled up!" .. ansicolors.reset)
	self:CheckLevelUp()
end

function Ally:CheckLevelUp()
	if self.EXP_Progress >= self.EXP_Needed then
		Ally:LevelUp()
	end
end

function Ally:GainEXP(Amount)
	self.EXP_Progress = self.EXP_Progress + Amount
	self:CheckLevelUp()
end

function Ally:SelectMove()
	return self.Moves[math.random(1, #self.Moves)]
end

function Ally:Heal(Amount)
	self.HP = math.clamp(self.HP + Amount, 0, self.MaxHP)
	print(self.Name .. " healed " .. ansicolors.green .. ansicolors.bright .. Amount  .. ansicolors.reset .. " HP!")
end

function Ally:ScaleDamage(originalDamage)
	return math.floor((originalDamage * (self.Level - .75 < 1 and 1 or self.Level - .75)))
end

function Ally:UseMove(Move, Enemy)
	local moveData = Moves[Move]
	print(ansicolors.cyan .. ansicolors.bright .. self.Name .. " used " .. ansicolors.yellow .. Move .. ansicolors.reset .. ansicolors.cyan .. ansicolors.bright .. " on " .. Enemy.Type .. "!" .. ansicolors.reset)

	Enemy:TakeDamage(self:ScaleDamage(moveData.BaseDamage))
	if Moves[Move].ApplyEffect then
		Enemy:AddTag(Moves[Move].ApplyEffect[1], Moves[Move].ApplyEffect[2], Moves[Move].ApplyEffect[3])
	end
	return Enemy
end

function Ally:Melee(Enemy)
	print(ansicolors.cyan .. ansicolors.bright .. self.Name .. " used their " .. ansicolors.dim .. self.Weapon .. ansicolors.reset .. ansicolors.cyan .. ansicolors.bright .. " on " .. Enemy.Type .. "!" .. ansicolors.reset)

	Enemy:TakeDamage(self:ScaleDamage(Weapons[self.Weapon].Damage[((math.random(1, 10) == 5 and 2 or 1))]))

	return Enemy
end

function Ally:TakeDamage(Damage, specialType)
	self.HP = (self.HP - Damage < 0 and 0 or self.HP - Damage)
	if not specialType then
		print(self.Name .. " took " .. ansicolors.red .. Damage  .. ansicolors.reset .. " damage!")
	elseif specialType == "BLEED" then
		print(self.Name .. " took " .. ansicolors.red .. Damage  .. ansicolors.reset .. " damage from bleeding!")
	end
end

return Ally
  