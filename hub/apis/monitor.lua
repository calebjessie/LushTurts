local func = { }
local surface = require("/lushTurts/apis/surface")
local turtFile = require("/lushTurts/apis/turtFile")
local monitor = peripheral.find("monitor")

term.redirect(monitor)
monitor.setTextScale(.5)

func.width, func.height = monitor.getSize()
local padding = 2
local page, sCount, eCount = 1, 1, 11
local sSurf = surface.create(func.width, func.height)

function func.initDisplay()
    monitor.clear()
    local headerImg = surface.load("/lushTurts/images/header")
    local hSurf = surface.create(func.width, 9)
    hSurf:drawSurface(headerImg, 0, 0)

    func.drawStatus()

    sSurf:output()
    hSurf:output()
end

function func.drawStatus()
    sSurf:clear(colors.black)
    local turtles = turtFile.getTurtles()
    local i = 1

    local upBtn = surface.load("/lushTurts/images/up-btn")
    local downBtn = surface.load("/lushTurts/images/down-btn")
    sSurf:drawSurface(upBtn, math.ceil(func.width/2) - 19, 9)
    sSurf:drawSurface(downBtn, math.ceil(func.width/2) - 19, func.height - 3)

    if (#turtles ~= 0) then
        for key, turt in pairs(turtles) do
            local loc = tostring("("..math.floor(turt.loc.x))..","..tostring(math.floor(turt.loc.y))..","..tostring(math.floor(turt.loc.z)..")")

            if((turt.id >= sCount) and (turt.id <= eCount)) then
                if(turt.status == "Stopped" or turt.status == "Out of fuel") then
                    sSurf:fillRect(math.ceil(func.width/2 - 27), (i * padding) + 11, 2, 1, colors.red)
                else
                    sSurf:fillRect(math.ceil(func.width/2 - 27), (i * padding) + 11, 2, 1, colors.green)
                end
                sSurf:drawString(tostring(turt.label), math.ceil(func.width/2) - 24, (i * padding) + 11, colors.black, colors.white)
                sSurf:drawString(tostring(turt.status), math.ceil(func.width/2) - 2, (i * padding) + 11, colors.black, colors.white)
                sSurf:drawString(tostring(loc), math.ceil(func.width/2) + 13, (i * padding) + 11, colors.black, colors.white)
                i = i + 1
            end
        end
    else
        local emptyText = "Add your first turtle to get started."
        sSurf:drawString(emptyText, math.ceil(func.width/2) - math.ceil(string.len(emptyText) - (string.len(emptyText)/2)), (func.height/2) + 3, colors.black, colors.white)
    end
end

function func.nextPage()
    local turtles = turtFile.getTurtles()

    if(math.ceil(#turtles/11) == page) then
        page = 1
        sCount = 1
        eCount = 11
    else
        page = page + 1
        sCount = sCount + 11
        eCount = eCount + 11
    end

    func.drawStatus()
end

function func.prevPage()
    local turtles = turtFile.getTurtles()

    if(page == 1) then
        page = math.ceil(#turtles/11)
        sCount = (page * 11) - 10
        eCount = (page * 10) + page
    else
        page = page - 1
        sCount = sCount - 11
        eCount = eCount - 11
    end

    func.drawStatus()
end

return func