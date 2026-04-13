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
        tile_obj.name == "city" or
        tile_obj.name == "factory" or
        tile_obj.name == "airport" or
        tile_obj.name == "seaport" or
        tile_obj.name == "hq"
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

local function can_transport_unit(loader_unit, moving_unit)
    return (
        loader_unit and
        moving_unit and
        loader_unit.transport_capacity and
        #loader_unit.cargo < loader_unit.transport_capacity and
        type(loader_unit.can_transport) == "function" and
        loader_unit:can_transport(moving_unit)
    )
end

local function compute_move_tiles(tile_table, start_y, start_x, unit_obj, include_transport_tiles)
    local out = {}

    local function find_tile(yy, xx, rr)
        local this_tile = tile_table[yy][xx]

        if (
            this_tile.unit and
            this_tile.unit.owner ~= unit_obj.owner
        ) then
            return
        end

        if not can_unit_move_on_tile(unit_obj, this_tile) then
            return
        end

        local key = coords_to_string(yy, xx)
        local prev_range = out[key] or -1
        if prev_range >= rr then
            return
        end

        if (
            this_tile.unit == nil or
            (include_transport_tiles and can_transport_unit(this_tile.unit, unit_obj))
        ) then
            out[key] = rr
        end

        if rr == 0 then
            return
        end

        if yy + 1 <= HEIGHT_TILES then
            find_tile(yy + 1, xx, rr - 1)
        end
        if yy - 1 > 0 then
            find_tile(yy - 1, xx, rr - 1)
        end
        if xx + 1 <= WIDTH_TILES then
            find_tile(yy, xx + 1, rr - 1)
        end
        if xx - 1 > 0 then
            find_tile(yy, xx - 1, rr - 1)
        end
    end

    find_tile(start_y, start_x, unit_obj.movement)
    return out
end

local function can_unit_end_turn_on_tile(unit_obj, tile_obj)
    if not unit_obj or not tile_obj then
        return false
    end

    if unit_obj.target_type == "air" then
        return true
    end

    if is_ship_unit(unit_obj) then
        return can_unit_move_on_tile(unit_obj, tile_obj)
    end

    return tile_obj.name ~= "water"
end

local function manhattan_distance(y0, x0, y1, x1)
    return math.abs(y1 - y0) + math.abs(x1 - x0)
end

local function get_attack_range_bounds(unit_obj)
    return unit_obj.range[1], unit_obj.range[2]
end

local function is_air_unit(unit_obj)
    return unit_obj and unit_obj.target_type == "air"
end

local function can_unit_attack_target(attacker, defender)
    return (
        attacker and
        defender and
        attacker.attack_types_lookup and
        defender.target_type and
        attacker.attack_types_lookup[defender.target_type] == true
    )
end

local function get_attack_stat(attacker, defender)
    if is_air_unit(defender) then
        return attacker.att_air or 0
    end

    if defender.hardness and defender.hardness > 0 then
        return attacker.att_hard or 0
    end

    return attacker.att_soft or 0
end

local function get_tile_cover(tile_obj)
    local cover = {
        grass = 1,
        city = 2,
        factory = 2,
        airport = 2,
        seaport = 2,
        hq = 3,
        water = 0,
        beach_n = 0,
        beach_e = 0,
        beach_s = 0,
        beach_w = 0,
        beach_nw = 0,
        beach_ne = 0,
        beach_se = 0,
        beach_sw = 0,
    }

    return cover[tile_obj.name] or 0
end

local function calculate_damage(attacker, defender, defender_tile)
    local attacker_factor = attacker.lp / attacker.max_lp
    local hardness = defender.hardness or 0
    local soft_dmg = (attacker.att_soft or 0) * attacker_factor * (1 - hardness)
    local hard_dmg = (attacker.att_hard or 0) * attacker_factor * hardness

    if is_air_unit(defender) then
        soft_dmg = 0
        hard_dmg = (attacker.att_air or 0) * attacker_factor
    end

    local factor_terrain = 1 - (get_tile_cover(defender_tile) / 5)
    local factor_rand = 0.9 + love.math.random() * 0.2
    return math.floor((factor_rand * factor_terrain * (soft_dmg + hard_dmg)) + 0.5)
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

