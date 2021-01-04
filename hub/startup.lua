os.setComputerLabel("Hub")
local label = os.getComputerLabel()
local hub = require("/lushTurts/apis/hub")
local monitor = require("/lushTurts/apis/monitor")

rednet.open("top")
rednet.host("hub", label)

monitor.initDisplay()

while true do
    local event, param1, param2, param3 = os.pullEvent()

    if (event == "rednet_message") then
        if(param3 == "pStart") then
            hub.startWork()
        elseif(param2 == "status") then
            hub.getStatus()
        end
    elseif (event == "monitor_touch") then
        if((param2 >= math.ceil(monitor.width/2) - 19) and (param2 <= math.ceil(monitor.width/2) + 19) and (param3 <= 12) and (param3 >= 10)) then
            monitor.prevPage()
        elseif((param2 >= math.ceil(monitor.width/2) - 19)  and (param2 <= math.ceil(monitor.width/2) + 19) and (param3 <= 38) and (param3 >= 36)) then
            monitor.nextPage()
        end
    end
end