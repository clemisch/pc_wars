local map = require("src.map")
local cursor = require("src.cursor")

-- global gamestate handler
Gamestate = require("src.hump.gamestate")

-- global gamestate entities
game = require("src.game")
pause = require("src.pause")
buymenu = require("src.buymenu")

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
