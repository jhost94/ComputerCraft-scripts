local tArgs = { ... }
local monitor = peripheral.wrap("back")
 
rednet.open("right")
 
local round = loadfile("decimalRound.lua")
 
local s,m,p = "", "", ""
local power = 0

local function getPercentage(n, m)
    return n/m * 100
end
 
local function getNumbersFromMessage(m)
    local n1, n2 = "", ""
    
    for w in m:gmatch("%d*") do
        if tonumber(w) ~= nil then
            if n1 == "" then
                n1 = tonumber(w)
            elseif n2 == "" then
                n2 = tonumber(w)
            end
        end
    end
    return n1, n2
end

function getMsg()
    monitor.setCursorPos(0, 0)
          
    s,m,p = rednet.receive("energy", 3000)
    power = round(getPercentage(getNumbersFromMessage(m)), 2)
    --rednet.broadcast("Received", "main")
 
    monitor.clear()
    
    print("Writing from id " .. s)
    
    monitor.setCursorPos(1, 1)
    --monitor.write(s)
    
    monitor.setPaletteColour(colors.green, 0x149414)
    
    monitor.setCursorBlink(true)
    monitor.setTextScale(0.5)
    monitor.setTextColour(colors.green)
    monitor.setBackgroundColour(32768)
    
    monitor.setCursorPos(1, 1)
    monitor.write(m)
    
    --monitor.setCursorPos(1, 3)
    --monitor.write(p)
end
 
monitor.clear()
 
while m ~= "close" do
    getMsg()
    print(round(getPercentage(getNumbersFromMessage(m)), 2) .. "%")
end
 
monitor.clear()
monitor.setCursorPos(1, 1)
monitor.write("Good bye :)")
