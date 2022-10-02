local Party = {}
local partyMembers = {}
local MAX_MEMBERS = 4

require("_misc/ansicolors")

function Party:RemoveMember(Entity)
	for i, v in pairs(partyMembers) do
		if i == tonumber(Entity) then
			partyMembers[i] = nil
			print(ansicolors.red .. v.Name ..  " was removed from the party!" .. ansicolors.reset)
			self:hotswitch()
		end
	end
end

function Party:hotswitch()
	for i = 2, MAX_MEMBERS do
		if partyMembers[i - 1] == nil and partyMembers[i] then
			partyMembers[i - 1] = partyMembers[i]
			partyMembers[i] = nil
		end
	end
end

function Party:ChooseMember()
	local concStr = "| "
	for i = 2, MAX_MEMBERS do
		if partyMembers[i] then
			concStr = concStr .. i .. " - " .. partyMembers[i].Name .. " | "
		end
	end
	print("CHOOSE THE NUMBER TO REPLACE:")
	print(ansicolors.red .. concStr .. ansicolors.reset)
	local inputStr = io.read()
	while not tonumber(inputStr) or tonumber(inputStr) < 2 or partyMembers[tonumber(inputStr)] == nil do
		print("INVALID INPUT!")
		inputStr = io.read()
	end

	return inputStr

end

function Party:AddMember(Entity)
	if #partyMembers >= MAX_MEMBERS then Party:RemoveMember(Party:ChooseMember()) end
	partyMembers[#partyMembers + 1] = Entity
	print(ansicolors.yellow .. ansicolors.bright .. Entity.Name ..  " was added to the party!" .. ansicolors.reset)
end

function Party:GetMembers()
	return partyMembers
end




return Party