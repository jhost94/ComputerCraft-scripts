--This program was made only to be used by other programs of mine, not to be used on its own
local tArgs = { ... }

if #tArgs < 1 then
	local programName = "delete"
	printError("Usage: " .. programName .. "<file name>")
	return
end

local file = fs.find(tArgs[1])[1]
if file == nil then return true end

if fs.isReadOnly(file) then
	printError("Cannot delete read-only file " .. file)
elseif fs.isDriveRoot(file) then
		printError("Cannot delete mount " .. file)
		if fs.isDir(file) then
			print("To delete its contents run " .. fs.combine(file, "*"))
		end
		return false
	else
	local ok, err = pcall(fs.delete, file)
	if not ok then
		printError((err:gsub("^pcall: ", "")))
		return false
	end
return true
end