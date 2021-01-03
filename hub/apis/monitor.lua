local func = { }
local surface = require("/lushTurts/apis/surface")
local hub = require("/lushTurts/apis/hub")
local monitor = peripheral.find("monitor")

term.redirect(monitor)
monitor.setTextScale(.5)

local width, height = monitor.getSize()
local padding = 2
local page, sCount, eCount = 1, 1, 11

function func.initDisplay()
    monitor.clear()

    while true do
        local headerImg = surface.load("/lushTurts/images/header")
        local hSurf = surface.create(width, 9)
        hSurf:drawSurface(headerImg, 0, 0)

        local sSurf = surface.create(width, height)

        local upBtn = surface.load("/lushTurts/images/up-btn")
        local downBtn = surface.load("/lushTurts/images/down-btn")
        sSurf:drawSurface(upBtn, math.ceil(width/2) + 1, 9)
        sSurf:drawSurface(downBtn, math.ceil(width/2) + 1, height - 3)
        drawStatus(sSurf)

        sSurf:output()
        hSurf:output()

        local event, side, x, y = os.pullEvent("monitor_touch")

        if((x >= 42) and (y <= 12) and (y >= 10)) then
            prevPage()
        elseif((x >= 42) and (y <= 38) and (y >= 36)) then
            nextPage()
        end
    end
end

function createHeader()
    local headerImg = surface.load("/lushTurts/images/header")
    local hSurf = surface.create(width, 8)
    hSurf:drawSurface(headerImg, 0, 0)
    hSurf:output()
end

function drawStatus(surf)
    local turtles = hub.getTurtles()
    local i = 1

    for key, turt in pairs(turtles) do
        local loc = tostring("("..math.floor(turt.loc.x))..","..tostring(math.floor(turt.loc.y))..","..tostring(math.floor(turt.loc.z)..")")

        if((turt.id >= sCount) and (turt.id <= eCount)) then
            surf:drawString(tostring(turt.label), math.ceil(width/2) + 3, (i * padding) + 11, colors.black, colors.white)
            surf:drawString(tostring(loc), math.ceil(width/2) + 11, (i * padding) + 11, colors.black, colors.white)
            surf:drawString(tostring(turt.status), math.ceil(width/2) + 26, (i * padding) + 11, colors.black, colors.white)
            i = i + 1
        end
    end
end

function nextPage()
    local turtles = hub.getTurtles()

    if(math.ceil(#turtles/11) == page) then
        page = 1
        sCount = 1
        eCount = 11
    else
        page = page + 1
        sCount = sCount + 11
        eCount = eCount + 11
    end
end

function prevPage()
    local turtles = hub.getTurtles()

    if(page == 1) then
        page = math.ceil(#turtles/11)
        sCount = (page * 11) - 10
        eCount = (page * 10) + page
    else
        page = page - 1
        sCount = sCount - 11
        eCount = eCount - 11
    end
end

function updateDisplay()

end

return func
