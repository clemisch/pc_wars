local Class = require("src.hump.class")
local Tilesets = require("src.tilesets")
local Loader = require("src.loader")
local unit_db = require("src.units.unit_db")

local unit_int_to_string = Loader.unit_num_to_string
local unit_string_to_int = Loader.unit_string_to_num


local Unit = Class.new()

local function get_lp_indicator(lp, max_lp)
    local relative_lp = (lp / max_lp) * 100
    local rounded_lp = math.floor(relative_lp + 0.5)

    if rounded_lp >= 94 then
        return nil
    end

    return math.max(1, math.ceil(rounded_lp / 10))
end

function Unit:init(name, owner, lp, is_used)
    assert(name)
    assert(owner)

    local stats = unit_db.get(name)

    self.name = name
    self.owner = owner
    self.is_used = is_used or false

    for key, value in pairs(stats) do
        self[key] = value
    end

    if type(self.range) == "number" then
        self.range = {self.range, self.range}
    end

    if self.direct_fire == nil then
        self.direct_fire = true
    end

    self.attack_types = self.attack_types or {}
    self.attack_types_lookup = {}
    for _, attack_type in ipairs(self.attack_types) do
        self.attack_types_lookup[attack_type] = true
    end

    self.max_lp = stats.lp
    self.lp = lp or stats.lp
end

function Unit:draw(y, x)
    -- draw the unit at tile y, x (lua indexing)
    local draw_x = (x - 1) * 16 * SCALING
    local draw_y = (y - 1) * 16 * SCALING - (self.is_select and SCALING*5 or 0)

    love.graphics.setColor(1, 1, 1, self.is_used and 0.6 or 1)
    love.graphics.draw(
        Tilesets.units.spritesheet, 
        Tilesets.units.quads[self.name][self.owner],
        draw_x,
        draw_y,
        0,
        SCALING
    )

    local indicator = get_lp_indicator(self.lp, self.max_lp)
    if indicator then
        local label = tostring(indicator)
        local font = love.graphics.getFont()
        local label_scale = 2.0
        local label_width = font:getWidth(label) * label_scale
        local label_height = font:getHeight() * label_scale
        local label_x = draw_x + (16 * SCALING) - label_width - 1
        local label_y = draw_y + (16 * SCALING) - label_height + 1

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("fill", label_x - 1, label_y - 1, label_width + 2, label_height + 2)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(label, label_x, label_y, 0, label_scale, label_scale)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function Unit:select()
    self.is_select = true
end

function Unit:de_select()
    self.is_select = false
end

function Unit:set_used(is_used)
    self.is_used = is_used
end

function Unit:take_damage(damage)
    self.lp = self.lp - damage
end

function Unit:is_destroyed()
    return self.lp <= 0
end


return {Unit = Unit}
