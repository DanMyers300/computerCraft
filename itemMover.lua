-- luacheck: ignore turtle os

local function main()
    local _, err
    local fuelSlot = nil

    local importantItems = {
        "minecraft:oak_log",
        "minecraft:oak_sapling",
        "minecraft:coal",
        "minecraft:charcoal",
    }

    local function refuel()
        if turtle.getFuelLevel() < 1 then
            for slot = 1, 16 do
                turtle.select(slot)
                local item = turtle.getItemDetail()
                if item and item.name == "minecraft:coal" or item.name == "minecraft:charcoal" then
                    fuelSlot = slot
                end
            end
            if fuelSlot == nil then
                print("Missing fuel")
                return false
            else
                turtle.select(fuelSlot)
                _, err = turtle.refuel(1);
                if not _ then error(err) end
            end
        end
    end

    local function doesNotInclude(table, item)
        for _, value in ipairs(table) do
            if value ~= item then return true end
        end
        return false
    end

    refuel()
    _, err = turtle.forward()
    if err then error(err) end
    if turtle.getItemDetail(fuelSlot).count <= 8 then
        turtle.suckDown()
    end
    _, err = turtle.forward()
    if err then error(err) end

    refuel()
    for slot = 1, 16 do
        turtle.select(slot)
        turtle.suckDown()
    end

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and doesNotInclude(importantItems, item.name) then
            turtle.select(slot)
            turtle.dropDown()
        end
    end

    refuel()
    turtle.turnRight()
    turtle.Up()
    _, err = turtle.forward()
    if err then error(err) end
    _, err = turtle.forward()
    if err then error(err) end
    _, err = turtle.forward()
    if err then error(err) end

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and item.name == "minecraft:oak_log" then
            turtle.select(slot)
            turtle.dropDown()
        end
    end

    refuel()
    turtle.turnRight()
    _, err = turtle.forward()
    if err then error(err) end
    _, err = turtle.forward()
    if err then error(err) end
    refuel()
    turtle.turnRight()
    _, err = turtle.forward()
    if err then error(err) end
    _, err = turtle.forward()
    if err then error(err) end
    _, err = turtle.forward()
    if err then error(err) end
    refuel()
    turtle.Down()
    turtle.turnRight()

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and item.name == "minecraft:oak_sapling" then
            turtle.select(slot)
            turtle.dropDown()
        end
    end
end

main()
