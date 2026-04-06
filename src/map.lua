local Class = require("src.hump.class")

local loader = require("src.loader")
local tile = require("src.tile")
local unit = require("src.unit") 
local utils = require("src.utils")

local log = require("src.log")
log.level = LOGLEVEL

local function coords_to_string(y, x)
    return string.format("%i,%i", y, x)
end

local function string_to_coords(str)
    local y = tonumber(str:match("[%w]+"))
    local x = tonumber(str:match(",([%w]+)"))
    return y, x
end

local function is_build_tile(tile_obj)
    return tile_obj and (
        tile_obj.name == "factory" or
        tile_obj.name == "airport" or
        tile_obj.name == "seaport"
    )
end

local function is_ship_unit(unit_obj)
    return unit_obj and unit_obj.name:match("^ship_") ~= nil
end

local function is_beach_tile(tile_obj)
    return tile_obj and tile_obj.name:match("^beach_") ~= nil
end

local function can_unit_move_on_tile(unit_obj, tile_obj)
    if not unit_obj or not tile_obj then
        return false
    end

    if not is_ship_unit(unit_obj) then
        return true
    end

    if tile_obj.name == "water" or tile_obj.name == "seaport" then
        return true
    end

    if unit_obj.name == "ship_tp" and is_beach_tile(tile_obj) then
        return true
    end

    return false
end

local function has_enemy_neighbor(tile_table, y, x, owner)
    local neighbors = {
        {y = y - 1, x = x},
        {y = y + 1, x = x},
        {y = y, x = x - 1},
        {y = y, x = x + 1},
    }

    for _, coords in ipairs(neighbors) do
        local row = tile_table[coords.y]
        local tile_obj = row and row[coords.x]
        if tile_obj and tile_obj.unit and tile_obj.unit.owner ~= owner then
            return true
        end
    end

    return false
end

local function manhattan_distance(y0, x0, y1, x1)
    return math.abs(y1 - y0) + math.abs(x1 - x0)
end


local Map = Class.new()
function Map:init(name)
    self.name = name
    self.tileTable = {}
    self.is_select = false
    self.game_state = nil
    utils.timeit(self.load, {self, name}, "Level loader", "%.2f ms", 1000)
end


function Map:load(name)
    -- decode level files
    local level_data = loader.load_level(name)

    -- construct map of tiles and units from level data
    for y, row in ipairs(level_data.ground) do
        self.tileTable[y] = {}
        for x, tileStr in ipairs(row) do
            local tileOwner = level_data.groundOwner[y][x]
            local unitsOwner = level_data.unitsOwner[y][x]
            local tile = tile.Tile(tileStr, tileOwner)
            local unitStr = level_data.units[y][x]

            -- TODO: move this check into unit.Unit
            if unitStr then
                tile:set_unit(unit.Unit(unitStr, unitsOwner))
            end
            
            self.tileTable[y][x] = tile
        end
    end
end

function Map:set_move_overlay_visible(is_visible)
    if not self.tiles_move then
        return
    end

    for key, _ in pairs(self.tiles_move) do
        local y, x = string_to_coords(key)
        self.tileTable[y][x].do_overlay = is_visible
    end
end

function Map:set_attack_overlay_visible(is_visible)
    if not self.tiles_attack then
        return
    end

    for key, _ in pairs(self.tiles_attack) do
        local y, x = string_to_coords(key)
        self.tileTable[y][x].do_attack_overlay = is_visible
    end
end


function Map:draw()
    -- first draw ground/buildings
    for y, row in ipairs(self.tileTable) do
        for x, tile in ipairs(row) do
            tile:draw_ground(y, x)
        end
    end

    -- then draw overlay and units
    for y, row in ipairs(self.tileTable) do
        for x, tile in ipairs(row) do
            tile:draw_overlay(y, x)
            tile:draw_unit(y, x)
        end
    end
end


function Map:set_game_state(game_state)
    self.game_state = game_state
end

function Map:get_tile(y, x)
    return self.tileTable[y] and self.tileTable[y][x]
end

function Map:can_open_buymenu(y, x)
    local tile_sel = self:get_tile(y, x)
    local active_player = self.game_state and self.game_state.active_player

    return (
        not self.is_select and
        tile_sel ~= nil and
        tile_sel.unit == nil and
        tile_sel.owner == active_player and
        is_build_tile(tile_sel)
    )
end


function Map:select(y, x)
    local tile_sel = self.tileTable[y][x]
    local unit_sel = tile_sel.unit
    local active_player = self.game_state and self.game_state.active_player

    if self:can_open_buymenu(y, x) then
        return {
            action = "open_buymenu",
            y = y,
            x = x,
            tile = tile_sel,
        }
    end

    -- select unit if tile contains one
    if (
        not self.is_select and 
        unit_sel ~= nil    and
        unit_sel.owner == active_player and
        not unit_sel.is_used
    ) then
        self.is_select = true
        tile_sel:select()
        self.selected = {y = y, x = x, tile = tile_sel}

        -- find tiles unit could move to
        assert(tile_sel.unit.movement, tile_sel.unit.name)
        local move_range = tile_sel.unit.movement

        local function find_tile(yy, xx, rr, out)
            local this_tile = self.tileTable[yy][xx]

            -- abort if move to/through tile is illegal
            --  * enemy unit
            --  * illegal terrain
            if (
                this_tile.unit and
                this_tile.unit.owner ~= tile_sel.unit.owner
            ) then
                return
            end

            if not can_unit_move_on_tile(tile_sel.unit, this_tile) then
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
        find_tile(y, x, move_range, self.tiles_move)

        -- activate overlay over tiles unit could move to
        for k, rr in pairs(self.tiles_move) do
            local y, x = string_to_coords(k)
            self.tileTable[y][x].do_overlay = true
            self.tileTable[y][x].move_range = move_range - rr
        end
    
    end
