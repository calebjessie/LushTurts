local func = { }
local json = require("/lushTurts/apis/json")

-- Retrieve list of current turtles registered to hub
function func.getTurtles()
	local turts = {}
	local newTurts = {}
	local turtFile = io.open("/lushTurts/data/turts.json", "r")
	local turtJson = turtFile:read("a")
	turtFile:close()

	turts = json.decode(turtJson)
	
	for key, turtle in pairs(turts) do
		newTurts[turtle.id] = turtle
	end

	return newTurts
end

function func.saveTurtles(turtles)
	local turtJson
	local turtFile = io.open("/lushTurts/data/turts.json", "w+")
	turtJson = json.encode(turtles)
	turtFile:write(turtJson)
	turtFile:close()
end

return func