local mine = require("/lushTurts/apis/mine")
local tracking = require("/lushTurts/apis/tracking")
local turtLabel = os.getComputerLabel()
local turtle = {
    id = os.getComputerID(),
    label = turtLabel,
    status = "mining"
}
rednet.open("left")
local hubID = rednet.lookup("hub", "Hub")

-- Register turtle with the hub
rednet.send(hubID, turtle, "reg")

-- Get initial location of turtle
tracking.initCoords()

-- Send request for new chunk to mine. If msg is stop, then we wait for hub to resume work
while true do
    rednet.send(9, "work", "mine")

    local senderID, msg, protocol = rednet.receive("mine")
    print("Message received father...")

    if(msg ~= "stop") then
        startMine(msg)
    else
        local senderID, msg, protocol = rednet.receive("resumeMine")
        os.sleep(1)
    end
end

function startMine(coords)
    print("Moving to the next chunk at x: "..coords.x..", y: "..coords.y..", z: "..coords.z)
    mine.moveToChunk(coords)
end