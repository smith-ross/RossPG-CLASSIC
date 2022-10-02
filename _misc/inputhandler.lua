local input = {}

function input.get(Prompt)
	io.write(Prompt)
	return io.read()
end

return input