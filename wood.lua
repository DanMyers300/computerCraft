--
-- Turtle Woodcutter Script
--

local saplingSlot = nil
local fuelSlot = nil

-- Function to find the slots for saplings and fuel
local function findItems()
    for slot = 1, 16 do
        local itemDetail = turtle.getItemDetail(slot)
        if itemDetail then
            if itemDetail.name == "minecraft:oak_sapling" and not saplingSlot then
                saplingSlot = slot
            elseif itemDetail.name == "minecraft:coal" or itemDetail.name == "minecraft:charcoal" then
                fuelSlot = slot
            end
        end
        if saplingSlot and fuelSlot then
            break
        end
    end
end

-- Function to check if the turtle has saplings
local function hasSaplings()
    return saplingSlot ~= nil
end

-- Function to refuel the turtle
local function refuel()
    if turtle.getFuelLevel() < 1 and hasSaplings() then
        turtle.select(fuelSlot)
        turtle.refuel(1)
    end
end

-- Function to check and break the tree
local function checkAndBreak()
    if turtle.detect() then
        turtle.dig()
    end
end

-- Function to check if planting is possible and plant sapling
local function plantSapling()
    if saplingSlot then
        turtle.select(saplingSlot)
        if not turtle.detectDown() then
            turtle.placeDown()
        end
    end
end


local function startup()
    findItems()
    for i = 1, 2 do
        turtle.forward()
    end
end

local function rowLeft()
    turtle.turnLeft()
    turtle.forward()
    turtle.forward()
    turtle.forward()
    turtle.turnLeft()
end

local function rowRight()
    turtle.turnRight()
    turtle.forward()
    turtle.forward()
    turtle.forward()
    turtle.turnRight()
end

local function checkRowDirection(row)
    if row < 5 then
        if row % 2 == 1 then
            rowLeft()
        else
            rowRight()
        end
    end
end

local function runThroughRow(slot)
    if slot < 13 then
        turtle.forward()
    end
end

local function loop()
    for row = 1, 5 do
        for slot = 1, 13 do
            refuel()
            checkAndBreak()
            plantSapling()
            runThroughRow(slot)
        end

        checkRowDirection(row)
    end
end

local function main()
    startup()
    loop()
end

main()
