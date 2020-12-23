local func = { }
local json = require("/lushTurts/apis/json")

local turtLoc = {
    coords = {x,y,z},
    cardinal = "north"
}

-- Load location from file
function func.loadLoc()
    local usLoc
    local tL = io.open("lushTurts/data/turtLoc.json", "r")
    local locJson = tL:read("a")
    tL:close()

    usLoc = json.decode(locJson)
    turtLoc.coords.x, turtLoc.coords.y, turtLoc.coords.z = usLoc.coords.x, usLoc.coords.y, usLoc.coords.z
    turtLoc.cardinal = usLoc.cardinal
end

-- Persist location values
function saveLoc()
    local turtLocJson
    local tL = io.open("lushTurts/data/turtLoc.json", "w+")
    turtLocJson = json.encode(turtLoc)
    tL:write(turtLocJson)
    tL:close()
end

-- Initialize start coordinates
function func.initCoords()
    if(gps.locate() == nil) then
        print("Cannot find GPS satelite. Please place me within range of one.")
    else
        turtLoc.coords.x, turtLoc.coords.y, turtLoc.coords.z = gps.locate()
        turtLoc.cardinal = findCard()
        saveLoc()
    end
end

-- Find the cardinal direction the turtle is facing
function findCard()
    local x, y, z = turtLoc.coords.x, turtLoc.coords.y, turtLoc.coords.z
    local nX, nY, nZ

    turtle.forward()
    nX, nY, nZ = gps.locate()
    turtle.back()

    if(nX > x) then
        return "east"
    elseif(nX < x) then
        return "west"
    elseif(nZ > z) then
        return "south"
    elseif(nZ < z) then
        return "north"
    end
end

-- Return the location
function func.getLoc()
    return turtLoc
end

-- Return the cardinal direction
function func.getCard()
    return turtLoc.cardinal
end

-- Forward adjustment
function func.turtForward()
    turtle.forward()
    
    if(turtLoc.cardinal == "north") then
        turtLoc.coords.z = turtLoc.coords.z - 1
    elseif(turtLoc.cardinal == "east") then
        turtLoc.coords.x = turtLoc.coords.x + 1
    elseif(turtLoc.cardinal == "south") then
        turtLoc.coords.z = turtLoc.coords.z + 1
    elseif(turtLoc.cardinal == "west") then
        turtLoc.coords.x = turtLoc.coords.x - 1
    end

    saveLoc()
end

-- Up adjustment
function func.turtUp()
    turtle.up()
    turtLoc.coords.y = turtLoc.coords.y + 1
    saveLoc()
end

-- Down adjustment
function func.turtDown()
    turtle.down()
    turtLoc.coords.y = turtLoc.coords.y - 1
    saveLoc()
end

-- Left turn adjustment
function func.turtLeft()
    turtle.turnLeft()

    if(turtLoc.cardinal == "north") then
        turtLoc.cardinal = "west"
    elseif(turtLoc.cardinal == "west") then
        turtLoc.cardinal = "south"
    elseif(turtLoc.cardinal == "south") then
        turtLoc.cardinal = "east"
    elseif(turtLoc.cardinal == "east") then
        turtLoc.cardinal = "north"
    end

    saveLoc()
end

-- Right turn adjustment
function func.turtRight()
    turtle.turnRight()

    if(turtLoc.cardinal == "north") then
        turtLoc.cardinal = "east"
    elseif(turtLoc.cardinal == "east") then
        turtLoc.cardinal = "south"
    elseif(turtLoc.cardinal == "south") then
        turtLoc.cardinal = "west"
    elseif(turtLoc.cardinal == "west") then
        turtLoc.cardinal = "north"
    end

    saveLoc()
end

return func