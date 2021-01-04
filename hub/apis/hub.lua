local func = { }
local json = require("/lushTurts/apis/json")
local monitor = require("/lushTurts/apis/monitor")

local nextMine = {
	loc = {x,y,z},
	chunkRow,
	chunkCol
}
local chunkRow, chunkCol
local workStatus

-- Calculate the next chunk to serve
function positioning()
	if(nextMine.chunkRow < 16 and nextMine.chunkCol == 16) then
		nextMine.loc.x = nextMine.loc.x + 16
		nextMine.chunkRow = nextMine.chunkRow + 1
		nextMine.chunkCol = 1
	elseif(nextMine.chunkCol < 16) then
		if(nextMine.chunkRow % 2 == 1) then
			nextMine.loc.z = nextMine.loc.z + 16
			nextMine.chunkCol = nextMine.chunkCol + 1
		else
			nextMine.loc.z = nextMine.loc.z - 16
			nextMine.chunkCol = nextMine.chunkCol + 1
		end
	end
end

-- Save new coordinates to file
function saveNewCoords()
	local mineJson
	local mineFile = io.open("/lushTurts/data/nextMine.json", "w+")
	positioning()
	mineJson = json.encode(nextMine)
	mineFile:write(mineJson)
	mineFile:close()
end

-- Fetch new mining coordinates for a turtle
function getNextMine()
	local usMine = {}
	local mineFile = io.open("/lushTurts/data/nextMine.json", "r")
	local mineJson = mineFile:read("a")
	mineFile:close()

	usMine = json.decode(mineJson)
	
	nextMine.loc.x = usMine.loc.x
	nextMine.loc.y = usMine.loc.y
	nextMine.loc.z = usMine.loc.z
	nextMine.chunkRow = usMine.chunkRow
	nextMine.chunkCol = usMine.chunkCol

	saveNewCoords()

	return usMine.loc
end

-- Retrieve list of current turtles registered to hub
function func.getTurtles()
	local turts = {}
	local turtFile = io.open("/lushTurts/data/turts.json", "r")
	local turtJson = turtFile:read("a")
	turtFile:close()

	turts = json.decode(turtJson)
	
	for key, turtle in pairs(turts) do
		newTurts[turtle.id] = turtle
	end

	return newTurts
end

-- Save database of all turtles registered
function func.saveTurtles(turtles)
	local turtJson
	local turtFile = io.open("/lushTurts/data/turts.json", "w+")
	turtJson = json.encode(turtles)
	turtFile:write(turtJson)
	turtFile:close()
end

-- Add turtle to the turtle db
function func.registerTurt(turt)
    local turtles = func.getTurtles()
    turtles[tostring(turt.id)] = turt
    func.saveTurtles(turtles)
end

-- Send message to all turtles with the "stopped" status to resume mining
function startTurts(msg, protocol)
	local turtles = func.getTurtles()

	for key, turt in pairs(turtles) do
		if(turt.status == "Stopped") then
			rednet.send(turt.id, msg, protocol)
			turt.status = "Mining"
			func.saveTurtles(turtles)
		end
	end
end

-- Set status of a turtle
function setStatus(id, nStatus)
	local turtles = func.getTurtles()

	for key, turt in pairs(turtles) do
		if(turt.id == id) then
			turt.status = nStatus
		end
	end

	func.saveTurtles(turtles)
	monitor.drawStatus()
end

function func.startWork()
	rednet.send(7, "Starting work...", "hub")

	startTurts("start", "resumeMine")

	while true do
		local event, param1, param2, param3 = os.pullEvent()

		if (event == "rednet_message") then
			if(param2.status) then
				func.registerTurt(param2)
				monitor.drawStatus()
			elseif(param2 == "work") then
				local nextMine = getNextMine()
				rednet.send(param1, nextMine, "mine")
				monitor.drawStatus()
			elseif(param2 == "status") then
				func.getStatus()
			elseif(param2 == "stop") then
				stopWork()
				break
			elseif(param2 == "fuel") then
				local turtles = func.getTurtles()
				setStatus(param1, "out of fuel")
			end
		elseif (event == "monitor_touch") then
			if((param2 >= math.ceil(monitor.width/2) - 19) and (param2 <= math.ceil(monitor.width/2) + 19) and (param3 <= 12) and (param3 >= 10)) then
				monitor.prevPage()
				monitor.initDisplay()
			elseif((param2 >= math.ceil(monitor.width/2) - 19)  and (param2 <= math.ceil(monitor.width/2) + 19) and (param3 <= 38) and (param3 >= 36)) then
				monitor.nextPage()
				monitor.initDisplay()
			end
		end
	end
end

function stopWork()
	rednet.send(7, "Stopping work...", "hub")

	while true do
		local turtsDone = 0
		local turtles = func.getTurtles()
		local event, param1, param2, param3 = os.pullEvent()

		if (event == "rednet_message") then
			if(param2 == "status") then
				func.getStatus()
			else
				rednet.send(param1, "stop", "mine")
				setStatus(param1, "Stopped")
	
				for key, turt in pairs(turtles) do
					if(turt.status == "Stopped") then
						turtsDone = turtsDone + 1
					end
				end
	
				if(turtsDone == #turtles) then
					break
				end
			end
		elseif (event == "monitor_touch") then
			if((param2 >= math.ceil(monitor.width/2) - 19) and (param2 <= math.ceil(monitor.width/2) + 19) and (param3 <= 12) and (param3 >= 10)) then
				monitor.prevPage()
				monitor.initDisplay()
			elseif((param2 >= math.ceil(monitor.width/2) - 19)  and (param2 <= math.ceil(monitor.width/2) + 19) and (param3 <= 38) and (param3 >= 36)) then
				monitor.nextPage()
				monitor.initDisplay()
			end
		end
	end
end

-- Get the status of all turtles and send to a pocket computer
function func.getStatus()
	local turts = func.getTurtles()
	rednet.send(7, turts, "hub")
end

return func