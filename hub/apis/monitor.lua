-- Display stats upon running startup.lua

local func = { }
local surface = require("/lushTurts/apis/surface")
local monitor = peripheral.find("monitor")

term.redirect(monitor)
monitor.setTextScale(.5)

local w, h = monitor.getSize()

function func.initDisplay()
    monitor.clear()
    createHeader()
end

function createHeader()
    local headerImg = surface.load("/lushTurts/images/headerImg")
    local hSurf = surface.create(headerHeight, headerWidth)
    hSurf:drawSurface(headerImg, 0, 0)
    hSurf:output()
end

function updateDisplay()

end

return func