end


function Map:de_select(y, x)
    if self.is_select then
        self:cancel_attack_targeting()
        self:cancel_action_preview()
        self.selected.tile:de_select()
        self.selected = nil
        self.is_select = false
        
        -- deactivate movement overlay
        if self.tiles_move then
            for k, _ in pairs(self.tiles_move) do
                local y, x = string_to_coords(k)
                self.tileTable[y][x].do_overlay = false
                self.tileTable[y][x].move_range = nil
            end
            self.tiles_move = nil
        end
    end

end

function Map:can_wait_at(y, x)
    if not self.is_select or not self.selected then
        return false
    end

    if self.preview then
        return y == self.preview.y and x == self.preview.x
    end

    if y == self.selected.y and x == self.selected.x then
        return true
    end

    local tile_target = self:get_tile(y, x)
    if not tile_target or tile_target.unit then
        return false
    end

    local key = coords_to_string(y, x)
    return self.tiles_move and self.tiles_move[key] ~= nil
end

function Map:begin_action_preview(y, x)
    if not self:can_wait_at(y, x) then
        return false
    end

    if self.preview then
        return self.preview.y == y and self.preview.x == x
    end

    local unit_obj = self.selected.tile.unit
    self.preview = {
        from_y = self.selected.y,
        from_x = self.selected.x,
        y = y,
        x = x,
        unit = unit_obj,
    }

    if y ~= self.selected.y or x ~= self.selected.x then
        self.tileTable[y][x].unit = unit_obj
        self.selected.tile.unit = nil
    end

    self:set_move_overlay_visible(false)
    return true
end

function Map:cancel_action_preview()
    if not self.preview then
        return false
    end

    if self.preview.y ~= self.preview.from_y or self.preview.x ~= self.preview.from_x then
        self.selected.tile.unit = self.preview.unit
        self.tileTable[self.preview.y][self.preview.x].unit = nil
    end

    self.preview = nil
    self:set_move_overlay_visible(true)
    return true
end

function Map:begin_attack_targeting(y, x)
    if not self.preview or self.preview.y ~= y or self.preview.x ~= x then
        return false
    end

    if self.tiles_attack then
        self:set_attack_overlay_visible(true)
        return true
    end

    local unit_obj = self.preview.unit
    self.tiles_attack = {}
    for yy, row in ipairs(self.tileTable) do
        for xx, _ in ipairs(row) do
            if manhattan_distance(y, x, yy, xx) <= unit_obj.range and not (yy == y and xx == x) then
                self.tiles_attack[coords_to_string(yy, xx)] = true
                self.tileTable[yy][xx].do_attack_overlay = true
            end
        end
    end

    return true
end

function Map:cancel_attack_targeting()
    if not self.tiles_attack then
        return false
    end

    for key, _ in pairs(self.tiles_attack) do
        local y, x = string_to_coords(key)
        self.tileTable[y][x].do_attack_overlay = false
    end
    self.tiles_attack = nil
    return true
end

function Map:move_unit(y, x)
    if not self:begin_action_preview(y, x) then
        return
    end

    return {
        action = "open_actionmenu",
        y = y,
        x = x,
    }
end

function Map:get_actions_at(y, x)
    if not self:can_wait_at(y, x) then
        return {}
    end

    local unit_obj = self.preview and self.preview.unit or (self.selected and self.selected.tile and self.selected.tile.unit)
    if not unit_obj then
        return {}
    end

    local actions = {"wait"}
    if has_enemy_neighbor(self.tileTable, y, x, unit_obj.owner) then
        table.insert(actions, "attack")
    end

    return actions
end

function Map:wait_unit(y, x)
    if not self:can_wait_at(y, x) then
        return false
    end

    local unit = self.preview and self.preview.unit or self.selected.tile.unit

    unit:de_select()
    unit:set_used(true)
    self.preview = nil
    self:de_select(self.selected.y, self.selected.x)
    return true
end

function Map:attack_unit(y, x)
    if not self:can_wait_at(y, x) then
        return false
    end

    log.debug("Attack is not implemented yet")
    return false
end

function Map:build_unit(y, x, unit_name, owner)
    local tile_sel = self:get_tile(y, x)
    if not tile_sel then
        return false
    end

    if tile_sel.unit ~= nil then
        return false
    end

    if tile_sel.owner ~= owner or not is_build_tile(tile_sel) then
        return false
    end

    tile_sel:set_unit(unit.Unit(unit_name, owner, 100, true))
    return true
end

function Map:set_units_used(owner, is_used)
    for _, row in ipairs(self.tileTable) do
        for _, tile_obj in ipairs(row) do
            if tile_obj.unit and tile_obj.unit.owner == owner then
                tile_obj.unit:set_used(is_used)
            end
        end
    end
end



return {
    Map = Map,
}
