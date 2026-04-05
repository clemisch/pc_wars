local log = require("src.log")
log.level = LOGLEVEL

local unit_db = require("src.units.unit_db")

local BuyMenu = {}

local BUILD_OPTIONS = {
    factory = {
        "soldier_normal",
        "soldier_mech",
        "slime",
        "tank_tp",
        "tank_light",
        "tank_medium",
        "tank_heavy",
        "tank_ultra",
        "tank_laser",
        "artillery",
        "artillery_rocket",
        "flak",
        "flak_rocket",
        "rocket",
    },
    airport = {
        "heli_tp",
        "heli_attack",
        "plane_fighter",
        "plane_bomber",
        "plane_stealth",
        "bomb",
    },
    seaport = {
        "ship_robot",
        "ship_tp",
        "ship_destroyer",
        "ship_submarine",
        "ship_battle",
        "ship_carrier",
    },
}

local function format_unit_name(name)
    return (name:gsub("_", " "):gsub("(%a)([%w']*)", function(first, rest)
        return first:upper() .. rest
    end))
end

local function clamp(value, min_value, max_value)
    return math.max(min_value, math.min(max_value, value))
end

local function get_visible_window(cursor, total_options, max_rows)
    local first_row = clamp(cursor - math.floor(max_rows / 2), 1, math.max(total_options - max_rows + 1, 1))
    local last_row = math.min(first_row + max_rows - 1, total_options)
    return first_row, last_row
end

function BuyMenu:enter(from, y, x)
    log.debug("Entering gamestate <BuyMenu>")

    self.name = "BuyMenu"
    self.from = from
    self.game = from
    self.map = from.map
    self.y = y
    self.x = x
    self.cursor = 1

    local tile = self.map:get_tile(y, x)
    self.tile = tile
    self.options = BUILD_OPTIONS[tile.name] or {}
end

function BuyMenu:update(dt)
    self.from:update(dt)
end

function BuyMenu:draw()
    self.from:draw()

    local box_width = WIDTH_PIXELS / 3
    local box_height = HEIGHT_PIXELS / 3
    local box_x = (WIDTH_PIXELS - box_width) / 2
    local box_y = (HEIGHT_PIXELS - box_height) / 2
    local row_height = 22
    local row_y = box_y + 22
    local max_rows = math.max(math.floor((box_height - 34) / row_height), 1)
    local first_row, last_row = get_visible_window(self.cursor, #self.options, max_rows)

    love.graphics.setColor(1, 1, 1, 0.88)
    love.graphics.rectangle("fill", box_x, box_y, box_width, box_height)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", box_x, box_y, box_width, box_height)
    love.graphics.print("Build Unit", box_x + 12, box_y + 8)

    for i = first_row, last_row do
        local unit_name = self.options[i]
        local cost = unit_db[unit_name].cost or 0
        local can_afford = self.game.player_money[self.game.active_player] >= cost
        local is_selected = i == self.cursor
        local text_color = can_afford and {0, 0, 0} or {0.45, 0.45, 0.45}
        local cost_text = tostring(cost)
        local cost_width = love.graphics.getFont():getWidth(cost_text)
        local this_row_y = row_y + (i - first_row) * row_height

        if is_selected then
            love.graphics.setColor(0, 0, 0, 0.12)
            love.graphics.rectangle("fill", box_x + 8, this_row_y - 1, box_width - 16, row_height)
        end

        love.graphics.setColor(text_color[1], text_color[2], text_color[3], 1)
        love.graphics.print(is_selected and ">" or " ", box_x + 12, this_row_y)
        love.graphics.print(format_unit_name(unit_name), box_x + 28, this_row_y)
        love.graphics.print(cost_text, box_x + box_width - 12 - cost_width, this_row_y)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function BuyMenu:keypressed(key)
    if key == "w" then
        self.cursor = clamp(self.cursor - 1, 1, #self.options)
        return
    end

    if key == "s" then
        self.cursor = clamp(self.cursor + 1, 1, #self.options)
        return
    end

    if key == "l" then
        Gamestate.pop()
        return
    end

    if key ~= "k" then
        return
    end

    local unit_name = self.options[self.cursor]
    if not unit_name then
        return
    end

    local ok = self.game:build_unit(self.y, self.x, unit_name)
    if ok then
        Gamestate.pop()
    end
end

function BuyMenu:resume(pre)
    log.debug("Resuming gamestate <BuyMenu>")
end

return {
    BuyMenu = BuyMenu
}
