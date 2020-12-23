os.setComputerLabel("Hub")
local hub = require("/lushTurts/apis/hub")

rednet.open("top")

-- Add in host so we can use lookup on "hub" to dynamically grab the hub computer ID rather than manually entering

while true do
    print("Waiting for orders...")
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
    else
        print("Unkown protocol: "..protocol)
    end
end