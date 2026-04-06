local log = require("src.log")
log.level = LOGLEVEL

local ActionMenu = {}

local function clamp(value, min_value, max_value)
    return math.max(min_value, math.min(max_value, value))
end

local function format_action_name(name)
    return (name:gsub("_", " "):gsub("^%l", string.upper))
end

local function get_option_label(option)
    if type(option) == "table" then
        return option.label
    end

    return format_action_name(option)
end

function ActionMenu:refresh_options()
    self.options = self.game:get_actions_at(self.y, self.x)
    self.cursor = clamp(self.cursor, 1, math.max(#self.options, 1))
end

function ActionMenu:enter(from, y, x)
    log.debug("Entering gamestate <ActionMenu>")

    self.name = "ActionMenu"
    self.from = from
    self.game = from
    self.y = y
    self.x = x
    self.cursor = 1
    self:refresh_options()
end

function ActionMenu:update(dt)
    self.from:update(dt)
end

function ActionMenu:draw()
    self.from:draw()

    local box_width = WIDTH_PIXELS / 4
    local box_height = HEIGHT_PIXELS / 5
    local box_x = (WIDTH_PIXELS - box_width) / 2
    local box_y = (HEIGHT_PIXELS - box_height) / 2
    local row_height = 22
    local row_y = box_y + 22

    love.graphics.setColor(1, 1, 1, 0.88)
    love.graphics.rectangle("fill", box_x, box_y, box_width, box_height)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("line", box_x, box_y, box_width, box_height)
    love.graphics.print("Action", box_x + 12, box_y + 8)

    for i, option_name in ipairs(self.options) do
        local is_selected = i == self.cursor
        local this_row_y = row_y + (i - 1) * row_height

        if is_selected then
            love.graphics.setColor(0, 0, 0, 0.12)
            love.graphics.rectangle("fill", box_x + 8, this_row_y - 1, box_width - 16, row_height)
        end

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(is_selected and ">" or " ", box_x + 12, this_row_y)
        love.graphics.print(get_option_label(option_name), box_x + 28, this_row_y)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function ActionMenu:keypressed(key)
    if key == "w" then
        self.cursor = clamp(self.cursor - 1, 1, #self.options)
        return
    end

    if key == "s" then
        self.cursor = clamp(self.cursor + 1, 1, #self.options)
        return
    end

    if key == "l" then
        if self.game:cancel_action_preview() then
            Gamestate.pop()
        end
        return
    end

    if key ~= "k" then
        return
    end

    local option = self.options[self.cursor]
    local option_id = type(option) == "table" and option.id or option
    if option_id == "wait" and self.game:wait_action(self.y, self.x) then
        Gamestate.pop()
    elseif option_id == "load" and self.game:load_action(self.y, self.x) then
        Gamestate.pop()
    elseif option_id == "attack" then
        Gamestate.push(attacktarget.AttackTarget, self.y, self.x)
    elseif option_id == "unload" then
        Gamestate.push(unloadtarget.UnloadTarget, self.y, self.x, option.cargo_index)
    end
end

function ActionMenu:resume(pre)
    log.debug("Resuming gamestate <ActionMenu>")
    self:refresh_options()
end

return {
    ActionMenu = ActionMenu
}
