os.setComputerLabel("Hub")
local label = os.getComputerLabel()
local hub = require("/lushTurts/apis/hub")

rednet.open("top")
rednet.host("hub", label)

while true do
    print("Waiting for orders or new Turtles to register or request work.")
    local senderID, msg, protocol = rednet.receive()

    if(protocol == "pStart") then
        print("You got it boss. Sending out the turts.")
        hub.startWork()
    elseif(protocol == "pStop") then
        print("Whatever you say bud. Stopping all turt action.")
        hub.stopWork()
    elseif(protocol == "pStatus") then
        print("Here's the sitrep.")
        hub.getStatus()
    elseif(protocol == "reg") then
        registerTurt(msg)
    else
        print("Unkown protocol: "..protocol)
    end
end

function registerTurt(turt)
    local turtles = hub.getTurtles()
    turtles[turt.label] = turt
    hub.saveTurts(turtles)
end

-- Register for turts is not saving
-- Turt is starting to mine right away rather than going to assigned chunk? wtf