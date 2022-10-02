local Console = setmetatable({

	["clear"] = function()
								io.write("\027[H\027[2J")
							end


}, {__index = io})

return Console