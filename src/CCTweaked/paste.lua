local tArgs = { ... }

if #tArgs < 1 then 
	printError("Usage: ")
	printError("paste <pastebin code> <program(optional, no .lua)>")
	return
end

local code = tArgs[1]
local program = "pp.lua" -- stands for pasted program

if #tArgs > 1 then
	program = tArgs[2]
end

local rm = assert(loadfile("lib/delete.lua"))
if not rm(program) then return end

local pb = assert(loadfile("lib/pastebin.lua"))
pb("get", code, program)