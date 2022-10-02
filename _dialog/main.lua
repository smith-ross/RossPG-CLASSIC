local Dialog = {}
Dialog.__index = Dialog

local dialogData = require("_dialog/data")
local io = require("_misc/additionalconsole")
local input = require("_misc/inputhandler")

function sleep (a) 
    local sec = tonumber(os.clock() + a); 
    while (os.clock() < sec) do 
    end 
end

require("_misc/ansicolors")

function Dialog.new(DialogID, Enemy, Player)
	local newDialog = {}
	setmetatable(newDialog, Dialog)
	newDialog.Player = Player
	newDialog.Enemy = Enemy
	newDialog.Data = dialogData[DialogID]
	newDialog.Speaker = newDialog.Data.Speaker
	newDialog.Text = newDialog.Data.Text
	newDialog.Responses = newDialog.Data.Responses
	newDialog.CurrentIndex = 1

	return newDialog
end

function Dialog:Start()
	self:Speak(self.CurrentIndex)
	return self:Next()
end

function Dialog:HandleProtocol(ProtocolInfo)
	
	local Protocol = {["id"] = ProtocolInfo[1], ["arg"] = ProtocolInfo[2]}

	local ProtocolFunc = {
			[0] = function() return Dialog.new(Protocol.arg, self.Enemy, self.Player):Start() end;

			[1] = function() return {"return to fight"} end;

			[2] = function() return {"giveitem", Protocol.arg} end;

			[3] = function() return {"recruit", Enemy} end;

			[4] = function() self.Enemy:RunAway() return {"run", self.Enemy, self.Player} end;

			[5] = function() return Protocol.args(self) end;
		}

	return ProtocolFunc[Protocol.id]()
end

function Dialog:GetResponse()
	local Responses = self.Responses
	if Responses == nil then return end 
	local relatedNumbers = {

	}
	local Numbers = 0
	for response, protocol in pairs(Responses) do
		Numbers = Numbers + 1
		print(ansicolors.red .. ansicolors.dim .. Numbers .. " |" .. ansicolors.bright .. response .. ansicolors.reset)
		relatedNumbers[Numbers] = response
	end
	local inputNumber
	repeat
		inputNumber = input.get("ENTER DIALOG CHOICE NUMBER: ")
	until relatedNumbers[tonumber(inputNumber)] ~= nil
	inputNumber = tonumber(inputNumber)
	local chosenResponse = relatedNumbers[inputNumber]
	local chosenProtocol = Responses[chosenResponse]
	return self:HandleProtocol(chosenProtocol)
end

function Dialog:Next()
	if self.Text[self.CurrentIndex + 1] then
		self.CurrentIndex = self.CurrentIndex + 1
		self:Speak(self.CurrentIndex)
	end

	if self.Text[self.CurrentIndex + 1] == nil then
		return self:GetResponse()
	end
end

function Dialog:Speak(index)
	io.clear()
	local Name = ansicolors.blue .. ansicolors.bright .. "[ " .. self.Speaker .. " ]" .. ansicolors.reset
	local TextTable = self.Text
	local chosenText = TextTable[index]
	for i = 1, chosenText:len() do
		io.clear()
		local currentSection = chosenText:sub(1, i)
		print(Name)
		print(currentSection)
		sleep(.025)
	end
	local input = input.get("")
	if not index == #self.Text then io.clear() end

end

return Dialog