local tArgs = { ... }

local spaceCount = 16

--Basic verifications--


--Auxiliary functions--

local function log (m)
	if debug then
		print(m)
	end
end

local function iterateInventory(f)
	for i = 1, 16 do
		f(i)
	end
end

--Core functionality--

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

local function suckItems()
    local didSuck, err = turtle.suck()

    while verifyInventory() do
        if didSuck then
             didSuck, err = turtle.suck()
        else
             print(err)
             sleep(3)
			 didSuck, err = turtle.suck()
        end 
        sleep(0.5)
     end
end

local function dropItems()
    local didDrop, err = turtle.drop()
    verifyInventory()

    while spaceCount < 16 do
        iterateInventory(function (s)
            turtle.select(s)
            if not didDrop then 
                print(err)
                sleep(1)
            end
            didDrop, err = turtle.drop()
        end)
        if err == "No items to drop" then
            break
        end
        verifyInventory()
    end
end

local function moveItems()
    while true do
        suckItems()
        turtle.turnRight()
        turtle.turnRight()
        dropItems()
        turtle.turnLeft()
        turtle.turnLeft()
    end
end

moveItems()
