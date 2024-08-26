local config = require("config")
local topMonitor = peripheral.wrap(config.monitorName)
local storageDrawers = peripheral.wrap(config.storageControllerName)
return {
    topMonitor = topMonitor,
    storageDrawers = storageDrawers
}
