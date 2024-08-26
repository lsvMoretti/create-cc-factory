local config = require("config")
local peripherals = require("peripherals")

function debugTable(table)
    for k, v in pairs(table) do
        print(v)
    end
end

function loopThroughItems(loopItems)
    for slot, itemTable in pairs(loopItems) do
        local count = itemTable.count
        local name = itemTable.name
        print('Name: ' .. name .. ' - Count: ' .. count)
    end
end

function fetchSlotForItem(storage, itemName)
    for slot, itemTable in pairs(storage) do
        local name = itemTable.name
        if name == itemName then
            return slot
        end
    end
    return nil
end

function hasItemAndQuantity(storage, itemName, quantity)
    for slot, itemTable in pairs(storage) do
        local name = itemTable.name
        if name == itemName then
            local count = itemTable.count
            return count >= quantity
        end
    end
end

function getItemCountInStorage(storage, itemName)
    local totalCount = 0
    for slot, itemTable in pairs(storage) do
        local count = itemTable.count
        local name = itemTable.name
        if name == itemName then
            totalCount = totalCount + count
        end
    end
    return totalCount
end

function fetchTextColors(itemInfo, text, colorType, fontOrBack)
    local strLen = string.len(text)
    local textColor = ""
    local backgroundColor = ""
    for i = 1, strLen do
        if colorType == 'ready' then
            textColor = textColor .. itemInfo.colors.readyFont
            backgroundColor = backgroundColor .. itemInfo.colors.readyBck
        end
        if colorType == 'busy' then
            textColor = textColor .. itemInfo.colors.busyFont
            backgroundColor = backgroundColor .. itemInfo.colors.busyBck
        end
        if colorType == 'error' then
            textColor = textColor .. itemInfo.colors.errorFont
            backgroundColor = backgroundColor .. itemInfo.colors.errorFont
        end
    end

    if fontOrBack == 'font' then
        return textColor
    else
        return backgroundColor
    end
end

function sendItemRecipeToMixer(processInfo)
    print(processInfo.output)
    processInfo.outputAmount = 1
    local waitToProcess = true
    while waitToProcess do
        -- Loop through Basins and wait for a free basin
        for k, basinInfo in pairs(config.mixers) do
            local basin = peripheral.wrap(basinInfo.name)
            local currrentFilter = basin.getFilterName()
            if currrentFilter == config.emptyFilterName then
                -- We have found a free basin
                print('Sending to Basin ' .. k)
                basin.setFilterItem(processInfo.output)
                for _, item in ipairs(processInfo) do
                    local storageItems = peripherals.storageDrawers.list()
                    local slot = fetchSlotForItem(storageItems, item.itemName)
                    peripherals.storageDrawers.pushItems(basinInfo.name, slot, item.amount)
                end
                waitToProcess = false
                local waitingToFinish = true
                while waitingToFinish do
                    -- Wait for item to finish
                    local items = basin.list()
                    local waiting = hasItemAndQuantity(items, processInfo.output, processInfo.outputAmount)
                    if waiting ~= nil then
                        -- item has finished
                        print('Looks like I have enough')
                        waitingToFinish = false
                        break
                    end

                    if waitingToFinish then
                        -- Waiting for item to finish
                        print('Waiting for Recipie to complete required amount: ' .. processInfo.outputAmount)
                        sleep(1)
                    end
                end
                -- Clear basin and remove filters
                basin.clearFilterItem()
                local basinItems = basin.list()
                local slot = fetchSlotForItem(basinItems, processInfo.output)
                print('Got items in slot: ' .. slot)
                basin.pushItems(config.storageControllerName, slot, processInfo.outputAmount)
                break
            end
        end

        if waitToProcess then
            print('Waiting for a free basin')
            sleep(1)
        end
    end
end

function sendErrorToDisplay(itemInfo, errorText)
    peripherals.topMonitor.setCursorPos(itemInfo.monX, itemInfo.lineNum)
    peripherals.topMonitor.clearLine()

    local storageList = peripherals.storageDrawers.list()
    local itemCount = getItemCountInStorage(storageList, itemInfo.itemName)
    local boardText = itemInfo.name .. ': ' .. itemCount
    local textColor = fetchTextColors(itemInfo, boardText, 'error', 'font')
    local backgroundColor = fetchTextColors(itemInfo, boardText, 'error', 'bck')
    peripherals.topMonitor.blit(boardText, textColor, backgroundColor)
    print('Missing some items during the process for ' .. itemInfo.name)
    print('Error: ' .. errorText)
end

function processItem(itemData)
    print(itemData.name)
    for k, processInfo in pairs(itemData.processes) do
        if processInfo.type == 'mix' then
            local missingItems = false
            local storageSystemItems = peripherals.storageDrawers.list()
            for _, item in ipairs(processInfo) do
                local hasItems = hasItemAndQuantity(storageSystemItems, item.itemName, item.amount)
                if hasItems == nil then
                    sendErrorToDisplay(itemData, 'Missing ' .. item.itemName .. ' - Qty: ' .. item.amount)
                    return 'error'
                end

            end
            print('Sending stuff to Mixer for stage ' .. k)
            sendItemRecipeToMixer(processInfo)
        end
    end
    print('Completed')
    return 'completed'
end

return {
    debugTable = debugTable,
    processItem = processItem,
    loopThroughItems = loopThroughItems,
    getItemCountInStorage = getItemCountInStorage,
    fetchTextColors = fetchTextColors
}
