local Class = require("src.hump.class")
local Tilesets = require("src.tilesets")

local Tile = Class.new()
function Tile:init(name, owner)
    assert(name)
    self.name = name
    self.owner = owner or 0
    self.unit = nil
    self.is_select = false
    self.doOverlay = false
end

function Tile:__tostring()
    return self.name
end

function Tile:draw(y, x)
    local quad = Tilesets.ground.quads[self.name][self.owner]
    local _, _, _, height = quad:getViewport()
    local yOffset = (height / 16) - 1  -- for tilesets higher than 16px

    love.graphics.draw(
        Tilesets.ground.spritesheet,
        quad,
        (x - 1) * 16 * SCALING,
        (y - 1 - yOffset) * 16 * SCALING,
        0,
        SCALING
    )

    if self.doOverlay then
        -- white overlay
        local overlay = Tilesets.overlays.quads.overlays
        love.graphics.draw(
            Tilesets.overlays.spritesheet,
            overlay,
            (x - 1) * 16 * SCALING,
            (y - 1) * 16 * SCALING,
            0,
            SCALING
        )
        -- number of moves to get this tile
        love.graphics.print(
            {{0, 0, 0}, tostring(self.range)}, 
            ((x - 1) * 16 + 6) * SCALING, 
            ((y - 1) * 16 + 6) * SCALING,
            0, 2
        )
    end

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
