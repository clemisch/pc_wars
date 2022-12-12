local Class = require('hump.class')

local loader = require('loader')
local tile = require('tile')
local unit = require('unit') 


local function string_to_coords(str)
    local y = tonumber(str:match("[%w]+"))
    local x = tonumber(str:match(",([%w]+)"))
    return y, x
end


local Map = Class.new()
function Map:init(name)
    self.name = name
    self.tileTable = {}
    self.isSelect = false
    local tStart = love.timer.getTime()
    self:load(name)
    local tStop = love.timer.getTime()
    print("Loaded level in ", tStop - tStart)
end


function Map:load(name)
    -- decode level files
    local levelData = loader.loadLevel(name)

    -- construct map of tiles and units from level data
    for y, row in ipairs(levelData.ground) do
        self.tileTable[y] = {}
        for x, tileStr in ipairs(row) do
            local tileOwner = levelData.groundOwner[y][x]
            local unitsOwner = levelData.unitsOwner[y][x]
            local tile = tile.Tile(tileStr, tileOwner)
            local unitStr = levelData.units[y][x]

            -- TODO: move this check into unit.Unit
            if unitStr then
                tile:setUnit(unit.Unit(unitStr, unitsOwner))
            end
            
            self.tileTable[y][x] = tile
        end
    end
end


function Map:draw()
    for y, row in ipairs(self.tileTable) do
        for x, tile in ipairs(row) do
            tile:draw(y, x)
        end
    end
end


function Map:select(y, x)
    -- select unit if tile contains one
    if not self.isSelect and self.tileTable[y][x]:getUnit() ~= nil then
        self.isSelect = true
        local selectedTile = self.tileTable[y][x]
        selectedTile:select()
        self.selected = {y = y, x = x, tile = selectedTile}

        -- find tiles unit could move to
        local range = self.selected.tile.unit.range
        
        local function find_tile(yy, xx, rr, out)
            local key = string.format("%i,%i", yy, xx)
            out[key] = true
            
            if rr == 0 then
                return out
            end
            
            if yy + 1 < HEIGHT_TILES then
                find_tile(yy + 1, xx, rr - 1, out)
            end
            if yy - 1 > 0 then
                find_tile(yy - 1, xx, rr - 1, out)
            end
            if xx + 1 < WIDTH_TILES then
                find_tile(yy, xx + 1, rr - 1, out)
            end
            if xx - 1 > 0 then
                find_tile(yy, xx - 1, rr - 1, out)
            end
        end
        
        self.tiles_move = {}
        find_tile(y, x, range, self.tiles_move)

        -- activate overlay over tiles unit could move to
        for k, _ in pairs(self.tiles_move) do
            local y, x = string_to_coords(k)
            self.tileTable[y][x].doOverlay = true
        end
    
    end
end


function Map:deSelect(y, x)
    if self.isSelect then
        self.selected.tile:deSelect()
        self.selected = nil
        self.isSelect = false
    end

    -- deactivate movement overlay
    for k, _ in pairs(self.tiles_move) do
        local y, x = string_to_coords(k)
        self.tileTable[y][x].doOverlay = false
    end

end


return {
    Map = Map,
}