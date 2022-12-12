local map = require("map")
local cursor = require("cursor")

-- global gamestate handler
Gamestate = require("hump.gamestate")

-- global gamestate entities
game = require("game")
pause = require("pause")

-- global start time used for animation
TIME_START = love.timer.getTime()

function love.load()
    DEBUG = true

    local map = map.Map("testLevel")
    local cursor = cursor.Cursor(map)

    Gamestate.registerEvents()
    Gamestate.switch(game.Game, map, cursor)
end


