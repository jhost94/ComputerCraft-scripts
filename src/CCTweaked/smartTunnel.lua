local tArgs = { ... }

local height = 1
local length = 100
local debug = true

----------Basic verefications------------

if tArgs[1] == "help" then
	printError("Usage: sTunel or sTunel <height> <length> or sTunnel <length>")
	printError("Default height is 1 and default length is 100, if length is -1 it runs indefinitely")
end

if not turtle then
	printError("Requires a Turtle")
end

if #tArgs > 1 then
	if tonumber(tArgs[1]) ~= nil and tonumber(tArgs[1]) > 0 then
		height = tonumber(tArgs[1])
	end
	if tonumber(tArgs[2]) ~= nil and tonumber(tArgs[2]) >= -1 then
		length = tonumber(tArgs[2])
	end
else
	if tonumber(tArgs[1]) ~= nil and tonumber(tArgs[1]) >= -1 then
		length = tonumber(tArgs[1])
	end
end

--Specific variables

local spaceCount = 16
local starterX = 0
local starterY = 0
local starterZ = 0

local path = {}

----------Auxiliary imported functions----

local subFromChar = assert(loadfile("lib/subFromChar.lua"))

----------Auxiliary functions-------------

local function iterateInventory(f)
	for _ = 1, 16 do
		f(_)
	end
end

local function log (m)
	if debug then
		print(m)
	end
end

local function addToPath (isTracking, d)
	if isTracking then
		table.insert(path, d)
	end
end

----------Startup verefications----------

local function verifyInventory()
	iterateInventory(function (c)
		if turtle.getItemCount(c) > 0 then 
			spaceCount = spaceCount - 1
		end
	end)
	log("Inventory space: " .. spaceCount)
	return spaceCount > 0
end

local function verifyFuel(min)
	local f = turtle.getFuelLevel()
	return f > min, f
end


local function getStarterLocation()
	local x, y, z = gps.locate()
	if x == nil then
		return false
	end
	return x, y, z
end


local function startup()
	if not verifyFuel() then return false end
	if not verifyInventory() then return false end
	
	local x, y, z = getStarterLocation()

	if type(x) == "number" then
		starterX, starterY, starterZ = x, y, z
		log("Starting position:\nX: " .. starterX .. "\nY: " .. starterY .. "\nZ: " .. starterZ)
	end

	return true
end


----------Core functionality-------------

local function tryDig(dir)
	if not verifyFuel(2) then return false end
	if not verifyInventory() then return false end

	if dir == nil then
		if turtle.detect() then
			return turtle.dig()
		end
	end

	if dir == "up" then
		if turtle.detectUp() then
			return turtle.digUp()
		end
	end

	if dir == "down" then
		if turtle.detectDown() then
			return turtle.digDown()
		end
	end
end

local function inspectEast()
	turtle.turnRight()
	local b, t = turtle.inspect()
	turtle.turnLeft()
	return {isBlock = b, block = t}
end

local function inspectWest()
	turtle.turnLeft()
	local b, t = turtle.inspect()
	turtle.turnRight()
	return {isBlock = b, block = t}
end

local function verifyOre()
	local b, t = turtle.inspect()
	return b and t.tags["forge:ores"]
end

local function verifyOreDown()
	local b, t = turtle.inspectDown()
	return b and t.tags["forge:ores"]
end

local function verifyOreUp()
	local b, t = turtle.inspectUp()
	return b and t.tags["forge:ores"]
end


local function moveUp(isTracking)
	turtle.up()
	addToPath(isTracking, moveDown)
end

local function moveDown(isTracking)
	turtle.down()
	addToPath(isTracking, moveUp)
end

--Up and down are easy t get but the following cardinal directions are in relation of the placement of the turtle, just for some orientation

local function moveNorth(isTracking)
	turtle.forward()
	addToPath(isTracking, moveSouth)
end

--Might have to Fix
local function moveSouth(isTracking)
	turtle.turnRight()
	turtle.turnRight()
	turtle.forward()
	addToPath(isTracking, moveNorth)
end

local function moveEast(isTracking)
	turtle.turnRight()
	if not turtle.detect() then
		turtle.forward()
	else
		turtle.turnLeft()
		return false
	end
	addToPath(isTracking, moveWest)
end

local function moveWest()
	turtle.turnLeft()
	if not turtle.detect() then
		turtle.forward()
	else
		turtle.turnRight()
		return false
	end
	addToPath(isTracking, moveEast)
end

local function backtrack()
	path[#path]()
	table.remove(path)
	if #path > 0 then backtrack() end
end

local function trackOre()
	local isBlock, block = turtle.inspect()
	if not isBlock then return false end
	
	log("I FOUND ORES")

	tryDig()
	moveNorth(true)
	if verifyOre() then return trackOre() end

	if verifyOreDown() then
		tryDig("down")
		moveDown(true)
		return trackOre()
	end

	if verifyOreUp() then
		tryDig("up")
		moveUp(true)
		return trackOre(true)
	end

	local block = inspectEast()
	
	if block.isBlock then
		moveEast(true)
		return trackOre()
	end

	block = inspectWest()
	
	if block.isBlock then
		moveWest(true)
		return trackOre()
	end

	return false
end

--decide if normal routine or ore tracking
local function decide()
	local isBlock, block = turtle.inspect()
	if not isBlock then return false end

	log("Path length: " .. #path)
	--TODO Fix || test string.reverse() == "ero"
	--if subFromChar(subFromChar(block.name, ":"), "_") == "ore" then 
	if block.tags["forge:ores"] then
		return trackOre()
	else
		return tryDig()
	end
end

local function smartDig()
	if length ~= -1 then
		for _ = 1, length do
			if not decide() then
				log("Iteration: " .. _)
				if #path > 0 then backtrack() end
			else
				turtle.forward()
			end
		end
	else
		while true do
			if not decide() then
				if #path > 0 then backtrack() end
			else
				turtle.forward()
			end
		end
	end
end

smartDig()