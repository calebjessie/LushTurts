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
    elseif(protocol == "dns") then
        print("A device pinged me ^_^")
    elseif(protocol == "pStatus") then
       hub.getStatus()
    else
        print("Unknown protocol: "..protocol.." Message: "..tostring(msg))

        if(type(msg) == "table") then
            for key, value in pairs(msg) do
                print(key..value)
            end
        end
    end
end