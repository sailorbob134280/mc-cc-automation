--
-- A simple (like, REALLY simple) logger for Lua.
--

-- Logger module
local Logger = {}

-- Log levels
Logger.levels = {
    TRACE = 0,
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    NONE = 5  -- for turning off logging
}

-- Log colors
Logger.colors = {
    RED = "\27[31m",
    YELLOW = "\27[33m",
    GREEN = "\27[32m",
    BLUE = "\27[34m",
    RESET = "\27[0m"
}

-- Default log level
Logger.currentLevel = Logger.levels.INFO

-- Function to format the current log level
function Logger.prettyLevel(level)
    if level == Logger.levels.TRACE then
        return "TRACE"
    elseif level == Logger.levels.DEBUG then
        return "DEBUG"
    elseif level == Logger.levels.INFO then
        return "INFO"
    elseif level == Logger.levels.WARN then
        return "WARN"
    elseif level == Logger.levels.ERROR then
        return "ERROR"
    elseif level == Logger.levels.NONE then
        return "NONE"
    else
        return "UNKNOWN"
    end
end

-- Function to set the log level
function Logger.setLevel(level)
    Logger.currentLevel = level
    Logger.info('Log level: ' .. Logger.prettyLevel(Logger.currentLevel))
end

-- Print a fancy banner
function Logger.banner(message)
print(Logger.colors.GREEN .. '-----------------------------------------' .. Logger.colors.RESET)
print(Logger.colors.GREEN .. message .. Logger.colors.RESET)
print(Logger.colors.GREEN .. '-----------------------------------------' .. Logger.colors.RESET)
end

-- Log functions for each level
function Logger.trace(message)
  if Logger.currentLevel <= Logger.levels.TRACE then
    print("[TRACE] " .. message)
  end
end

function Logger.debug(message)
    if Logger.currentLevel <= Logger.levels.DEBUG then
        print("[DEBUG] " .. message)
    end
end

function Logger.info(message)
    if Logger.currentLevel <= Logger.levels.INFO then
        print(Logger.colors.BLUE .. "[INFO]  " .. Logger.colors.RESET .. message)
    end
end

function Logger.warn(message)
    if Logger.currentLevel <= Logger.levels.WARN then
        print(Logger.colors.YELLOW .. "[WARN]  " .. Logger.colors.RESET .. message)
    end
end

function Logger.error(message)
    if Logger.currentLevel <= Logger.levels.ERROR then
        print(Logger.colors.RED .. "[ERROR] " .. Logger.colors.RESET .. message)
    end
end

return Logger
