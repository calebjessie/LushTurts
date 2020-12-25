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
        print(msg.label.." is now registered.")
        hub.registerTurt(msg)
    else
        print("Unkown protocol: "..protocol)
    end
end

-- Register for turts is not saving