local Class = require('hump.class')

local loader = require('loader')
local tile = require('tile')
local unit = require('unit') 



local function coords_to_string(y, x)
    return string.format("%i,%i", y, x)
end

local function string_to_coords(str)
    local y = tonumber(str:match("[%w]+"))
    local x = tonumber(str:match(",([%w]+)"))
    return y, x
end


local Map = Class.new()
function Map:init(name)
    self.name = name
    self.tileTable = {}
    self.is_select = false
    local tStart = love.timer.getTime()
    self:load(name)
    local tStop = love.timer.getTime()
    print(("Loaded level in %.2f ms"):format(1000 * (tStop - tStart)))
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
                tile:set_unit(unit.Unit(unitStr, unitsOwner))
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
    local tile_sel = self.tileTable[y][x]
    local unit_sel = tile_sel.unit
    if (
        not self.is_select and 
        unit_sel ~= nil   and
        unit_sel.owner == game.Game.active_player
    ) then
        self.is_select = true
        tile_sel:select()
        self.selected = {y = y, x = x, tile = tile_sel}

        -- find tiles unit could move to
        local range = tile_sel.unit.range
        
        local function find_tile(yy, xx, rr, out)
            local this_tile = self.tileTable[yy][xx]

            -- abort if move to/through tile is illegal
            --  * enemy unit
            --  * TODO: illegal terrain
            if (
                this_tile.unit and
                this_tile.unit.owner ~= tile_sel.unit.owner
            ) then
                return
            end

            -- abort if visited tile before with more or same range
            local key = coords_to_string(yy, xx)
            local prev_range = out[key] or -1
            if prev_range >= rr then 
                return 
            end

            -- add tile to legal tiles if we could move there
            -- (*through* is not enough: if friendly unit on tile, we can move but can't stay)
            if this_tile.unit == nil then
                out[key] = rr
            end
            
            -- return if there is no range left
            if rr == 0 then
                return 
            end
            
            if yy + 1 <= HEIGHT_TILES then
                find_tile(yy + 1, xx, rr - 1, out)
            end
            if yy - 1 > 0 then
                find_tile(yy - 1, xx, rr - 1, out)
            end
            if xx + 1 <= WIDTH_TILES then
                find_tile(yy, xx + 1, rr - 1, out)
            end
            if xx - 1 > 0 then
                find_tile(yy, xx - 1, rr - 1, out)
            end
        end
        
        self.tiles_move = {}
        find_tile(y, x, range, self.tiles_move)

        -- activate overlay over tiles unit could move to
        for k, rr in pairs(self.tiles_move) do
            local y, x = string_to_coords(k)
            self.tileTable[y][x].doOverlay = true
            self.tileTable[y][x].range = range - rr
        end
    
    end
end


function Map:de_select(y, x)
    if self.is_select then
        self.selected.tile:de_select()
        self.selected = nil
        self.is_select = false
        
        -- deactivate movement overlay
        for k, _ in pairs(self.tiles_move) do
            local y, x = string_to_coords(k)
            self.tileTable[y][x].doOverlay = false
            self.tileTable[y][x].range = nil
            self.tiles_move = nil
        end
    end

end


function Map:move_unit(y, x)
    --[[
    Try to move selected unit to (y, x). 
    New tile must be empty and within movement range.
    --]]
    if self.tileTable[y][x].unit then
        return
    end

    local key = coords_to_string(y, x)
    if not self.tiles_move[key] then
        return
    end

    local unit = self.selected.tile.unit
    self.tileTable[y][x].unit = unit
    unit:de_select()
    
    -- clear old tile
    self.selected.tile.unit = nil
    self:de_select(self.selected.y, self.selected.x)
end



return {
    Map = Map,
}