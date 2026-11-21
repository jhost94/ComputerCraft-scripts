local tArgs = { ... }
--Local variables--
local currentPos = {
    x = 0,
    y = 0
}
local startedPos = {
    x = 0,
    y = 0
}
local center = {
    x = 0,
    y = 0
}
local lastPos = {
    x = 0,
    y = 0,
    dir = 1
}
local debug = true
local spaceCount = 16
local size = 5
local radius = 3
local directions = {"north", "east", "south", "west"}
local currentDir = 1
local allowedStorageContainers = {
    "chest",
    "chests", 
    "drawers",
    "diamond_chest",
}
local allowedFuel = {
    "coal"
}
local depth = 0

--Basic verifications-
if #tArgs > 0 and tonumber(tArgs[1]) == "NaN" then
    printError("Usage: excavateCircle <size>")
else
    size = tonumber(tArgs[1])
    radius = (size - 1) / 2
end

if #tArgs > 3 and   tArgs[2] ~= nil and tonumber(tArgs[2]) ~= nil and
                    tArgs[3] ~= nil and tonumber(tArgs[2]) ~= nil and  
                    tArgs[4] ~= nil and tonumber(tArgs[2]) ~= nil then
        lastPos.x = tonumber(tArgs[2])                    
        lastPos.y = tonumber(tArgs[3])
        lastPos.dir = tonumber(tArgs[4])
    end

center.x = radius
center.y = radius

--Imported functionality
local subFromChar = assert(loadfile("lib/subFromChar.lua"))

--Auxiliary functions
local function verifyFuel(min)
    if min == nil then min = 200 end
	local f = turtle.getFuelLevel()
	return f > min, f
end

local function log (m)
	if debug then
		print(m)
	end
end

local function compareArrayWith(a, c)
    for _, e in pairs(a) do
        if e == subFromChar(c, ":") then return true end
    end
    return false
end

local function iterateInventory(f)
	for i = 1, 16 do
		f(i)
	end
end

local function refuel()
    iterateInventory(function (s)
        turtle.select(s)
        turtle.refuel()
    end)

end

----------Startup verefications----------
local function goBackUp()
    while depth > 0 do
        turtle.up()
        depth = depth - 1
    end
end

local function verifyInventory()
	local space = 16
	iterateInventory(function (c)
		if turtle.getItemCount(c) > 0 then 
			space = space - 1
		end
	end)

	spaceCount = space
	log("Inventory space: " .. spaceCount)
	return spaceCount > 0
end

--Turning and movement--

local function turnClockwise()
    turtle.turnRight()

    if currentDir == 4 then
        currentDir = 1
    else
        currentDir = currentDir + 1
    end
end

local function turnCounterClockwise()
    turtle.turnLeft()

    if currentDir == 1 then
        currentDir = 4
    else
        currentDir = currentDir - 1
    end
end

local function move()
    print("Moving")
    if not verifyFuel(2) then return false end

    if currentDir == 1 then
       currentPos.y = currentPos.y + 1
   elseif currentDir == 2 then
       currentPos.x = currentPos.x + 1
   elseif currentDir == 3 then
       currentPos.y = currentPos.y - 1
   elseif currentDir == 4 then
       currentPos.x = currentPos.x - 1
   else
        printError("Something happend")
        sleep(0.5)
        return false
   end

   if not turtle.forward() then 
        turtle.dig()
        turtle.forward()
    end
    print("Dir: " .. directions[currentDir])
    print("X: " .. currentPos.x .. "Y: " .. currentPos.y)

    sleep(0.5)
end

local function returnToLastPos()
    --Make sure its pointing North
    while currentDir ~= 1 do
        turnClockwise()
    end

    while currentPos.y < lastPos.y do
        move()
    end

    turnClockwise()

    while currentPos.x < lastPos.x do
        move()    
    end

    while currentDir ~= lastPos.dir do
        turnClockwise()
    end
end

--Core functionality--

local function startup()
    refuel()
	if not verifyFuel() then 
        printError("No fuel.") 
        return false
    end
	if not verifyInventory() then 
        printError("No Space")
        return false
    end

    if lastPos.x ~= 0 and lastPos.y ~= 0 and lastPos.dir ~= 0 then
        returnToLastPos()
    end

	return true
end

local function unload()
    local isBlock, block = turtle.inspect()
    refuel()

    log("Unloading")

    if isBlock then
        if compareArrayWith(allowedStorageContainers, subFromChar(block.name, ":")) then
            iterateInventory(function (s)
                turtle.select(s)
                turtle.drop()
            end)
        end        
        log(block.name)
    end

    if not verifyInventory() then
        printError("Couldn't unload the turtle, please make space in the chest in front of me and then type \"continue\" so I can unload.")
        local cnt = read()
        while cnt ~= "continue" do
            refuel()
            cnt = read()
        end
        unload()
    end
end

local function isInsideCircle(t, b)
    return ( ((t.x - center.x) ^ 2) + ((t.y - center.y) ^ 2) ) <= radius ^ 2 + math.pi
end

local function distanceFromCenter(t)
    return ((t.x - center.x) ^ 2) + ((t.y - center.y) ^ 2)
end

local function isHigherQuadrants()
    return currentPos.y <= radius
end

