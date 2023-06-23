local map = require("map")
local cursor = require("cursor")

-- global gamestate handler
Gamestate = require("hump.gamestate")

-- global gamestate entities
game = require("game")
pause = require("pause")
buymenu = require("buymenu")

-- global start time used for animation
TIME_START = love.timer.getTime()

function love.load()
    local x, y = love.graphics.inverseTransformPoint(0.5, 0.5)
    print(x, y)
    local map = map.Map("level_test")
    local cursor = cursor.Cursor(map)
    Gamestate.registerEvents()
    Gamestate.switch(game.Game, map, cursor)
end
