-- luacheck: ignore turtle os
local saplingSlot = nil
local fuelSlot = nil
local couldBeTree = false
local slotHasSapling = {}
local slotHasFuel = {}
local slotHasJunk = {}

local function includes(table, item)
    for _, value in ipairs(table) do if value == item then return true end end
    return false
end

local function findItems()
    for _ = 1, 16 do
        turtle.select(_)
        local itemDetail = turtle.getItemDetail(_)
        if itemDetail then
            if itemDetail.name == "minecraft:oak_sapling" and itemDetail.count >=
                25 then
                if not saplingSlot then saplingSlot = _ end
                table.insert(slotHasSapling, _)
            elseif itemDetail.name == "minecraft:coal" or itemDetail.name ==
                "minecraft:charcoal" then
                if not fuelSlot then fuelSlot = _ end
                table.insert(slotHasFuel, _)
            elseif itemDetail.name ~= "minecraft:coal" then
                if itemDetail.name ~= "minecraft:charcoal" then
                    if itemDetail.name ~= "minecraft:oak_sapling" then
                        table.insert(slotHasJunk, _)
                    end
                end
            else
                if includes(slotHasSapling, _) then
                    table.remove(slotHasSapling, _)
                end
                if includes(slotHasFuel, _) then
                    table.remove(slotHasFuel, _)
                end
                if includes(slotHasJunk, _) then
                    table.remove(slotHasJunk, _)
                end
            end
        end
    end
end

local function refuel()
    if fuelSlot == nil then
        print("Missing fuel")
        return false
    end
    if turtle.getFuelLevel() < 1 then
        turtle.select(fuelSlot)
        local _, err = turtle.refuel(1);
        if not _ then error(err) end
    end
end

local function plantSapling()
    if saplingSlot then
        turtle.select(saplingSlot)
        if not turtle.detectDown() then
            local _, err = turtle.placeDown();
            if not _ then error(err) end
        end
    else
        error('no saplings')
    end
end

local function destroyTree()
    local blocksMovedUp = 0

    local function moveUp()
        refuel()
        local _, err = turtle.up()
        if err then error(err) end
        blocksMovedUp = blocksMovedUp + 1
    end

    refuel()

    local _, err = turtle.inspectDown()
    if _ and err.name == "minecraft:oak_log" or err.name ~= "minecraft:grass_block" then
        _, err = turtle.digDown()
        if err then error(err) end
        plantSapling()
    end

    while true do
        _, err = turtle.inspectUp()
        if _ and err.name ~= "minecraft:oak_leaves" then
            _, err = turtle.digUp()
            if err then error(err) end
            moveUp()
        else
            for _ = 1, blocksMovedUp do
                refuel()
                _, err = turtle.down()
                if err then error(err) end
            end
            break
        end
    end
end

local function moveForward(blocks)
    for _ = 1, blocks do
        local _, info = turtle.inspect()
        refuel()
        if _ then
            if info.name == "minecraft:oak_log" then
                couldBeTree = true
            end
            local _, err = turtle.dig()
            if err then error(err) end
        end

        local a, err = turtle.forward()
        if not a then
            if err == string.find(err, "obstructed") then
                turtle.dig()
                turtle.forward()
            else
                error(err)
            end
        end

        _, info = turtle.inspectUp()
        if _ then
            if info.name == "minecraft:oak_log" and couldBeTree then
                destroyTree()
            end
        end
    end

    if couldBeTree then couldBeTree = false end
end

local function checkRowDirection(row)
    if row < 5 then
        if row % 2 == 1 then
            turtle.turnLeft()
            moveForward(3)
            turtle.turnLeft()
        else
            turtle.turnRight()
            moveForward(3)
            turtle.turnRight()
        end
    end
end

local function runThroughRow(i) if i < 13 then moveForward(1) end end

local function ensureSapling()
    if saplingSlot then
        turtle.select(saplingSlot)
        local _, err = turtle.dropDown();
        if err then error(err) end
        for _, v in ipairs(slotHasSapling) do
            if v ~= saplingSlot then
                turtle.select(v)
                if turtle.getItemDetail() then
                    _, err = turtle.dropDown();
                    if err then error(err) end
                else
                    table.remove(slotHasSapling, v)
                end
            end
        end
        _, err = turtle.suckDown();
        if err then error(err) end
        saplingSlot = nil
    else
        local _, err = turtle.suckDown();
        if err then error(err) end
    end
end

local function ensureFuel()
    if fuelSlot then
        turtle.select(fuelSlot)
        local _, err = turtle.dropDown();
        if err then error(err) end
        for _, v in ipairs(slotHasFuel) do
            if v ~= fuelSlot then
                turtle.select(v)
                if turtle.getItemDetail() then
                    _, err = turtle.dropDown();
                    if err then error(err) end
                else
                    table.remove(slotHasFuel, v)
                end
            end
        end
        _, err = turtle.suckDown();
        if err then error(err) end
        fuelSlot = nil
    else
        local _, err = turtle.suckDown();
        if err then error(err) end
    end
end

local function dumpJunk()
    if saplingSlot then
        for slot = 1, 16 do
            if includes(slotHasJunk, slot) then
                turtle.select(slot)
                local _, err = turtle.dropDown()
                if err then print(err) end
            end
        end
    else
        findItems()
    end
end

local function startup()
    findItems()
    print("Sapling Slot: " .. tostring(saplingSlot))
    print("Fuel Slot: " .. tostring(fuelSlot))
    refuel()
    ensureSapling()
    findItems()
    moveForward(1)
    ensureFuel()
    findItems()
    moveForward(1)
    dumpJunk()
end

local function returnToHome()
    turtle.turnLeft()
    moveForward(2)
    turtle.turnLeft()
    moveForward(14)
    turtle.turnLeft()
    moveForward(14)
    turtle.turnLeft()
end

local function loop()
    startup()
    for row = 1, 5 do
        for block = 1, 13 do
            refuel()
            plantSapling()
            runThroughRow(block)
        end
        checkRowDirection(row)
    end
    returnToHome()
end

while true do loop(); end

