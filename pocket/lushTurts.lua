rednet.open("back")
local hub = rednet.lookup("hub", "Hub")
local arg = string.lower(arg[1])

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
    rednet.send(hub, "status", "mine")
    local id, msg, protocol = rednet.receive("hub")

    local turtTable = { }
    
    for key, turt in pairs(msg) do
        local turtStr = string.sub(turt.label, 1, 12).." - "..turt.status
        table.insert(turtTable, turtStr)
    end

    table.sort(turtTable)
    textutils.pagedTabulate(turtTable)
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