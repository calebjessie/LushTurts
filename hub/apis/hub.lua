local func = { }
local json = require("/lushTurts/apis/json")

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

	return turts
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
		if(turt.status == "stopped") then
			rednet.send(turt.id, msg, protocol)
			turt.status = "mining"
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
end

function func.startWork()
	rednet.send(7, "Starting work...", "hub")

	startTurts("start", "resumeMine")

	while true do
		print("Waiting for orders, new Turtles to register or request work.")
		local senderID, msg, protocol = rednet.receive("mine")

		if(msg.status) then
			print(msg.label.." is now registered.")
        	func.registerTurt(msg)
		elseif(msg == "work") then
			local nextMine = getNextMine()
			print("Good. Next mine for you child is: ".."x: "..nextMine.x.." y: "..nextMine.y.." z: "..nextMine.z)
			rednet.send(senderID, nextMine, "mine")
		elseif(msg == "status") then
			print("Sending the status of all turts.")
			func.getStatus()
		elseif(msg == "stop") then
			print("Whatever you say bud. Stopping all turt action.")
			stopWork()
			break
		elseif(msg == "fuel") then
			local turtles = func.getTurtles()
			print(senderID.." is out of fuel")
			setStatus(senderID, "out of fuel")
		else
			print("Not sure what this is from "..senderID.."... Message: "..msg)
			print("Just gonna wait for another message...")
		end
	end
end

function stopWork()
	rednet.send(7, "Stopping work...", "hub")

	while true do
		local turtsDone = 0
		local turtles = func.getTurtles()
		local senderID, msg, protocol = rednet.receive("mine")

		if(msg == "status") then
			func.getStatus() -- Is it possible to send an additional message to let us know we're in the process of stopping?
		else
			rednet.send(senderID, "stop", "mine")

			setStatus(senderID, "stopped")

			for key, turt in pairs(turtles) do
				if(turt.status == "stopped") then
					turtsDone = turtsDone + 1
				end
			end

			if(turtsDone == #turtles) then
				break
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