function Map:set_attack_inspect_overlay_visible(is_visible)
    if not self.tiles_attack_inspect then
        return
    end

    for key, _ in pairs(self.tiles_attack_inspect) do
        local y, x = string_to_coords(key)
        self.tileTable[y][x].do_attack_overlay = is_visible
    end
end

function Map:set_unload_overlay_visible(is_visible)
    if not self.tiles_unload then
        return
    end

    for key, _ in pairs(self.tiles_unload) do
        local y, x = string_to_coords(key)
        self.tileTable[y][x].do_overlay = is_visible
        self.tileTable[y][x].move_range = nil
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
            tile:draw_unit(y, x)
            tile:draw_overlay(y, x)
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

        self.tiles_move = compute_move_tiles(self.tileTable, y, x, tile_sel.unit, true)

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
        self:cancel_unload_targeting()
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

function Map:can_load_at(y, x)
    if not self.is_select or not self.selected or self.preview then
        return false
    end

    if y == self.selected.y and x == self.selected.x then
        return false
    end

    local tile_target = self:get_tile(y, x)
    local moving_unit = self.selected.tile.unit
    local key = coords_to_string(y, x)

    return (
        tile_target ~= nil and
        tile_target.unit ~= nil and
        tile_target.unit.owner == moving_unit.owner and
        self.tiles_move and
        self.tiles_move[key] ~= nil and
        can_transport_unit(tile_target.unit, moving_unit)
    )
end

function Map:can_attack_from(y, x)
    if not self.preview or self.preview.y ~= y or self.preview.x ~= x then
        return false
    end

    local unit_obj = self.preview.unit
    if not unit_obj or not unit_obj.range then
        return false
    end

    if (
        not unit_obj.moveaction and
        (self.preview.y ~= self.preview.from_y or self.preview.x ~= self.preview.from_x)
    ) then
        return false
    end

    local min_range, max_range = get_attack_range_bounds(unit_obj)
    for yy, row in ipairs(self.tileTable) do
        for xx, tile_obj in ipairs(row) do
            local dist = manhattan_distance(y, x, yy, xx)
            if (
                dist >= min_range and
                dist <= max_range and
                tile_obj.unit and
                tile_obj.unit.owner ~= unit_obj.owner and
                can_unit_attack_target(unit_obj, tile_obj.unit)
            ) then
                return true
            end
        end
    end

    return false
end

function Map:can_unload_from(y, x)
    if not self.preview or self.preview.is_load or self.preview.y ~= y or self.preview.x ~= x then
        return false
    end

    return self.preview.unit and #self.preview.unit.cargo > 0
end

function Map:begin_action_preview(y, x)
    if not self:can_wait_at(y, x) and not self:can_load_at(y, x) then
        return false
    end

    if self.preview then
        return self.preview.y == y and self.preview.x == x
    end

    local unit_obj = self.selected.tile.unit
    local tile_target = self:get_tile(y, x)
    local is_load = self:can_load_at(y, x)
    self.preview = {
        from_y = self.selected.y,
        from_x = self.selected.x,
        y = y,
        x = x,
        unit = unit_obj,
        is_load = is_load,
        transport = is_load and tile_target.unit or nil,
        committed = false,
    }

    if not is_load and (y ~= self.selected.y or x ~= self.selected.x) then
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

    if self.preview.committed then
        return false
    end

    if (
        not self.preview.is_load and
        (self.preview.y ~= self.preview.from_y or self.preview.x ~= self.preview.from_x)
    ) then
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

    if not self:can_attack_from(y, x) then
        return false
    end

    if self.tiles_attack then
        self:set_attack_overlay_visible(true)
        return true
    end

    local unit_obj = self.preview.unit
    local min_range, max_range = get_attack_range_bounds(unit_obj)
    self.tiles_attack = {}
    for yy, row in ipairs(self.tileTable) do
        for xx, _ in ipairs(row) do
            local dist = manhattan_distance(y, x, yy, xx)
            if dist >= min_range and dist <= max_range then
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

