local function main()
    local _, err
    local importantItems = {
        "minecraft:oak_log",
        "minecraft:oak_sapling",
        "minecraft:coal",
        "minecraft:charcoal",
    }

    local function doesNotInclude(table, item)
        for _, value in ipairs(table) do
            if value ~= item then return true end
        end
        return false
    end

    _, err = turtle.forward()
    if err then error(err) end
    _, err = turtle.forward()
    if err then error(err) end

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

    turtle.turnRight()
    _, err = turtle.forward()
    if err then error(err) end
    _, err = turtle.forward()
    if err then error(err) end
    turtle.turnRight()
    _, err = turtle.forward()
    if err then error(err) end
    _, err = turtle.forward()
    if err then error(err) end
    _, err = turtle.forward()
    if err then error(err) end
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
