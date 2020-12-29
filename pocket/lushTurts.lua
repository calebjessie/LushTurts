local hub = rednet.lookup("hub", "Hub")
local arg = string.lower(arg[1])

rednet.open("back")

function start()
    rednet.send(hub, "start", "pStart")
    local id, msg, protocol = rednet.receive("hub")
    print(msg)
end

function stop()
    rednet.send(hub, "stop", "mine")
    local id, msg, protocol = rednet.receive("hub")
    print(msg)
end

function status()
    rednet.send(hub, "status", "pStatus")
    local id, msg, protocol = rednet.receive("hub")
    
    for key, turt in pairs(msg) do
        print(turt.label.." - "..turt.status)
    end
end

function formatStatus()

end

if(arg == "start") then
    start()
elseif(arg == "stop") then
    stop()
elseif(arg == "status") then
    status()
else
    print("Usage: lushturts [-start] | [-stop] | [-status]")
    return
end