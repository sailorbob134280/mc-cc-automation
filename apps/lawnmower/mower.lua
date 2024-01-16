local Mower = {}
Mower.__index = Mower

local function vector_eq(a, b)
  return a.x == b.x and a.y == b.y and a.z == b.z
end

-------------
-- "Enums" --
-------------
Mower.turn_direction = {
  LEFT = -1,
  RIGHT = 1,
  pretty = function(direction)
    if direction == Mower.turn_direction.LEFT then
      return 'LEFT'
    elseif direction == Mower.turn_direction.RIGHT then
      return 'RIGHT'
    else
      return 'INVALID'
    end
  end,
  opposite = function(direction)
    if direction == Mower.turn_direction.LEFT then
      return Mower.turn_direction.RIGHT
    elseif direction == Mower.turn_direction.RIGHT then
      return Mower.turn_direction.LEFT
    else
      return nil
    end
  end,
}

Mower.refuel_side = {
  LEFT = 0,
  RIGHT = 1,
  BACK = 2,
  pretty = function(side)
    if side == Mower.refuel_side.LEFT then
      return 'LEFT'
    elseif side == Mower.refuel_side.RIGHT then
      return 'RIGHT'
    elseif side == Mower.refuel_side.BACK then
      return 'BACK'
    else
      return 'INVALID'
    end
  end,
}

Mower.direction = {
  NORTH = vector.new(0, -1, 0),
  EAST = vector.new(1, 0, 0),
  SOUTH = vector.new(0, 1, 0),
  WEST = vector.new(-1, 0, 0),
  pretty = function(direction)
    if vector_eq(direction, Mower.direction.NORTH) then
      return 'NORTH'
    elseif vector_eq(direction, Mower.direction.EAST) then
      return 'EAST'
    elseif vector_eq(direction, Mower.direction.SOUTH) then
      return 'SOUTH'
    elseif vector_eq(direction, Mower.direction.WEST) then
      return 'WEST'
    else
      return 'INVALID'
    end
  end,
  turn_right = function(direction)
    if vector_eq(direction, Mower.direction.NORTH) then
      return Mower.direction.EAST
    elseif vector_eq(direction, Mower.direction.EAST) then
      return Mower.direction.SOUTH
    elseif vector_eq(direction, Mower.direction.SOUTH) then
      return Mower.direction.WEST
    elseif vector_eq(direction, Mower.direction.WEST) then
      return Mower.direction.NORTH
    else
      return nil
    end
  end,
  turn_left = function(direction)
    if vector_eq(direction, Mower.direction.NORTH) then
      return Mower.direction.WEST
    elseif vector_eq(direction, Mower.direction.EAST) then
      return Mower.direction.NORTH
    elseif vector_eq(direction, Mower.direction.SOUTH) then
      return Mower.direction.EAST
    elseif vector_eq(direction, Mower.direction.WEST) then
      return Mower.direction.SOUTH
    else
      return nil
    end
  end,
}

-------------
-- Helpers --
-------------

-- These are simple wrappers around the turtle API that also handle dead reckoning
function Mower:turn_right()
  local success, msg = turtle.turnRight()
  if success then
    self.current_direction = Mower.direction.turn_right(self.current_direction)
    self.logger.trace('Turned right')
    return true
  else
    -- Turning is a much more serious error than moving, so we'll go into safe mode
    self.logger.error('Unable to turn right: ' .. msg)
    self.fsm:error()
    return false
  end
end

function Mower:turn_left()
  local success, msg = turtle.turnLeft()
  if success then
    self.current_direction = Mower.direction.turn_left(self.current_direction)
    self.logger.trace('Turned left')
    return true
  else
    -- Turning is a much more serious error than moving, so we'll go into safe mode
    self.logger.error('Unable to turn left: ' .. msg)
    self.fsm:error()
    return false
  end
end

function Mower:turn(direction)
  if direction == Mower.turn_direction.LEFT then
    return self:turn_left()
  else
    return self:turn_right()
  end
end

function Mower:turn_around()
  self:turn_right()
  self:turn_right()
end

function Mower:move_forward()
  local success, msg = turtle.forward()
  if success then
    self.current_position = self.current_position:add(self.current_direction)
    self.logger.trace('Moved forward')
    return true
  else
    self.logger.debug('Unable to move forward: ' .. msg)
    return false
  end
end

function Mower:move_backward()
  local success, msg = turtle.back()
  if success then
    self.current_position = self.current_position:subtract(self.current_direction)
    self.logger.trace('Moved backward')
    return true
  else
    self.logger.debug('Unable to move backward: ' .. msg)
    return false
  end
end

function Mower:move_up()
  local success, msg = turtle.up()
  if success then
    self.current_position.z = self.current_position.z + 1
    self.logger.trace('Moved up')
    return true
  else
    self.logger.debug('Unable to move up: ' .. msg)
    return false
  end
end

