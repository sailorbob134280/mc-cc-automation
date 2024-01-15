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
  position = {x = 429, y = 56, z = 68},
  mowing_area = {
    start = {x = 438, y = 47},
    finish = {x = 448, y = 64}
  },
  direction = lawnmower.direction.EAST,
  refuel_side = lawnmower.refuel_side.RIGHT,
  obstacle_height_threshold = 2,
  mowables = {
    "botania:flower",
    "botania:double_flower",
    "minecraft:grass",
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
mower:run()
