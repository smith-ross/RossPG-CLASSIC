math.randomseed(os.time())
math.random() math.random() math.random() --make sure it's random
local Enemy = {}
local EnemyMoveData = require("_enemy/enemyMoveData")
local Moves = require("_moves/moveData")
local io = require("_misc/additionalconsole")

require("_misc/ansicolors")

Enemy.__index = Enemy

function Enemy.new(Type, Level, HP, Speed)
  local newEnemy = {}

  setmetatable(newEnemy, Enemy)

  newEnemy.Type = Type or "Thug"
	newEnemy.Name = newEnemy.Type
	newEnemy.Level = Level or 1
  newEnemy.HP = HP or (math.floor(newEnemy.Level * .75 * 10)) --10 * newEnemy.Level
	newEnemy.MaxHP = HP or newEnemy.HP
  newEnemy.Speed = Speed or 5
	newEnemy.Stunned = false
	newEnemy.RanAway = false
	newEnemy.valid = true
	newEnemy.Recruited = false
	newEnemy.Status_Effects = {}
	newEnemy.cache = {}
  newEnemy.Moves = EnemyMoveData[newEnemy.Type] or {"Nothing"}

  return newEnemy
end


function Enemy:Tick()
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

function Enemy:ScaleDamage(originalDamage)
	return math.floor((originalDamage * (self.Level - .75 < 1 and 1 or self.Level - .75)))
end

function Enemy:SelectMove()
  local randomMove = self.Moves[math.random(1, #self.Moves)]
  return randomMove
end

function Enemy:UseMove(Move, Ally)
  print(self.Type .. " used " .. ansicolors.red .. ansicolors.bright .. Move .. ansicolors.reset .. "!")
	Ally:TakeDamage(self:ScaleDamage(Moves[Move].BaseDamage))
	if Moves[Move].ApplyEffect then
		Ally:AddTag(Moves[Move].ApplyEffect[1], Moves[Move].ApplyEffect[2], Moves[Move].ApplyEffect[3])
	end
	return Ally
end

function Enemy:TakeDamage(Damage, specialType)
  self.HP = self.HP - Damage
	if not specialType then
  	print(self.Type.. " took " .. ansicolors.red .. Damage ..  ansicolors.reset .. " damage!")
	elseif specialType == "BLEED" then
		print(self.Type.. " took " .. ansicolors.red .. Damage ..  ansicolors.reset .. " damage from bleeding!")
	end
  self:update()
end

function Enemy:HasTag(tag_name)
	return self.Status_Effects[tag_name] ~= nil
end

function Enemy:AddTag(effect_name, duration, ...)
	if self.cache[effect_name] == nil then
		self.Status_Effects[effect_name] = (self.Status_Effects[effect_name] and self.Status_Effects[effect_name] or {duration, ({...})[1]})
		print(ansicolors.red .. effect_name .. " WAS APPLIED ON " .. self.Name .. ansicolors.reset)
	else
		print(ansicolors.red .. "THE EFFECT WAS UNSUCCESSFUL!")
	end
end

function Enemy:CheckHP()
  return not (self.HP <= 0)
end

function Enemy:RunAway()
	self.RanAway = true
end


function Enemy:update()
  local Alive = self:CheckHP()
  if not Alive then
		self.valid = false
  end
	if self.RanAway == true then
		print(self.Type .. " ran away!")
		self.valid = false
	end
end






return Enemy