function Mower:move_down()
  local success, msg = turtle.down()
  if success then
    self.current_position.z = self.current_position.z - 1
    self.logger.trace('Moved down')
    return true
  else
    self.logger.debug('Unable to move down: ' .. msg)
    return false
  end
end

function Mower:at_position(targetPosition)
    return vector_eq(self.current_position, targetPosition)
end

function Mower:face_direction(targetDirection)
    while not vector_eq(self.current_direction, targetDirection) do
        self:turn_right()
    end
end

function Mower:calculate_direction_to(target_position)
    if self.current_position.x < target_position.x then
        return Mower.direction.EAST
    elseif self.current_position.x > target_position.x then
        return Mower.direction.WEST
    -- Yes, this is wrong. Yes, minecraft is also wrong. Yes, it infuriates me too.
    elseif self.current_position.y > target_position.y then
        return Mower.direction.NORTH
    else
        return Mower.direction.SOUTH
    end
end

function Mower:is_mowable(name)
  for _, mowable in pairs(self.mowables) do
    if mowable == name then
      return true
    end
  end
  return false
end

function Mower:is_done_mowing()
    -- Check if the mower has reached or passed the finish position
    if vector_eq(self.base_direction, Mower.direction.NORTH) then
        return self.current_position.x >= self.finish_position.x
    elseif vector_eq(self.base_direction, Mower.direction.SOUTH) then
        return self.current_position.x <= self.finish_position.x
    elseif vector_eq(self.base_direction, Mower.direction.EAST) then
        return self.current_position.y >= self.finish_position.y
    elseif vector_eq(self.base_direction, Mower.direction.WEST) then
        return self.current_position.y <= self.finish_position.y
    end
end

function Mower:is_row_complete()
    -- Check if the mower has reached or passed the finish position
    if vector_eq(self.current_direction, Mower.direction.NORTH) then
        return self.current_position.y <= math.min(self.start_position.y, self.finish_position.y)
    elseif vector_eq(self.current_direction, Mower.direction.SOUTH) then
        return self.current_position.y >= math.max(self.start_position.y, self.finish_position.y)
    elseif vector_eq(self.current_direction, Mower.direction.EAST) then
        return self.current_position.x >= math.max(self.start_position.x, self.finish_position.x)
    elseif vector_eq(self.current_direction, Mower.direction.WEST) then
        return self.current_position.x <= math.min(self.start_position.x, self.finish_position.x)
    end
end

-------------------
-- State Actions --
-------------------
function Mower:idle()
  self.logger.trace('Idle action')
  return false -- We're done, exit the loop
end

function Mower:start()
  self.logger.trace('Starting action')

  if self:at_position(self.start_position) then
    self:face_direction(self.base_direction)
    self.fsm:at_start()
    return true
  end

  local target_direction = self:calculate_direction_to(self.start_position)
  self:face_direction(target_direction)
  self:move_forward()

  return true
end

function Mower:mow()
  self.logger.trace('Mowing action')

  if not self:move_forward() then
    self.logger.debug('Unable to move forward, is it mowable?')
    local success, data = turtle.inspect()
    if not success then
      self.logger.error('Unable to inspect block in front of us for some reason')
      self.fsm:error()
      return true
    elseif self:is_mowable(data.name) then
      self.logger.debug('Block in front of us is mowable, trying to mow')
      turtle.dig()
    else
      self.logger.debug('Block in front of us is not mowable, so it must be an obstacle')
      self.fsm:obstacle()
      return true
    end
  end

  if self:is_done_mowing() then
    self.logger.debug('Mowing complete, returning to base')
    self.fsm:mowing_complete()
  end

  if self:is_row_complete() then
    self.logger.debug('Row complete, turning around')
    self.fsm:row_complete()
  end

  if not turtle.detectDown() then
    self.logger.debug('We\'re flying, Jack! Trying to land')
    while self:move_down() do
    end
  end

  return true
end

function Mower:dodge()
    self.logger.trace('Dodging action')
    if self:move_forward() then 
        self.logger.debug('Dodged the obstacle')
        self.fsm:obstacle_cleared()
        return true
    else
      self.logger.debug('Still blocked. Climbing...')
      if not self:move_up() then
        self.logger.debug('Under an overhang! Trying to turn around...')
        self:turn_around()
        if not self:move_forward() then
            self.logger.error('Someone is fucking with me. I\'m going to safe mode >:(')
            self.fsm:error()
            return true
        end
        self:turn_around()
        return true
      end
      return true
    end
end

function Mower:turnaround()
  self.logger.trace('Turnaround action')

  local turn
  if self.next_turn == Mower.turn_direction.LEFT then
    turn = function() self:turn_left() end
    self.next_turn = Mower.turn_direction.RIGHT
  else
    turn = function() self:turn_right() end
    self.next_turn = Mower.turn_direction.LEFT
  end

  turn()

  if not self:move_forward() then
    self.logger.error('Unable to move forward during turnaround')
    self.fsm:error()
    return true
  end

  turn()

  self.fsm:turned_around()
  return true
end

