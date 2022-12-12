local Class = require('hump.class')
local Tilesets = require('tilesets')
local Loader = require("loader")
local unit_db = require("units/unit_db")


local unit_int_to_string = Loader.unitNumToString
local unit_string_to_ing = Loader.groundStringToNum






local Unit = Class.new()
function Unit:init(name, owner, health)
    self.name = name
    self.owner = owner or 0
    self.health = health or 100
    self.range = unit_db[name].range
end

function Unit:draw(y, x)
    -- draw the unit at tile y, x (lua indexing)
    love.graphics.draw(
        Tilesets.units.spritesheet, 
        Tilesets.units.quads[self.name][self.owner],
        (x - 1) * 16 * SCALING,
        (y - 1) * 16 * SCALING - (self.isSelect and SCALING*5 or 0),
        0,
        SCALING
    )
end

function Unit:select()
    self.isSelect = true
end

function Unit:deSelect()
    self.isSelect = false
end


return {Unit = Unit}
