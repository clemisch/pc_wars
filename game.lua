local pprint = require("pprint")


local function text_center(rectX, rectY, rectWidth, rectHeight, text)
	local font       = love.graphics.getFont()
	local textWidth  = font:getWidth(text)
	local textHeight = font:getHeight()
	love.graphics.print({{0, 0, 0}, text}, rectX+rectWidth/2, rectY+rectHeight/2, 0, 1, 1, textWidth/2, textHeight/2)
end

local function text_right(y, text, is_bot)
    
	local font       = love.graphics.getFont()
	local text_width  = font:getWidth(text)
	local text_height = font:getHeight()
    local y_offset = 0
    if is_bot then 
        y_offset = y_offset - text_height
    end

	love.graphics.print({{0, 0, 0}, text}, WIDTH_PIXELS, y, 0, 1, 1, text_width, -y_offset)
end



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
    
    self.player_money = {}
    for i = 1,self.num_players do
        self.player_money[i] = 3000
    end

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

    text_right(HEIGHT_PIXELS, ("Active player: %i"):format(self.active_player), true)
    text_right(0, ("Funds: %i"):format(self.player_money[self.active_player]))

    if DEBUG then
        local s = ("%.1f"):format(self.FPS)
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
    self.active_player = (self.active_player % self.num_players) + 1
    print("Active player:", self.active_player)
end


return {
    Game = Game,
}