function Map:show_attack_inspect(y, x)
    self:hide_attack_inspect()

    if self.is_select then
        return false
    end

    local tile_sel = self:get_tile(y, x)
    local unit_obj = tile_sel and tile_sel.unit
    if not unit_obj or not unit_obj.attack_types or #unit_obj.attack_types == 0 then
        return false
    end

    local positions = {}
    if unit_obj.moveaction then
        positions = compute_move_tiles(self.tileTable, y, x, unit_obj, false)
    else
        positions[coords_to_string(y, x)] = unit_obj.movement
    end
    positions[coords_to_string(y, x)] = unit_obj.movement

    local min_range, max_range = get_attack_range_bounds(unit_obj)
    self.tiles_attack_inspect = {}
    for key, _ in pairs(positions) do
        local yy, xx = string_to_coords(key)
        for ty, row in ipairs(self.tileTable) do
            for tx, _ in ipairs(row) do
                local dist = manhattan_distance(yy, xx, ty, tx)
                if dist >= min_range and dist <= max_range then
                    local attack_key = coords_to_string(ty, tx)
                    self.tiles_attack_inspect[attack_key] = true
                    self.tileTable[ty][tx].do_attack_overlay = true
                end
            end
        end
    end

    return true
end

function Map:hide_attack_inspect()
    if not self.tiles_attack_inspect then
        return false
    end

    for key, _ in pairs(self.tiles_attack_inspect) do
        local y, x = string_to_coords(key)
        self.tileTable[y][x].do_attack_overlay = false
    end
    self.tiles_attack_inspect = nil
    return true
end

function Map:begin_unload_targeting(y, x, cargo_index)
    if not self:can_unload_from(y, x) then
        return false
    end

    local cargo_unit = self.preview.unit.cargo[cargo_index]
    if not cargo_unit then
        return false
    end

    self:cancel_unload_targeting()
    self.unload_preview = {
        cargo_index = cargo_index,
        unit = cargo_unit,
        y = y,
        x = x,
    }

    local candidates = {
        {y = y - 1, x = x},
        {y = y + 1, x = x},
        {y = y, x = x - 1},
        {y = y, x = x + 1},
    }

    self.tiles_unload = {}
    local has_targets = false
    for _, coords in ipairs(candidates) do
        local tile_target = self:get_tile(coords.y, coords.x)
        if (
            tile_target and
            tile_target.unit == nil and
            can_unit_end_turn_on_tile(cargo_unit, tile_target)
        ) then
            local key = coords_to_string(coords.y, coords.x)
            self.tiles_unload[key] = true
            tile_target.do_overlay = true
            tile_target.move_range = nil
            has_targets = true
        end
    end

    if not has_targets then
        self:cancel_unload_targeting()
        return false
    end

    return true
end

function Map:cancel_unload_targeting()
    if not self.tiles_unload then
        self.unload_preview = nil
        return false
    end

    for key, _ in pairs(self.tiles_unload) do
        local y, x = string_to_coords(key)
        self.tileTable[y][x].do_overlay = false
        self.tileTable[y][x].move_range = nil
    end
    self.tiles_unload = nil
    self.unload_preview = nil
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
    if not self.preview then
        return {}
    end

    if self.preview.is_load then
        if self.preview.y == y and self.preview.x == x then
            return {"load"}
        end
        return {}
    end

    if not self:can_wait_at(y, x) then
        return {}
    end

    local unit_obj = self.preview and self.preview.unit or (self.selected and self.selected.tile and self.selected.tile.unit)
    if not unit_obj then
        return {}
    end

    local actions = {
        {id = "wait", label = "Wait"},
    }
    if self:can_attack_from(y, x) then
        table.insert(actions, {id = "attack", label = "Attack"})
    end
    if self:can_unload_from(y, x) then
        for cargo_index, cargo_unit in ipairs(unit_obj.cargo) do
            table.insert(actions, {
                id = "unload",
                label = "Unload " .. cargo_unit.name,
                cargo_index = cargo_index,
            })
        end
    end
    if self.preview.is_load then
        actions = {
            {id = "load", label = "Load"},
        }
    end

    return actions
