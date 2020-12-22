-- Load Configs
local config = require("/data/config")
local tracking = require("/apis/tracking")
local func = { }

function dropItems()
  print("Looking for garbo to drop")
  for slot = 1, config.SLOT_COUNT do
    local item = turtle.getItemDetail(slot)
    if item then
      for _, i in pairs(config.DROPPED_ITEMS) do
        if(item["name"] == i) then
          print("Dropping "..item["name"])
          turtle.select(slot)
          turtle.dropDown()
        end
      end
    end
  end
end

function searchInv(rItem)
  for slot = 1, config.SLOT_COUNT do
    local sItem = turtle.getItemDetail(slot)
    if sItem and (sItem["name"] == rItem) then
      return slot
    end
  end
  return nil
end

function manageInventory()
    dropItems()

    index = searchInv("enderstorage:ender_storage")
    if(index ~= nil) then
        repeat
          turtle.digUp()
          detect = turtle.detectUp()
        until(detect == false)

        turtle.select(index)
        turtle.digUp()
        turtle.placeUp()
    end
    -- Chest is now deployed

    for slot = 1, config.SLOT_COUNT, 1 do
        local item = turtle.getItemDetail(slot)
        if(item ~= nil) then
            if(item["name"] ~= "minecraft:coal_block" and item["name"] ~= "minecraft:coal") then
                turtle.select(slot)
                turtle.dropUp()
            end
        end
    end
    -- Items are now stored

    turtle.digUp()
    -- Dig chest
end

function checkFuel()
    turtle.select(1)

    if(turtle.getFuelLevel() < 50) then
        print("Attempting Refuel...")
        for slot = 1, config.SLOT_COUNT, 1 do
            turtle.select(slot)
            if(turtle.refuel(1)) then
                return true
            end
        end

        return false
    else
        return true
    end
end


function detectAndDig()
    while(turtle.detect()) do
        turtle.dig()
        turtle.digUp()
        turtle.digDown()
    end
end

function forward()
    detectAndDig()
    tracking.turtForward()
end

function leftTurn()
    tracking.turtLeft()
    detectAndDig()
    tracking.turtForward()
    tracking.turtLeft()
    detectAndDig()
end

function rightTurn()
    tracking.turtRight()
    detectAndDig()
    tracking.turtForward()
    tracking.turtRight()
    detectAndDig()
end

-- Movement, add tracking
function turnAround(tier)
    local d = tracking.getCard()

    if(tier % 2 == 1) then
        if(d == "north" or d == "east") then
            rightTurn()
        elseif(d == "south" or d == "west") then
            leftTurn()
        end
    else
        if(d == "north" or d == "east") then
            leftTurn()
        elseif(d == "south" or d == "west") then
            rightTurn()
        end
    end
end

-- Each tier is worth three y levels since we mine above and below each tier
function riseTier()
    tracking.turtRight()
    tracking.turtRight()
    
    for _, 3, do
        turtle.digUp()
        tracking.turtUp()
    end
end

function startMine()
    for tier = 1, config.mineChunk.h, 1 do
        for col = 1, config.mineChunk.w, 1 do
            for row = 1, config.mineChunk.d - 1, 1 do
                if(not checkFuel()) then
                    print("Turtle is out of fuel, Powering Down...")
                    return
                end
                forward()
                print(string.format("Row: %d   Col: %d", row, col))
            end
            if(col ~= config.mineChunk.w) then
                turnAround(tier)
            end
            manageInventory()
        end
        riseTier()
    end
end

function checkMoveForward()
    if(turtle.detect()) then
        turtle.dig()
        tracking.turtForward()
    else
        tracking.turtForward()
    end
end

function checkMoveUp()
    if(turtle.detectUp()) then
        turtle.digUp()
        tracking.turtUp()
    else
        tracking.turtUp()
    end
end

function checkMoveDown()
    if(turtle.detectDown()) then
        turtle.digDown()
        tracking.turtDown()
    else
        tracking.turtDown()
    end
end

function turnTo(card)
    local curCard = tracking.getCard()

    if(card == "north") then
        if(curCard == "east") then
            tracking.turtLeft()
        elseif(curCard == "west") then
            tracking.turtRight()
        elseif(curCard == "south") then
            tracking.turtRight()
            tracking.turtRight()
        end
    elseif(card == "east") then
        if(curCard == "west") then
            tracking.turtRight()
            tracking.turtRight()
        elseif(curCard == "north") then
            tracking.turtRight()
        elseif(curCard == "south") then
            tracking.turtLeft()
        end
    elseif(card == "south") then
        if(curCard == "east") then
            tracking.turtRight()
        elseif(curCard == "north") then
            tracking.turtRight()
            tracking.turtRight()
        elseif(curCard == "west") then
            tracking.turtLeft()
        end
    elseif(card == "west") then
        if(curCard == "east") then
            tracking.turtRight()
            tracking.turtRight()
        elseif(curCard == "north") then
            tracking.turtLeft()
        elseif(curCard == "south") then
            tracking.turtRight()
        end
    end
end

function func.moveToChunk(coords)
    local curLoc = tracking.getLoc()

    -- First we move to the right z
    while(curLoc.coords.z ~= coords.z) do
        -- Then move either south or north
        if(curLoc.coords.z < coords.z) then
            turnTo("south")
            checkMoveForward()
        elseif(curLoc.coords.z > coords.z) then
            turnTo("north")
            checkMoveForward()
        end
        curLoc = tracking.getLoc()
    end

    -- Then we get to x
    while(curLoc.coords.x ~= coords.x) do
        -- Move either east or west
        if(curLoc.coords.x < coords.x) then
            turnTo("east")
            checkMoveForward()
        elseif(curLoc.coords.x > coords.x) then
            turnTo("west")
            checkMoveForward()
        end
        curLoc = tracking.getLoc()
    end

    -- Then make sure we're at the right depth
    while(curLoc.coords.y ~= coords.y) do
        -- Chunk is above turtle
        if(curLoc.coords.y < coords.y) then
            checkMoveUp()
        end

        -- Chunk is below turtle
        if(curLoc.coords.y > coords.y) then
            checkMoveDown()
        end
        curLoc = tracking.getLoc()
    end
    
    -- Make sure we're facing the right way to start mining the chunk
    if(curLoc.cardinal ~= "east") then
        turnTo("east")
    end

    startMine()
end

return func