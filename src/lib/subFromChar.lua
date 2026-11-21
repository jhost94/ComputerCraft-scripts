local tArgs = { ... }

if #tArgs < 2 then
	printError("Usage: subStrAfter <string> <character>")
end	

local str = tArgs[1]
local c = tArgs[2]

local function getSubStr()
	local index = 1
	
	for _ in str:gmatch(".") do
		if _ == c then
			return str:sub(index + 1)
		end
		index = index + 1
	end
	return str
end

--Since the idea for the files in this bin is to be used by other files I return the result of a single function in the end
return getSubStr()