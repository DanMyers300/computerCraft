--
-- Turtle Woodcutter Script
-- luacheck: ignore turtle os
--
-- Current status:
--  - Able to sort inventory
--  - Able to start with correct saplings and coal
--  - Able to run through chunk and plant sapling in predug holes
--  - Able to return to home
--
-- To Do:
--  - Make wait time longer
--  - Set up wood cutting function
--  - Make bot go underground to return to home
--

local saplingSlot = nil
local fuelSlot = nil
local slotHasSapling = {}
local slotHasFuel = {}
local slotHasJunk = {}

local function findItems()
    for _ = 1, 16 do
        turtle.select(_)
        local itemDetail = turtle.getItemDetail(_)
        if itemDetail then
            if itemDetail.name == "minecraft:oak_sapling" and itemDetail.count >= 25 then
                if not saplingSlot then
                    saplingSlot = _
                end
                table.insert(slotHasSapling, _)
            elseif itemDetail.name == "minecraft:coal" or itemDetail.name == "minecraft:charcoal" then
                if not fuelSlot then
                    fuelSlot = _
                end
                table.insert(slotHasFuel, _)
            elseif itemDetail.name ~= "minecraft:coal" or itemDetail.name ~= "minecraft:charcoal" or itemDetail.name ~= "minecraft:oak_sapling" then
                table.insert(slotHasJunk, _)
            else 
                if includes(slotHasSapling, _) then table.remove(slothasSapling, _) end
                if includes(slotHasFuel, _) then table.remove(slotHasFuel, _) end
                if includes(slotHasJunk, _) then table.remove(slotHasJunk, _) end
            end
        end
    end
end

local function includes(table, item)
    for _, value in ipairs(table) do
        if value == item then
            return true
        end
    end
    return false
end

local function refuel()
    if turtle.getFuelLevel() < 1 then
        turtle.select(fuelSlot)
        local _, err turtle.refuel(1); if err then error(err) end
    end
end

local function checkAndBreak()
    if turtle.detect() then
        local _, err turtle.dig()
        if err then error(err) end
    end
end

local function plantSapling()
    if saplingSlot then
        turtle.select(saplingSlot)
        if not turtle.detectDown() then
            local _, err turtle.placeDown(); if err then error(err) end
        end
    else
        error('no saplings')
    end
end

local function rowLeft()
    turtle.turnLeft()
    for _ = 1, 3 do
        local _, err = turtle.forward(); if err then error() end
    end
    turtle.turnLeft()
end

local function rowRight()
    turtle.turnRight()
    for _ = 1, 3 do
        local _, err = turtle.forward(); if err then error() end
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
        local _, err = turtle.forward()
        if err then error(err) end
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
        turtle.select(saplingSlot)
        local _, err = turtle.dropDown(); if err then error(err) end
        for _, v in ipairs(slotHasSapling) do
            if v ~= saplingSlot then
                turtle.select(v)
                if turtle.getItemDetail() then
                    _, err = turtle.dropDown(); if err then error(err) end
                else
                    table.remove(slotHasSapling, v)
                end
            end
        end
        _, err = turtle.suckDown(); if err then error(err) end
        saplingSlot = nil
    else
        local _, err = turtle.suckDown(); if err then error(err) end
    end

    findItems()
    turtle.forward()

    if fuelSlot then
        turtle.select(fuelSlot)
        local _, err = turtle.dropDown(); if err then error(err) end
        for _, v in ipairs(slotHasFuel) do
            if v ~= fuelSlot then
                turtle.select(v)
                if turtle.getItemDetail() then
                    _, err = turtle.dropDown(); if err then error(err) end
                else
                    table.remove(slotHasFuel, v)
                end
            end
        end
        _, err = turtle.suckDown(); if err then error(err) end
        fuelSlot = nil
    else
        local _, err = turtle.suckDown(); if err then error(err) end
    end

    findItems()
    turtle.forward()

    if saplingSlot then
        for slot = 1, 16 do
            if includes(slotHasJunk, slot) then
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
        local _, err = turtle.forward()
        if err then error(err) else return true end
    end

    local function moveForwardLoop(blocks)
        for _ = 1, blocks do
            moveForward()
        end
    end

    turtle.turnLeft()
    moveForwardLoop(2)
    turtle.turnLeft()
    moveForwardLoop(14)
    turtle.turnLeft()
    moveForwardLoop(14)
    turtle.turnLeft()
end

local function loop()
    startup()
    for row = 1, 5 do
        for block = 1, 13 do
            refuel()
            checkAndBreak()
            plantSapling()
            runThroughRow(block)
        end
        checkRowDirection(row)
    end
    returnToHome()
    os.sleep(300)
end
while true do loop(); end

