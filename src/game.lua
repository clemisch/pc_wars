local log = require("src.log")
log.level = LOGLEVEL

local unit_db = require("src.units.unit_db")


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

local function text_left(y, text, is_bot)
	local font = love.graphics.getFont()
	local text_height = font:getHeight()
    local y_offset = 0
    if is_bot then
        y_offset = y_offset - text_height
    end

	love.graphics.print({{0, 0, 0}, text}, 0, y, 0, 1, 1, 0, -y_offset)
end



-- `Game` is a HUMP Gamestate
local Game = {}

function Game:init() 
    log.debug("Initializing gamestate <Game>")
end

function Game:enter(from, map, cursor)
    assert(map)
    assert(cursor)

    self.name = "Game"
    self.map = map
    self.map:set_game_state(self)
    self.cursor = cursor
    self.active_player = 1
    self.num_players = 3
    
    self.player_money = {}
    for i = 1,self.num_players do
        self.player_money[i] = 0
    end
    self.player_money[self.active_player] = self.player_money[self.active_player] + 1000 * self.map:get_num_buildings(self.active_player)

    log.debug("Entering gamestate <Game>")
    if DEBUG then
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

    local cursor_tile = self.map:get_tile(self.cursor.y, self.cursor.x)
    local unit_obj = cursor_tile and cursor_tile.unit
    if unit_obj then
        local font_height = love.graphics.getFont():getHeight()
        local lines = {}

        if #unit_obj.cargo > 0 then
            for _, cargo_unit in ipairs(unit_obj.cargo) do
                table.insert(lines, ("cargo: %s %i/%i"):format(cargo_unit.name, cargo_unit.lp, cargo_unit.max_lp))
            end
        end

        table.insert(lines, ("%s %i/%i"):format(unit_obj.name, unit_obj.lp, unit_obj.max_lp))


        for i, line in ipairs(lines) do
            text_left(HEIGHT_PIXELS - (#lines - i) * font_height, line, true)
        end
    end

    if DEBUG then
        local s = ("%.1f"):format(self.FPS)
        love.graphics.print({{0, 0, 0}, s})
    end

end


function Game:keypressed(key)
    if 
        key == "p"      then Gamestate.push(pause.Pause) elseif
        key == "escape" then love.event.quit()           elseif 
        key == "return" then self:next_player()          elseif 
        key == "r"      then love.event.quit("restart")
    end

    local action = self.cursor:update(key)
    if action and action.action == "open_buymenu" then
        Gamestate.push(buymenu.BuyMenu, action.y, action.x)
    elseif action and action.action == "open_actionmenu" then
        Gamestate.push(actionmenu.ActionMenu, action.y, action.x)
    end
end


function Game:resume(pre)
    log.debug("Resuming gamestate <Game>")
end


function Game:next_player()
    self.active_player = (self.active_player % self.num_players) + 1
    self.player_money[self.active_player] = self.player_money[self.active_player] + 1000 * self.map:get_num_buildings(self.active_player)
    self.map:set_units_used(self.active_player, false)
    log.debug("Active player:", self.active_player)
end

function Game:build_unit(y, x, unit_name)
    local data = unit_db[unit_name]
    if not data then
        return false
    end

    local tile = self.map:get_tile(y, x)
    if not tile then
        return false
    end

    if not data.can_build or data.producer ~= tile.name then
        return false
    end

    local cost = data.cost or 0
    local funds = self.player_money[self.active_player]
    if funds < cost then
        return false
    end

    local ok = self.map:build_unit(y, x, unit_name, self.active_player)
    if not ok then
        return false
    end

    self.player_money[self.active_player] = funds - cost
    return true
end

function Game:wait_action(y, x)
    return self.map:wait_unit(y, x)
end

function Game:attack_action(y, x)
    return self.map:attack_unit(y, x)
end

function Game:load_action(y, x)
    return self.map:load_unit(y, x)
end

function Game:unload_action(y, x)
    return self.map:unload_unit(y, x)
end

function Game:get_actions_at(y, x)
    return self.map:get_actions_at(y, x)
end

function Game:cancel_action_preview()
    return self.map:cancel_action_preview()
end

function Game:begin_attack_targeting(y, x)
    return self.map:begin_attack_targeting(y, x)
end

function Game:cancel_attack_targeting()
    return self.map:cancel_attack_targeting()
end

function Game:begin_unload_targeting(y, x, cargo_index)
    return self.map:begin_unload_targeting(y, x, cargo_index)
end

function Game:cancel_unload_targeting()
    return self.map:cancel_unload_targeting()
end




return {
    Game = Game,
}
