local Class = require('hump.class')
local Tilesets = require('tilesets')

local Cursor = Class.new()
function Cursor:init(map)
    assert(map)

    self.map = map
    self.x = 1
    self.y = 1
    self.isSelect = false
end

function Cursor:moveRel(y, x)
    local new_y = self.y + y
    local new_x = self.x + x
    if new_y > 0 and new_y <= HEIGHT_TILES then
        self.y = new_y
    end
    if new_x > 0 and new_x <= WIDTH_TILES then
        self.x = new_x
    end
end

function Cursor:moveAbs(y, x)
    if y < 0 or y > HEIGHT_TILES then
        error("y beyond bounds")
    end
    if x < 0 or x > WIDTH_TILES then
        error("x beyond bounds")
    end

    self.y = y
    self.x = x
end

function Cursor:update(key)
    if  key == 'w'      then self:moveRel(-1, 0)    elseif
        key == 's'      then self:moveRel(1, 0)     elseif
        key == 'd'      then self:moveRel(0, 1)     elseif
        key == 'a'      then self:moveRel(0, -1)    elseif
        key == 'k'      then self:select()          elseif
        key == 'l'      then self:deSelect()
    end
end

function Cursor:draw()
    love.graphics.draw(
        Tilesets.cursor.spritesheet,
        Tilesets.cursor.quads.cursor,
        (self.x - 1) * SCALING * TILESIZE_PIXELS,
        (self.y - 1) * SCALING * TILESIZE_PIXELS,
        0,
        SCALING
    )
end

function Cursor:select()
    -- move selected unit to cursor
    if self.map.isSelect then
        -- do nothing if new tile contains unit
        if self.map.tileTable[self.y][self.x].unit then
            return nil
        end

        -- set new tile
        local unit = self.map.selected.tile.unit
        unit:deSelect()
        self.map.tileTable[self.y][self.x].unit = unit
        
        -- clear old tile
        self.map.selected.tile.unit = nil
        self.map:deSelect(self.map.selected.y, self.map.selected.x)

    -- select unit
    else
        self.map:select(self.y, self.x)
    end
end

function Cursor:deSelect()
    self.map:deSelect(self.y, self.x)
end


return {
    Cursor = Cursor,
}