end

function Map:load_unit(y, x)
    if (
        not self.preview or
        not self.preview.is_load or
        self.preview.y ~= y or
        self.preview.x ~= x
    ) then
        return false
    end

    local moving_unit = self.preview.unit
    local transport = self.preview.transport
    if not can_transport_unit(transport, moving_unit) then
        return false
    end

    moving_unit:de_select()
    moving_unit:set_used(true)
    table.insert(transport.cargo, moving_unit)
    self.selected.tile.unit = nil

    self.preview = nil
    self:de_select(self.selected.y, self.selected.x)
    return true
end

function Map:can_unload_unit_at(y, x)
    if not self.unload_preview or not self.tiles_unload then
        return false
    end

    local key = coords_to_string(y, x)
    return self.tiles_unload[key] == true
end

function Map:unload_unit(y, x)
    if not self:can_unload_unit_at(y, x) then
        return false
    end

    local cargo_index = self.unload_preview.cargo_index
    local transport = self.preview and self.preview.unit
    local cargo_unit = transport and transport.cargo[cargo_index]
    local tile_target = self:get_tile(y, x)
    if not cargo_unit or not tile_target or tile_target.unit then
        return false
    end

    table.remove(transport.cargo, cargo_index)
    cargo_unit:set_used(true)
    cargo_unit:de_select()
    tile_target.unit = cargo_unit

    self.preview.committed = true
    self:cancel_unload_targeting()
    return true
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

function Map:can_attack_unit_at(y, x)
    if not self.preview or not self.tiles_attack then
        return false
    end

    local key = coords_to_string(y, x)
    if not self.tiles_attack[key] then
        return false
    end

    local attacker = self.preview.unit
    local tile_target = self:get_tile(y, x)
    local defender = tile_target and tile_target.unit

    return (
        attacker ~= nil and
        defender ~= nil and
        defender.owner ~= attacker.owner and
        can_unit_attack_target(attacker, defender)
    )
end

function Map:attack_unit(y, x)
    if not self:can_attack_unit_at(y, x) then
        return false
    end

    local attacker = self.preview.unit
    local attacker_tile = self:get_tile(self.preview.y, self.preview.x)
    local tile_target = self:get_tile(y, x)
    local defender = tile_target.unit
    local distance = manhattan_distance(self.preview.y, self.preview.x, y, x)

    local damage_to_defender = calculate_damage(attacker, defender, tile_target)
    defender:take_damage(damage_to_defender)
    if defender:is_destroyed() then
        tile_target.unit = nil
    elseif distance == 1 and attacker.direct_fire and defender.direct_fire then
        local damage_to_attacker = calculate_damage(defender, attacker, attacker_tile)
        attacker:take_damage(damage_to_attacker)
        if attacker:is_destroyed() then
            attacker_tile.unit = nil
        end
    end

    if not attacker:is_destroyed() then
        attacker:de_select()
        attacker:set_used(true)
    end

    self.preview = nil
    self:de_select(self.selected.y, self.selected.x)
    return true
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

    tile_sel:set_unit(unit.Unit(unit_name, owner, nil, true))
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

function Map:get_num_buildings(owner)
    local num_buildings = 0

    for _, row in ipairs(self.tileTable) do
        for _, tile_obj in ipairs(row) do
            if tile_obj.owner == owner and is_build_tile(tile_obj) then
                num_buildings = num_buildings + 1
            end
        end
    end

    return num_buildings
end



return {
    Map = Map,
}
