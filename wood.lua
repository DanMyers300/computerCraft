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
        if not turtle.refuel(1) then
            print("Failed to refuel. Check fuel availability.")
        end
    elseif turtle.getFuelLevel() >= 1 then
        print("Sufficient fuel available.")
    end
end

-- Function to check and break the tree
local function checkAndBreak()
    if turtle.detect() then
        if not turtle.dig() then
            print("Failed to dig. The block may be obstructed.")
        end
    end
end

-- Function to check if planting is possible and plant sapling
local function plantSapling()
    if saplingSlot then
        turtle.select(saplingSlot)
        if not turtle.detectDown() then
            if not turtle.placeDown() then
                print("Failed to plant sapling. Check the ground below.")
            end
        else
            print("Cannot plant sapling. A block is obstructing the space below.")
        end
    else
        print("No saplings found.")
    end
end

local function startup()
    findItems()
    if not hasSaplings() or fuelSlot == nil then
        print("Missing saplings or fuel. Please check inventory.")
        return false
    end
    for i = 1, 2 do
        if not turtle.forward() then
            print("Failed to move forward during startup.")
            return false
        end
    end
    return true
end

local function rowLeft()
    turtle.turnLeft()
    for _ = 1, 3 do
        if not turtle.forward() then
            print("Failed to move forward in rowLeft.")
            return false
        end
    end
    turtle.turnLeft()
end

local function rowRight()
    turtle.turnRight()
    for _ = 1, 3 do
        if not turtle.forward() then
            print("Failed to move forward in rowRight.")
            return false
        end
    end
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
        if not turtle.forward() then
            print("Failed to move forward in runThroughRow.")
            return false
        end
    end
end

local function returnToHome()
    turtle.turnLeft()
    for _ = 1, 8 do
        if not turtle.forward() then
            print("Failed to return home.")
            return
        end
    end
    turtle.turnLeft()
    for _ = 1, 20 do
        if not turtle.forward() then
            print("Failed to return home.")
            return
        end
    end
    turtle.turnLeft()
    for _ = 1, 19 do
        if not turtle.forward() then
            print("Failed to return home.")
            return
        end
    end
    turtle.turnLeft()
    os.sleep(5)
    for _ = 1, 5 do
        if not turtle.forward() then
            print("Failed to move forward while returning home.")
            return
        end
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
    if startup() then
        loop()
        returnToHome()
    else
        print("Startup failed. Exiting script.")
    end
end

main()
