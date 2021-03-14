local func = { }
local json = require("/lushTurts/apis/json")

-- Retrieve list of current turtles registered to hub
function func.getTurtles()
	local turts = {}
	local turtFile = io.open("/lushTurts/data/turts.json", "r")
	local turtJson = turtFile:read("a")
	turtFile:close()

	turts = json.decode(turtJson)
	
	return turts
end

function func.saveTurtles(turtles)
	local turtJson
	local turtFile = io.open("/lushTurts/data/turts.json", "w+")
	turtJson = json.encode(turtles)
	turtFile:write(turtJson)
	turtFile:close()
end

function func.orderTurts(tObj)
	local newTurts = {}

	local i = 1
	for key, turtle in pairs(tObj) do
		newTurts[i] = turtle
		i = i + 1
	end

	return newTurts
end

return func