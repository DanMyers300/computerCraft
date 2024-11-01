--
-- Turtle Woodcutter Script
-- luacheck: ignore turtle os
--

local saplingSlot = nil
local slotHasSapling = {}

local fuelSlot = nil
local slotHasFuel = {}

local slotHasJunk = {}

local function findItems()
    print("hit findItems()")
    for _ = 1, 16 do
        local itemDetail = turtle.getItemDetail(_)
        if itemDetail then
            if itemDetail.name == "minecraft:oak_sapling" and itemDetail.count >= 25 then
                if not saplingSlot or turtle.getItemDetail(saplingSlot).count <= 1 then
                    saplingSlot = _
                end
                table.insert(slotHasSapling, _)
            elseif itemDetail.name == "minecraft:coal" or itemDetail.name == "minecraft:charcoal" then
                if not fuelSlot then
                    fuelSlot = _
                end
                table.insert(slotHasFuel, _)
            else
                table.insert(slotHasJunk, _)
            end
        end
    end
end

local function refuel()
    if turtle.getFuelLevel() < 1 then
        turtle.select(fuelSlot)
        if not turtle.refuel(1) then
            print("Failed to refuel. Check fuel availability.")
        end
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
        end
    else
        findItems()
        print("No saplings found.")
    end
end

local function contains(table, item)
    for _, value in ipairs(table) do
        if value == item then
            return true
        end
    end
    return false
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
    else
        local _, err = turtle.suckDown(); if err then error(err); return false; end
    end

    findItems()
    turtle.forward()

    local _, err = turtle.dropDown(fuelSlot); if err then error(err); return false; end
    _, err = turtle.suckDown(); if err then error(err); return false; end

    findItems()
    turtle.forward()

    if saplingSlot then
        for slot = 1, 16 do
            if contains(slotHasJunk, slot) then
                turtle.select(slot)
                _, err = turtle.dropDown()
                if err then print(err) end
            end
        end
    else
        findItems()
    end

    return true
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
        end; checkRowDirection(row)
    end
end

local function main()
    if startup() and saplingSlot and fuelSlot then
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
