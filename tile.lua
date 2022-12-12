local Class = require('hump.class')
local Tilesets = require('tilesets')

local Tile = Class.new()
function Tile:init(name, owner)
    assert(name)
    self.name = name
    self.owner = owner or 0
    self.unit = nil
    self.isSelect = false
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
        local overlay = Tilesets.ground.quads["city"][5]
        love.graphics.draw(
            Tilesets.ground.spritesheet,
            overlay,
            (x - 1) * 16 * SCALING,
            (y - 1) * 16 * SCALING,
            0,
            SCALING
        )
    end

    if self.unit then
        self.unit:draw(y, x)
    end
end

function Tile:setUnit(unit)
    self.unit = unit
end

function Tile:getUnit(unit)
    return self.unit
end

function Tile:select()
    self.isSelect = true
    if self.unit then
        self.unit:select()
    end
end

function Tile:deSelect()
    self.isSelect = false
    if self.unit then
        self.unit:deSelect()
    end
end



return {
    Tile = Tile
}
