--[[
Function `loadLevel` gets a string (level name) and loads level with that name
from levels/ folder. It converts the levels ground and units from numbers to
string identifiers, which in turn are used in other parts of this program.
]]

--- @module
local loader = {}

loader.groundNumToString = {
    [0] = "grass",
    [1] = "factory",
    [2] = "city",
    [3] = "airport",
    [4] = "seaport",
    [5] = "hq",
}

-- encode units with integers; define string names for readability
loader.unitNumToString = {
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

loader.groundStringToNum = {}
for k,v in pairs(loader.groundNumToString) do
    loader.groundStringToNum[v] = k
end

loader.unitStringToNum = {}
for k,v in pairs(loader.unitNumToString) do
    loader.unitStringToNum[v] = k
end

function loader.loadLevel(name)
    local levelData = require("levels/" .. name)
    
    local groundTable = {}
    for y, row in ipairs(levelData.ground) do
        groundTable[y] = {}
        for x, tileNum in ipairs(row) do
            tileString = loader.groundNumToString[tileNum]
            groundTable[y][x] = tileString
        end
    end

    local unitTable = {}
    for y, row in ipairs(levelData.units) do
        unitTable[y] = {}
        for x, unitNum in ipairs(row) do
            unitString = loader.unitNumToString[unitNum]
            unitTable[y][x] = unitString
        end
    end

    local levelStringTables = {
        ground = groundTable,
        groundOwner = levelData.groundOwner,
        units = unitTable,
        unitsOwner = levelData.unitsOwner,
    }

    return levelStringTables
end


return loader