function Mower:return_to_base()
  self.logger.trace('Return action')

  if self:at_position(self.base_position) then
    self:face_direction(self.base_direction)
    self.fsm:at_base()
    return true
  end

  local targetDirection = self:calculate_direction_to(self.base_position)
  self:face_direction(targetDirection)
  self:move_forward()

  return true
end

function Mower:safe_mode()
  self.logger.error('Mower is now in a safe mode and awaiting rescue')
  while true do
    self.logger.warn('Stuck in safe mode, awaiting reset')
    self.logger.warn('Current Position: ' .. self.current_position.x .. ', ' .. self.current_position.y .. ', ' .. self.current_position.z)
    os.sleep(10)
  end
end

function Mower:create_sm()
  local machine = require('statemachine')

  local logger = self.logger

  logger.debug('Configuring lawnmower state machine')

  local fsm = machine.create({
    initial = 'idle',
    events = {
      {name = 'start', from = 'idle', to = 'starting'},
      {name = 'at_start', from = 'starting', to = 'mowing'},
      {name = 'obstacle', from = 'mowing', to = 'dodging'},
      {name = 'obstacle_cleared', from = 'dodging', to = 'mowing'},
      {name = 'row_complete', from = 'mowing', to = 'turnaround'},
      {name = 'turned_around', from = 'turnaround', to = 'mowing'},
      {name = 'mowing_complete', from = 'mowing', to = 'returning'},
      {name = 'at_base', from = 'returning', to = 'idle'},
      {name = 'error', from = '*', to = 'safe_mode'},
    },
    callbacks = {
      -- sm, event, from, to
      onstart = function(_, _, _, _) logger.info('Starting lawnmower') end,
      onat_start = function(_, _, _ , _) logger.info('Arrived at start location') end,
      onobstacle = function(_, _, _ , _) logger.info('Obstacle detected') end,
      onobstacle_cleared = function(_, _, _ , _) logger.info('Obstacle cleared') end,
      onrow_complete = function(_, _, _ , _) logger.info('Row complete') end,
      onturned_around = function(_, _, _ , _) logger.info('Turned around') end,
      onmowing_complete = function(_, _, _ , _) logger.info('Mowing complete') end,
      onat_base = function(_, _, _ , _) logger.info('Arrived at base') end,
      onerror = function(_, _, _ , _) logger.warn('Error detected') end,

      onidle = function(_, _, _ , _)
        logger.debug('Now in idle state')
        self.action = function() return self:idle() end
      end,
      onstarting = function(_, _, _ , _)
        logger.debug('Now in starting state')
        self.action = function() return self:start() end
      end,
      onmowing = function(_, _, _ , _)
        logger.debug('Now in mowing state')
        self.action = function() return self:mow() end
      end,
      ondodging = function(_, _, _ , _)
        logger.debug('Now in dodging state')
        self.action = function() return self:dodge() end
      end,
      onturnaround = function(_, _, _ , _)
        logger.debug('Now in turnaround state')
        self.action = function() return self:turnaround() end
      end,
      onreturning = function(_, _, _ , _)
        logger.debug('Now in returning state')
        self.action = function() return self:return_to_base() end
      end,
      onsafe_mode = function(_, _, _ , _)
        logger.debug('Now in safe mode state')
        self.action = function() return self:safe_mode() end
      end,
    }
  })

  return fsm
end

function Mower.create(base_opts, logger)
  assert(base_opts.position)
  assert(base_opts.direction)
  assert(base_opts.refuel_side)

  local mower = setmetatable({}, Mower)
  mower.logger = logger
  mower.logger.info('Initializing lawnmower')

  -- Relative to the base station
  mower.logger.debug('Setting configuration parameters')
  mower.base_position = vector.new(base_opts.position.x, base_opts.position.y, base_opts.position.z)
  mower.base_direction = base_opts.direction
  mower.start_position = vector.new(base_opts.mowing_area.start.x, base_opts.mowing_area.start.y, base_opts.position.z)
  mower.finish_position = vector.new(base_opts.mowing_area.finish.x, base_opts.mowing_area.finish.y, base_opts.position.z)
  mower.refuel_side = base_opts.refuel_side
  mower.mowables = base_opts.mowables
  mower.logger.info(string.format([[
Configured parameters:

    Base position: %s
    Base direction: %s
    Refuel side: %s
  ]], mower.base_position:tostring(), Mower.direction.pretty(mower.base_direction),
      Mower.refuel_side.pretty(mower.refuel_side)))

  -- Starting state
  mower.next_turn = Mower.turn_direction.RIGHT
  mower.current_position = vector.new(base_opts.position.x, base_opts.position.y, base_opts.position.z)
  mower.current_direction = base_opts.direction

  mower.fsm = mower:create_sm()
  -- This isn't called by state machine init for some reason
  mower.fsm:onidle()

  return mower
end

function Mower:begin()
  self.logger.info('Starting to mow')
  self.fsm:start()
end

function Mower:run()
  while self.action() do
  end
end

return Mower
