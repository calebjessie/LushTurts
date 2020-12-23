local arg = string.lower(arg[1])

rednet.open("back")

function start()
    rednet.send(9, "start", "pStart")
    local id, msg, protocol = rednet.receive("hub")
    print(msg)
end

function stop()
    rednet.send(9, "stop", "pStop")
    local id, msg, protocol = rednet.receive("hub")
    print(msg)
end

function status()
    rednet.send(9, "status", "pStatus")
    local id, msg, protocol = rednet.receive("hub")
    print("Need to figure out how to display turtle stats")
end

if arg == "start" then
    start()
elseif arg == "stop" then
    stop()
elseif arg == "status" then
    status()
else
    print("Usage: lushturts [-start] | [-stop] | [-status]")
    return
end