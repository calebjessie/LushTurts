os.setComputerLabel("Hub")
local hub = require("hub")

rednet.open("top")

while true do
    print("Waiting for my children to request more work...")
    local senderID, msg, protocol = rednet.receive("mine")

    local nextMine = hub.getNextMine()
    print("Good. Next mine for you child is: ".."x: "..nextMine.x.." y: "..nextMine.y.." z: "..nextMine.z)

    rednet.send(senderID, nextMine, "mine")
end