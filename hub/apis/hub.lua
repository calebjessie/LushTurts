local func = { }
local json = require("/lushTurts/apis/json")

local nextMine = {
	loc = {x,y,z},
	chunkRow,
	chunkCol
}
-- local direction, chunk
local chunkRow, chunkCol

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
	local usMine  = {}
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

function func.startWork()
	rednet.send(7, "Starting work...", "hub")

	while true do
		print("Waiting for my children to request more work...")
		local senderID, msg, protocol = rednet.receive("mine")
		
		local nextMine = func.getNextMine()
		print("Good. Next mine for you child is: ".."x: "..nextMine.x.." y: "..nextMine.y.." z: "..nextMine.z)
	
		rednet.send(senderID, nextMine, "mine")
	end
end

function func.stopWork()
	-- Under construction
	rednet.send(7, "Stopping work...", "hub")
	rednet.send(senderID, "stop", "mine")
end

function func.getStatus()
	-- Under construction
	rednet.send(7, "Sending status...", "hub")
	
end

return func