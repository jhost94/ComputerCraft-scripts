local tArgs = { ... }

local y = 1
local x = 1
local d = 0

if #tArgs < 2 or tonumber(tArgs[1]) == "NaN" or tonumber(tArgs[2]) == "NaN" then
    printError("Usage yrootofx <number> <number> <number of decimal places (optional)>")
    return
end

local function calculate()
    y = tonumber(tArgs[1])
    x = tonumber(tArgs[2])

    if tArgs[3] ~= nil and tonumber(tArgs[3]) ~= "NaN" then
        d = tonumber(tArgs[3])
    end

    local start = 0
    local endN = x
    local mid = 0
    local ans = 0

    while start <= endN do
        mid = math.floor((start + endN) / 2)
        if mid ^ y == x then
            ans = mid
            break
        end

        if mid ^ y < x then
            ans = start
            start = mid + 1
        else
            endN = mid - 1
        end
    end    

    if d > 0 then
        local inc = 0.1

        for i = 1, d do
            while ans ^ y <= x do
                ans = ans + inc
            end

            ans = ans - inc
            inc = inc / 10
        end
    end

    if d > 0 then
        return (10 ^ -d) * math.floor(ans * (10 ^ d))
    end
    return ans
end

return calculate()