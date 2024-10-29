--
-- Turtle Woodcutter Script
-- luacheck: ignore turtle
-- luacheck: ignore os
--

local saplingSlot = nil
local fuelSlot = nil

local function findItems()
    for slot = 1, 16 do
        local itemDetail = turtle.getItemDetail(slot)
        if itemDetail then
            print("Found item: " .. itemDetail.name .. " in slot " .. slot)
            if itemDetail.name == "minecraft:oak_sapling" and itemDetail.count >= 25 then
                saplingSlot = slot
                print("Sapling found in slot " .. slot)
            else
                print("Not enough saplings: " .. itemDetail.name .. " - " .. itemDetail.count .. " - slot: ".. slot)
            end
            if itemDetail.name == "minecraft:coal" or itemDetail.name == "minecraft:charcoal" then
                fuelSlot = slot
                print("Fuel found in slot " .. slot)
            else
                error("No fuel")
            end
        end
        if fuelSlot then
            break
        end
    end
end

local function hasSaplings()
    return saplingSlot ~= nil
end

local function refuel()
    if turtle.getFuelLevel() < 1 then
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
    if fuelSlot == nil then
        print("Missing fuel")
        return false
    end

    if saplingSlot then
        local _, err = turtle.dropDown(saplingSlot); if err then error(err); return false; end
        _, err = turtle.suckDown(); if err then error(err); return false; end
        findItems()
    else
        print("No saplings found, attempting to suck from chest")
        _, err = turtle.suckDown(); if err then error(err); return false; end
    end
    findItems()
    turtle.forward()
    local _, err = turtle.dropDown(fuelSlot); if err then error(err); return false; end
    _, err = turtle.suckDown(); if err then error(err); return false; end
    findItems()
    turtle.forward()

    for slot = 1, 16 do
        if slot ~= saplingSlot and slot ~= fuelSlot then
            turtle.select(slot)
            local _, err = turtle.suckDown(); if err then print(err); end
            findItems()
        end
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

local function runThroughRow(i)
    if i < 13 then
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
end

local function loop()
    for row = 1, 5 do
        for block = 1, 13 do
            refuel()
            checkAndBreak()
            plantSapling()
            runThroughRow(block)
        end
        checkRowDirection(row)
    end
end

local function main()
    if startup() then
        if loop() then
            if returnToHome() then
                os.sleep(5)
            else
                print("returntoHome failed")
            end
        else
            print("Loop failed")
        end
    else
        print("Startup failed. Exiting script.")
    end
end

main()
