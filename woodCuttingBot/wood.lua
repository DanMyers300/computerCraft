--
-- Turtle Woodcutter Script
--

local saplingSlot = nil
local fuelSlot = nil

local function findItems()
    for slot = 1, 16 do
        local itemDetail = turtle.getItemDetail(slot)
        if itemDetail then
            print("Found item: " .. itemDetail.name .. " in slot " .. slot)
            if itemDetail.name == "minecraft:oak_sapling" and not saplingSlot then
                saplingSlot = slot
                print("Sapling found in slot " .. slot)
            elseif itemDetail.name == "minecraft:coal" or itemDetail.name == "minecraft:charcoal" then
                fuelSlot = slot
                print("Fuel found in slot " .. slot)
            end
        end
        if saplingSlot and fuelSlot then
            break
        end
    end
end

local function hasSaplings()
    return saplingSlot ~= nil
end

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

local function checkAndBreak()
    if turtle.detect() then
        if not turtle.dig() then
            print("Failed to dig. The block may be obstructed.")
        end
    end
end

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
    refuel()
    print("Sapling Slot: " .. tostring(saplingSlot))
    print("Fuel Slot: " .. tostring(fuelSlot))
    
    if not hasSaplings() or fuelSlot == nil then
        print("Missing saplings or fuel. Please check inventory.")
        return false
    end

    return true
end

local function rowLeft()
    turtle.turnLeft()
    for _ = 1, 3 do
        local success, err = turtle.forward()
        if not success then
            print("Failed to move forward in rowLeft: " .. (err or "unknown error"))
            return false
        end
    end
    turtle.turnLeft()
end

local function rowRight()
    turtle.turnRight()
    for _ = 1, 3 do
        local success, err = turtle.forward()
        if not success then
            print("Failed to move forward in rowRight: " .. (err or "unknown error"))
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
        local success, err = turtle.forward()
        if not success then
            print("Failed to move forward in runThroughRow: " .. (err or "unknown error"))
            return false
        end
    end
end

local function returnToHome()
    local function moveForward()
        refuel()
        local success, err = turtle.forward()
        if not success then
            print("Error moving forward: " .. (err or "unknown error"))
            return false
        end
        return true
    end

    turtle.turnLeft()
    for _ = 1, 2 do
        if not moveForward() then return end
    end
    turtle.turnLeft()
    for _ = 1, 14 do
        if not moveForward() then return end
    end
    turtle.turnLeft()
    for _ = 1, 14 do
        if not moveForward() then return end
    end
    turtle.turnLeft()
    os.sleep(5)
end

local function loop()
    for row = 1, 5 do
        for slot = 1, 13 do
            findItems()
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
