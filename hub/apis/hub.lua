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
function func.getNextMine()
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
    turtles[turt.label] = turt
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

function func.startWork()
	workStatus = true
	rednet.send(7, "Starting work...", "hub")

	startTurts("start", "resumeMine")

	while workStatus do
		print("Waiting for orders, new Turtles to register or request work.")
		local senderID, msg, protocol = rednet.receive("mine")

		if(msg.status) then
			print(msg.label.." is now registered.")
        	func.registerTurt(msg)
		elseif(workStatus and (msg == "work")) then
			local nextMine = func.getNextMine()
			print("Good. Next mine for you child is: ".."x: "..nextMine.x.." y: "..nextMine.y.." z: "..nextMine.z)
		
			rednet.send(senderID, nextMine, "mine")
		else
			break
		end
	end
end

function func.stopWork()
	workStatus = false
	rednet.send(7, "Stopping work...", "hub")

	while true do
		local senderID, msg, protocol = rednet.receive("mine")

		if(workStatus) then
			break
		else 
			local turtsDone = 0
			rednet.send(senderID, "stop", "mine")

			local turtles = func.getTurtles()
			turtles.senderID.status = "stopped"
			func.saveTurtles(turtles)

			for _, turt in turtles do
				if(turt.status == "stopped") then
					turtsDone = turtsDone + 1
					
					if(turtsDone == #turtles) then
						break
					end
				end
			end
		end
	end
end

function func.getStatus()
	-- Under construction
	rednet.send(7, "Sending status...", "hub")
	
end

return func