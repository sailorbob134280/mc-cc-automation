-- Adjust package.path to include libraries
package.path = package.path .. ";./lib/?.lua"
package.path = package.path .. ";../lib/?.lua"

local logger = require('logger')
logger.setLevel(logger.levels.TRACE)
logger.banner('Lawnmower')
logger.info('Initializing the lawnmower application...')

local lawnmower = require('apps.lawnmower.mower')

-- Configure constants
-- TODO: Move these to a config file
local opts = {
  position = {x = 0, y = 0, z = 0},
  mowing_area = {
    start = {x = 0, y = 0},
    finish = {x = 0, y = 0}
  },
  direction = lawnmower.direction.EAST,
  refuel_side = lawnmower.refuel_side.BACK,
  obstacle_height_threshold = 2
}

local mower = lawnmower.create(opts, logger)

-- Start the lawnmower
mower:begin()
mower:run()
