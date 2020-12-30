local func = { }
local surface = require("/lushTurts/apis/surface")
local monitor = peripheral.find("monitor")

term.redirect(monitor)
monitor.setTextScale(.5)

local width, height = monitor.getSize()

function func.initDisplay()
    monitor.clear()
    createHeader()
    createTerm()
end

function createHeader()
    local headerImg = surface.load("/lushTurts/images/header")
    local hSurf = surface.create(width, 8)
    hSurf:drawSurfaceSmall(headerImg, 0, 0)
    hSurf:output()
end

function createTerm()
    local tSurf = surface.create((width/2), (height-8))
    tSurf:fillRect(0, 0, (width/2), (height-8), colors.red)
end

function createStatus()

end

function updateDisplay()

end

return func