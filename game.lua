local pprint = require("pprint")

-- `Game` is a HUMP Gamestate
local Game = {}

function Game:init() 
    if DEBUG then
        print("Initializing gamestate <Game>")
    end
end

function Game:enter(from, map, cursor)
    assert(map)
    assert(cursor)

    self.name = "Game"
    self.map = map
    self.cursor = cursor
    self.active_player = 1
    self.num_players = 3

    if DEBUG then
        print("Entering gamestate <Game>")
        self.ACC = 0
        self.ACC_LIM = 0.5
        self.FPS = 1
    end
end


function Game:update(dt)
    if DEBUG then
        self.ACC = self.ACC + dt
        if self.ACC > self.ACC_LIM then
            self.FPS = love.timer.getFPS()
            self.ACC = 0
        end
    end
end


function Game:draw()
    self.map:draw()
    self.cursor:draw() 

    if DEBUG then
        local s = string.format("%.1f", self.FPS)
        love.graphics.print({{0, 0, 0}, s})
    end

end


function Game:keypressed(key)
    if 
        key == "p"      then Gamestate.push(pause.Pause) elseif
        key == "escape" then love.event.quit()           elseif 
        key == "return" then self:next_player()
    end

    self.cursor:update(key)
end


function Game:resume(pre)
    if DEBUG then
        print("Resuming gamestate <Game>")
    end
end


function Game:next_player()
    -- TODO: make owner 1-indexed (map is 0 atm)
    self.active_player = (self.active_player % self.num_players) + 1
    print(self.active_player)
end


return {
    Game = Game,
}