local Encrypter = {}

function string.split(inputstr, sep)
        sep = sep or "%s"
				local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function Encrypter:Encode(String)
	local Time = tostring(os.time()):sub(1, 3)

	local finalString = Time
	for i = 1, #String do
		local selectedCharacter = string.sub(String, i, i)
		local ASCIICharacter = string.byte(selectedCharacter)
		
		ASCIICharacter = ASCIICharacter + Time -  math.floor((Time / (Time / 2))) - math.floor(Time / Time ^ 2)

		finalString = finalString .. "#" .. ASCIICharacter
	end
	return finalString
end


function Encrypter:Decode(String)
	local Data = string.split(String, "#")
	local Time = Data[1]

	local Converted = ""
	for i, v in pairs(Data) do
		if i ~= 1 then
			local ASCIICharacter = v
			ASCIICharacter = (ASCIICharacter - Time) + math.floor((Time / (Time / 2))) + math.floor(Time / Time ^ 2)

			local No = tonumber(ASCIICharacter)
			ASCIICharacter = string.char(No)

			Converted = Converted .. ASCIICharacter
		end
	end
	return Converted
end


return Encrypter