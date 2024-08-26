local config = require("config")
local functions = require("functions")
local peripherals = require("peripherals")

local methods = peripheral.getMethods(config.storageControllerName)
functions.debugTable(methods)
local items = peripherals.storageDrawers.list()

functions.loopThroughItems(items)