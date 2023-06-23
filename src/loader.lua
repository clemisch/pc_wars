--[[
Function `load_level` gets a string (level name) and loads level with that name
from levels/ folder. It converts the levels ground and units from numbers to
string identifiers, which in turn are used in other parts of this program.
]]

--- @module
local loader = {}

loader.ground_num_to_string = {
    [0] = "grass",
    [1] = "factory",
    [2] = "city",
    [3] = "airport",
    [4] = "seaport",
    [5] = "hq",
}

-- encode units with integers; define string names for readability
loader.unit_num_to_string = {
    [ 0] = nil,
    [ 1] = "soldier_normal",
    [ 2] = "soldier_mech",
    [ 3] = "soldier_tp",
    [ 4] = "slime",
    [ 5] = "tank_light",
    [ 6] = "tank_medium",
    [ 7] = "tank_heavy",
    [ 8] = "tank_ultra",
    [ 9] = "tank_laser",
    [10] = "artillery",
    [11] = "artillery_rocket",
    [12] = "bomb",
    [13] = "flak_rocket",
    [14] = "flak",
    [15] = "heli_tp",
    [16] = "heli_attack",
    [17] = "plane_fighter",
    [18] = "plane_bomber",
    [19] = "plane_stealth",
    [20] = "rocket",
    [21] = "ship_robot",
    [22] = "ship_tp",
    [23] = "ship_destroyer",
    [24] = "ship_submarine",
    [25] = "ship_battle",
    [26] = "ship_carrier",
}

loader.ground_string_to_num = {}
for k,v in pairs(loader.ground_num_to_string) do
    loader.ground_string_to_num[v] = k
end

loader.unit_string_to_num = {}
for k,v in pairs(loader.unit_num_to_string) do
    loader.unit_string_to_num[v] = k
end

function loader.load_level(name)
    local data_level = require("levels/" .. name)
    
    local table_ground = {}
    for y, row in ipairs(data_level.ground) do
        table_ground[y] = {}
        for x, num_tile in ipairs(row) do
            local tile_str = loader.ground_num_to_string[num_tile]
            table_ground[y][x] = tile_str
        end
    end

    local table_unit = {}
    for y, row in ipairs(data_level.units) do
        table_unit[y] = {}
        for x, num_unit in ipairs(row) do
            local unit_str = loader.unit_num_to_string[num_unit]
            table_unit[y][x] = unit_str
        end
    end

    local levelStringTables = {
        ground = table_ground,
        groundOwner = data_level.groundOwner,
        units = table_unit,
        unitsOwner = data_level.unitsOwner,
    }

    return levelStringTables
end


return loader
