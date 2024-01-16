-- Adjust package.path to include libraries
package.path = package.path .. ";./lib/?.lua"
package.path = package.path .. ";../lib/?.lua"
package.path = package.path .. ";../../lib/?.lua"
package.path = package.path .. ";./?.lua"

local logger = require('logger')
logger.setLevel(logger.levels.DEBUG)
logger.banner('Lawnmower')
logger.info('Initializing the lawnmower application...')

local lawnmower = require('mower')

-- Configure constants
-- TODO: Move these to a config file
local opts = {
  position = {x = 430, y = 57, z = 68},
  mowing_area = {
    start = {x = 433, y = 34},
    finish = {x = 489, y = 83}
  },
  direction = lawnmower.direction.EAST,
  refuel_side = lawnmower.refuel_side.BACK,
  mowables = {
    "botania:flower",
    "botania:double_flower",
    "minecraft:tallgrass",
    "minecraft:yellow_flower",
    "minecraft:red_flower",
    "minecraft:double_plant",
    "minecraft:leaves",
    "minecraft:leaves2",
    "minecraft:web",
  }
}

local mower = lawnmower.create(opts, logger)

-- Start the lawnmower
mower:begin()

while true do
  mower:run()
  os.setAlarm(24)
  os.pullEvent("alarm")
end
