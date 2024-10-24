local width         --amount of trees wide of the tree farm
local length        --amount of tree length of the tree farm
local treeDistance  --the distance of blocks between
local sleepTime     --the amount of time between the turtle checking the tree farm for grown trees
local pos           --current distance from the starting point
local direction     --current direction turtle is facing

local function fuelCheck()
    if turtle.getFuelLevel() == 0 then
        for i = 1, 16 do
            if turtle.getFuelLevel() > 0 then
                break
            end

            turtle.select(i)
            
            if turtle.getItemDetail() and turtle.getItemDetail().name ~= "minecraft:oak_sapling" then
                turtle.refuel(1)
            end
        end
    end

    if turtle.getFuelLevel() < 1 then
        print("Out of Fuel")
        returnHome()
        os.exit()
    end
end


local function up()
    fuelCheck()
    
    if turtle.up() then
        pos.y = pos.y + 1
    end
end

local function down()
    fuelCheck()

    if turtle.down() then
        pos.y = pos.y - 1
    end
end

local function forward()
    fuelCheck()

    if turtle.forward() then
        if direction == 0 then
            pos.z = pos.z + 1
        elseif direction == 1 then
            pos.x = pos.x + 1
        elseif direction == 2 then
            pos.z = pos.z - 1
        elseif direction == 3 then
            pos.x = pos.x - 1
        else
            print("Unknown direction")
            os.exit()
        end
    end
end

local function left()
    if turtle.turnLeft() then
        direction = math.abs((direction - 1) % 4)
    end
end

local function right()
    if turtle.turnRight() then
        direction = math.abs((direction + 1) % 4)
    end
end

local function moveToNextTree()
    local i=0
    while i <= treeDistance do
        turtle.dig()
        forward()
        i = i + 1
    end
end

local function mineTree()
    local success, data = turtle.inspectUp()

    if success and data.name == "minecraft:oak_log" then
        turtle.digDown()
    end
    
    while success and data.name == "minecraft:oak_log" do
        turtle.digUp()
        up()
        success, data = turtle.inspectUp()
    end

    local y = pos.y
    while pos.y > 0 do
        down()
    end
end

local function plantSapling()
    local i = 1
    while i <= 16 do
        turtle.select(i)
        local itemDetails = turtle.getItemDetail()
        if itemDetails ~= nil and itemDetails.name == "minecraft:oak_sapling" then
            turtle.placeDown()
            break;
        end
        i = i + 1
    end
end

local function turnAround(turnRight)
    moveToNextTree()
    if turnRight then
        right()
    else
        left()
    end
    moveToNextTree()
    if turnRight then
        right()
    else
        left()
    end

    return not turnRight
end

local function returnHome()
    if pos.z == 0 then
        left()
    else
        while pos.z > 0 do
            forward()
        end
    
        right()
    end

    while pos.x > 0 do
        forward()
    end

    right()
end

local function depositeWood()
    while direction ~= 2 do
        right()
    end

    local i = 1
    while i <= 16 do
        turtle.select(i)
        local itemDetails = turtle.getItemDetail()
        if itemDetails ~= nil and itemDetails.name == "minecraft:oak_log" then
            turtle.drop()
        end
        i = i + 1
    end
end

local function init()
    width = 5;
    length = 5;
    treeDistance = 1;
    sleepTime = 1;
    pos = {
        x=0,
        y=0,
        z=0,
    }
    direction = 0;
end

local function loop()
    while true do
        local turnRight = true

        for wid = 1, width do
            for len = 1, length do
                -- Move to the position where we need to plant
                moveToNextTree()
                plantSapling()  -- Plant sapling at the current position
            end
            if wid < width then
                turnAround(true)  -- Turn around for the next row
            end
        end
    
        returnHome()  -- Go home after initial planting
        -- Move through the tree farm
        while direction ~= 0 do
            right()
        end

        local widDist = 0
        while widDist < width do
            local lenDist = 0
            while lenDist < length do
                moveToNextTree()
                mineTree()
                plantSapling()
                lenDist = lenDist + 1
            end
            
            turnRight = turnAround(turnRight)
            widDist = widDist + 1
        end

        returnHome()
        depositeWood()

        os.sleep(sleepTime)
    end
end

init()
loop()
