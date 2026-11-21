local tArgs = { ... }

if tonumber(tArgs[1]) == nil or tonumber(tArgs[2]) == nil then
    error("usage: decimalRound <number to round> <number of places>")
end

local n = tonumber(tArgs[1])
local r = tonumber(tArgs[2])

local function round(number, round)
    if round and round > 0 then
        local exp = 10 ^(round)
        return math.floor(number * exp + 0.5) / exp
    end
    return math.floor(number + 0.5)
end
--Since the idea for the files in this bin is to be used by other files I return the result of a single function in the end
return round(n, r)