local function canDigAhead()
    local blockToCheck = {
        x = 0,
        y = 0
    }
    blockToCheck.x = currentPos.x
    blockToCheck.y = currentPos.y

    if currentDir == 1 then
        blockToCheck.y = blockToCheck.y + 1
    elseif currentDir == 2 then
        blockToCheck.x = blockToCheck.x + 1
    elseif currentDir == 3 then
        blockToCheck.y = blockToCheck.y - 1
    elseif currentDir == 4 then
        blockToCheck.x = blockToCheck.x - 1
    end

    print("Distance from center: " .. distanceFromCenter(blockToCheck))

    return isInsideCircle(blockToCheck, isHigherQuadrants()) and verifyFuel(currentPos.x + currentPos.y + 1) and verifyInventory()
end

local function isLastBlock()
    if currentPos.y == size and not canDigAhead() then
        return true
    end

    return false
end

local function returnToStartingPos()
    if currentDir == 1 then
        turnCounterClockwise()
    elseif currentDir == 2 then
        turnClockwise()
        turnClockwise()
    elseif currentDir == 3 then
        turnClockwise()
    else
         printError("Something happend")
         sleep(0.5)
         return false
    end

    while currentPos.x > startedPos.x do move() end
    turnCounterClockwise()
    while currentPos.y > startedPos.y do move() end
    unload()
end


local function taticalRetreat(location, block, a)
    lastPos.x = currentPos.x
    lastPos.y = currentPos.y
    lastPos.dir = currentDir

    returnToStartingPos()
    if block ~= nil and a ~= nil and compareArrayWith(a, block) then
        printError("Dangerous block " .. block .. " found at:")
        printError("X: " .. location.x)
        printError("Y: " .. location.y)
        printError("Z: " .. location.z)
        print("")
        print("Waiting until block is removed manually, when done please type \"continue\"")
    else
        refuel()
        if not verifyFuel(lastPos.x + lastPos.y + 100) then
            printError("Need fuel")
            printError("Put fuel in the turtle and then type \"continue\" to continue.")
        end
    end

    turnClockwise()
    turnClockwise()
    if block ~= nil and a ~= nil and compareArrayWith(a, block) then
        local cont = read()
        while cont ~= "continue" or not verifyFuel(lastPos.x + lastPos.y + 50) do
            cont = read()
            refuel()
        end
    end
end

local function digCircle(a)
    local isBlock, blockBelow = turtle.inspectDown()
    while blockBelow.name ~= "minecraft:bedrock" do
        log("Fuel: " .. turtle.getFuelLevel())
        if a ~= nil and isBlock and compareArrayWith(a, blockBelow.name) then
            for i = 1, depth do
                turtle.up()
            end
            taticalRetreat({x = currentPos.x, y = depth, z=currentPos.y}, blockBelow.name, a)
            returnToLastPos()
            sleep(0.5)
            return false, blockBelow.name
        end

        if not verifyInventory() or not verifyFuel(currentPos.x + currentPos.y + depth + 10) then
            goBackUp()
            taticalRetreat({x = currentPos.x, y = depth, z=currentPos.y}, blockBelow.name, a)
            returnToLastPos()
        end

        turtle.digDown()
        turtle.down()
        depth = depth + 1
        sleep(0.5)
        isBlock, blockBelow = turtle.inspectDown()
    end

    goBackUp()
    sleep(1)
    return true, nil
end

local function manageNegetiveCosQuadrants()
    
    if currentDir == 1 then
        turnClockwise()
        move()
        turnCounterClockwise()
        while canDigAhead() do move() end
        turnClockwise()
        turnClockwise()
    elseif currentDir == 3 then
        turnCounterClockwise()
        move()
        turnClockwise()
        while canDigAhead() do move() end
        turnClockwise()
        turnClockwise()
    end
    
end

local function managePositiveCosQuadrants()
    if isLastBlock() then return false end

    if currentDir == 1 then
        turnClockwise()
        if canDigAhead() then 
            move()
        else
            turnClockwise()
            move()
            turnCounterClockwise()
            turnCounterClockwise()
            return managePositiveCosQuadrants()
        end
        turnCounterClockwise()
        while canDigAhead() do move() end
        turnClockwise()
        turnClockwise()
    elseif currentDir == 3 then
        turnCounterClockwise()
        if canDigAhead() then
            move()
        else
            turnCounterClockwise()
            move()
            turnClockwise()
            turnClockwise()
            return managePositiveCosQuadrants()
        end
        turnClockwise()
        while canDigAhead() do move() end
        turnClockwise()
        turnClockwise()
    end
    
end

local function initialGotoCircle()
    while not canDigAhead() do
        if not move() then
            printError("WTF HAPPEND")
        end
    end
    move()
end

local function mine(a)
    if not verifyFuel(200) then 
        printError("Not enough fuel")
        return 
    end
    initialGotoCircle()

    sleep(0.5)

    while currentPos.x < radius do
        local didMine, block = digCircle(a)
        if canDigAhead() then
            move()
        else 
            manageNegetiveCosQuadrants()
        end 
    end

    while not isLastBlock() do
        local didMine, block = digCircle(a)
        if canDigAhead() then
            move()
        else
            managePositiveCosQuadrants()
        end
    end    

    returnToStartingPos()
    print("Finished")
end

if startup() then
    mine({"stella_arcanum"})
end
