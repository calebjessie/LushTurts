local turtName = os.getComputerLabel()
local mine = require("mine")
local tracking = require("tracking")

rednet.open("left")

-- Get initial location of turtle
tracking.initCoords()

-- Send request for new chunk to mine
while true do
    rednet.send(9, "work", "mine")

    local senderID, msg, protocol = rednet.receive("mine")
    print("Message received father...")
    print("Moving to the next chunk at x: "..msg.x..", y: "..msg.y..", z: "..msg.z)

    rednet.close("left")
    mine.moveToChunk(msg)
    rednet.open("left")
end