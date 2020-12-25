os.setComputerLabel("Hub")
local label = os.getComputerLabel()
local hub = require("/lushTurts/apis/hub")

rednet.open("top")
rednet.host("hub", label)

while true do
    print("Waiting for orders from the homie...")
    local senderID, msg, protocol = rednet.receive()

    if(protocol == "pStart") then
        print("You got it boss. Starting up the job.")
        hub.startWork()
    else
        print("Unkown protocol: "..protocol)
    end
end