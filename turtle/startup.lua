local turtName = os.getComputerLabel()
local mine = require("apis/mine")
local tracking = require("apis/tracking")

rednet.open("left")

-- Get initial location of turtle
tracking.initCoords()

-- Send request for new chunk to mine
while true do
    rednet.send(9, "work", "mine")

    local senderID, msg, protocol = rednet.receive("mine")
    print("Message received father...")

    if(msg == "stop") then
        print("Stopping all work")
        break
    else
        print("Moving to the next chunk at x: "..msg.x..", y: "..msg.y..", z: "..msg.z)
        mine.moveToChunk(msg)
    end
end