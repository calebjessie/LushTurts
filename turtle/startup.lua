local mine = require("/lushTurts/apis/mine")
local tracking = require("/lushTurts/apis/tracking")
local turtLabel = os.getComputerLabel()
local turtleObj = {
    id = os.getComputerID(),
    label = turtLabel,
    status = "mining"
}
rednet.open("left")
local hubID = rednet.lookup("hub", "Hub")

-- Register turtle with the hub
rednet.send(hubID, turtleObj, "mine")

-- Get initial location of turtle
tracking.initCoords()

-- Send request for new chunk to mine. If msg is stop, then we wait for hub to resume work
while true do
    if(turtle.getFuelLevel() == 0) then
        rednet.send(hub, "fuel", "mine")
        break
    else 
        rednet.send(hubID, "work", "mine")
    end

    local senderID, msg, protocol = rednet.receive("mine")
    print("Message received father...")

    if(msg ~= "stop") then
        print("Moving to the next chunk at x: "..msg.x..", y: "..msg.y..", z: "..msg.z)
        mine.moveToChunk(msg)
    else
        print("Waiting for order to resume working.")
        local senderID, msg, protocol = rednet.receive("resumeMine")
        os.sleep(1)
    end
end