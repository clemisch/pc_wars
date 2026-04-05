local Class = require("src.hump.class")
local Tilesets = require("src.tilesets")
local Loader = require("src.loader")
local unit_db = require("src.units.unit_db")

local unit_int_to_string = Loader.unit_num_to_string
local unit_string_to_int = Loader.unit_string_to_num


local Unit = Class.new()
function Unit:init(name, owner, health, is_used)
    assert(name)
    assert(owner)

    self.name = name
    self.owner = owner
    self.health = health or 100
    self.movement = assert(unit_db[name], name).movement
    self.is_used = is_used or false
end

function Unit:draw(y, x)
    -- draw the unit at tile y, x (lua indexing)
    love.graphics.setColor(1, 1, 1, self.is_used and 0.6 or 1)
    love.graphics.draw(
        Tilesets.units.spritesheet, 
        Tilesets.units.quads[self.name][self.owner],
        (x - 1) * 16 * SCALING,
        (y - 1) * 16 * SCALING - (self.is_select and SCALING*5 or 0),
        0,
        SCALING
    )
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


return {Unit = Unit}
