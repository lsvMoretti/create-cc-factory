-- Small Monitor above Computer
local monitorName = "top"

-- Depots @ Presses
local leftDepotName = "create:depot_0"
local midDepotName = "create:depot_1"

-- Basins @ Mixers
local leftBasinName = "create:basin_0"
local midBasinName = "create:basin_1"

-- Empty filter name
local emptyFilterName = "minecraft:air"

local storageControllerName = "storagedrawers:controller_0"

-- Define recipes
local recipes = {
    -- Andesite Alloy Recipe
    andesite = {
        name = 'Andesite Alloy', -- Recipe name
        itemName = 'create:andesite_alloy', -- Output item
        monX = 1, -- Monitor Text Position
        lineNum = 1, -- Monitor Line Number (Y)
        clickMax = 14, -- Monitor Max Touch Pos of X Pos
        colors = {
            readyFont = '0', -- Font Color when ready to be sent
            readyBck = '5', -- Background Color when ready to be sent
            busyFont = '0', -- Busy Font Color
            busyBck = 'e', -- Busy background color
            errorFont = '0', -- Error Font Color
            errorBck = 'a' -- Error background color
        },
        processes = { -- Input items
        {
            type = 'mix',
            {
                itemName = 'minecraft:andesite', -- First input item
                amount = 1 -- Amount of first input
            },
            {
                itemName = 'minecraft:iron_nugget', -- Second input item
                amount = 1 -- Amount of second input
            },
            output = 'create:andesite_alloy' -- The outputted item after this stage
        }},
        outputAmount = 1, -- Amount of output item
    }
}

local mixers = {
    leftBasin = {
        name = "create:basin_0",
    },
    midBasin = {
        name = "create:basin_1"
    }
}

-- Return all variables in a table
return {
    leftDepotName = leftDepotName,
    midDepotName = midDepotName,
    leftBasinName = leftBasinName,
    midBasinName = midBasinName,
    monitorName = monitorName,
    emptyFilterName = emptyFilterName,
    storageControllerName = storageControllerName,
    recipes = recipes,
    mixers = mixers
}
