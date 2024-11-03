-- luacheck: ignore turtle

local function main()
    local _, err
    local fuelSlot = nil

    local function findItems()
        for _ = 1, 16 do
            turtle.select(_)
            local itemDetail = turtle.getItemDetail(_)
            if itemDetail then
                if itemDetail.name == "minecraft:coal" or itemDetail.name ==
                    "minecraft:charcoal" then
                    if not fuelSlot then fuelSlot = _ end
                end
            end
        end
    end

    local function refuel()
        findItems()
        if fuelSlot == nil then
            print("Missing fuel")
            return false
        end
        if turtle.getFuelLevel() < 1 then
            turtle.select(fuelSlot)
            _, err = turtle.refuel(1);
            if not _ then error(err) end
        end
    end

    local function moveForward(blocks)
        for _ = 1, blocks do
            refuel()
            _, err = turtle.forward()
            if err then error(err) end
        end
    end

    refuel()
    moveForward(1)
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            if item.name == "minecraft:charcoal" or item.name == "minecraft:coal" then
                if slot ~= fuelSlot then
                    turtle.select(slot)
                    turtle.dropDown()
                end
            end
        end
    end
    if turtle.getItemDetail(fuelSlot).count <= 8 then
        turtle.suckDown()
    end
    moveForward(1)

    refuel()
    for slot = 1, 16 do
        turtle.select(slot)
        turtle.suckDown()
    end

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            if item.name ~= "minecraft:coal" and item.name ~= "minecraft:charcoal" then
                if item.name ~= "minecraft:oak_sapling" and item.name ~= "minecraft:oak_log" then
                    turtle.select(slot)
                    turtle.dropDown()
                end
            end
        end
    end

    refuel()
    turtle.turnRight()
    turtle.up()
    moveForward(3)

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and item.name == "minecraft:oak_log" then
            turtle.select(slot)
            turtle.dropDown()
        end
    end

    refuel()
    turtle.turnRight()
    moveForward(2)
    refuel()
    turtle.turnRight()
    moveForward(3)
    refuel()
    turtle.down()
    turtle.turnRight()

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and item.name == "minecraft:oak_sapling" then
            turtle.select(slot)
            turtle.dropDown()
        end
    end
end

while true do main() end
