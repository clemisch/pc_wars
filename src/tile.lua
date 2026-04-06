local Class = require("src.hump.class")
local Tilesets = require("src.tilesets")

local Tile = Class.new()
function Tile:init(name, owner)
    assert(name)
    self.name = name
    self.owner = owner or 0
    self.unit = nil
    self.is_select = false
    self.do_overlay = false
    self.do_attack_overlay = false
end

function Tile:__tostring()
    return self.name
end

function Tile:draw(y, x)
    self:draw_ground(y, x)
    self:draw_overlay(y, x)
end

function Tile:draw_ground(y, x)
    local spritesheet, quad = Tilesets.ground:get_drawable(self.name, self.owner)
    local _, _, _, height = quad:getViewport()
    local yOffset = (height / 16) - 1  -- for tilesets higher than 16px

    love.graphics.draw(
        spritesheet,
        quad,
        (x - 1) * 16 * SCALING,
        (y - 1 - yOffset) * 16 * SCALING,
        0,
        SCALING
    )
end

function Tile:draw_overlay(y, x)
    if self.do_overlay then
        local overlay = Tilesets.overlays.quads.move
        love.graphics.draw(
            Tilesets.overlays.move_spritesheet,
            overlay,
            (x - 1) * 16 * SCALING,
            (y - 1) * 16 * SCALING,
            0,
            SCALING
        )
    end

    if self.do_attack_overlay then
        local overlay = Tilesets.overlays.quads.attack
        love.graphics.draw(
            Tilesets.overlays.attack_spritesheet,
            overlay,
            (x - 1) * 16 * SCALING,
            (y - 1) * 16 * SCALING,
            0,
            SCALING
        )
    end
end

function Tile:draw_unit(y, x)
    if self.unit then
        self.unit:draw(y, x)
    end
end

function Tile:set_unit(unit)
    self.unit = unit
end

function Tile:get_unit(unit)
    return self.unit
end

function Tile:select()
    self.is_select = true
    if self.unit then
        self.unit:select()
    end
end

function Tile:de_select()
    self.is_select = false
    if self.unit then
        self.unit:de_select()
    end
end



return {
    Tile = Tile
}
