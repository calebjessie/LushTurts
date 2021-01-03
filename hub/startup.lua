os.setComputerLabel("Hub")
local label = os.getComputerLabel()
local hub = require("/lushTurts/apis/hub")
local monitor = require("/lushTurts/apis/monitor")

rednet.open("top")
rednet.host("hub", label)

-- Need to add os.pullEvent() and use if statement to detect if rednet msg or monitor touch
-- then the rednet.receive below becomes redundant bc we can detect through pullEvent() which will still return senderID, msg, and protocol
-- The next thing would be to do the same within the startWork() function

monitor.initDisplay()

while true do
    print("Waiting for orders from the homie...")
    local senderID, msg, protocol = rednet.receive()

    if(protocol == "pStart") then
        print("You got it boss. Starting up the job.")
        hub.startWork()
    elseif(protocol == "dns") then
        print("A device pinged me ^_^")
    elseif(msg == "status") then
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