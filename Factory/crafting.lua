local config = require("config")
local functions = require("functions")
local peripherals = require("peripherals")

print('All Periphals on System')
local allPeriphals = peripheral.getNames()
functions.debugTable(allPeriphals)
print('-----')

function setupMonitor()
    peripherals.topMonitor.clear()

    local storageList = peripherals.storageDrawers.list()

    for item, itemInfo in pairs(config.recipes) do

        print('Adding ' .. item .. ' to the Monitor')
        local itemCount = functions.getItemCountInStorage(storageList, itemInfo.itemName)
        local boardText = itemInfo.name .. ': ' .. itemCount
        local textColor = functions.fetchTextColors(itemInfo, boardText, 'ready', 'font')
        local backgroundColor = functions.fetchTextColors(itemInfo, boardText, 'ready', 'bck')
        peripherals.topMonitor.setCursorPos(itemInfo.monX, itemInfo.lineNum)
        peripherals.topMonitor.blit(boardText, textColor, backgroundColor)
    end
end

setupMonitor()
local allowClick = true

while allowClick do
    local event, side, x, y = os.pullEvent("monitor_touch")
    if side == 'top' then
        for item, itemInfo in pairs(config.recipes) do
            if itemInfo.lineNum == y then

                local storageList = peripherals.storageDrawers.list()
                local itemCount = functions.getItemCountInStorage(storageList, itemInfo.itemName)
                local boardText = itemInfo.name .. ': ' .. itemCount

                local textColor = functions.fetchTextColors(itemInfo, boardText, 'busy', 'font')
                local backgroundColor = functions.fetchTextColors(itemInfo, boardText, 'busy', 'bck')
                peripherals.topMonitor.setCursorPos(itemInfo.monX, itemInfo.lineNum)
                peripherals.topMonitor.clearLine()
                peripherals.topMonitor.blit(boardText, textColor, backgroundColor)
                local result = functions.processItem(itemInfo)
                if result == 'completed' then
                    local storageList = peripherals.storageDrawers.list()
                    local itemCount = functions.getItemCountInStorage(storageList, itemInfo.itemName)
                    local boardText = itemInfo.name .. ': ' .. itemCount

                    local textColor = functions.fetchTextColors(itemInfo, boardText, 'ready', 'font')
                    local backgroundColor = functions.fetchTextColors(itemInfo, boardText, 'ready', 'bck')
                    peripherals.topMonitor.setCursorPos(itemInfo.monX, itemInfo.lineNum)
                    peripherals.topMonitor.blit(boardText, textColor, backgroundColor)
                end
            end
        end
    end
end
