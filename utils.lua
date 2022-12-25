--- @module
local utils = {}

local log = require("log")
log.level = LOGLEVEL

function utils.timeit (fun, args, name, fmt, multiplier)
    local name = name or "Function"
    local fmt = fmt or "%f"
    local multiplier = multiplier or 1.0

    local t0 = love.timer.getTime()
    local ret = fun(table.unpack(args))
    local t1 = love.timer.getTime()
    local dt = t1 - t0
    log.debug(("%s took " .. fmt):format(name, dt * multiplier))
    return ret
end



return utils

