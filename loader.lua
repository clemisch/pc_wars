--[[
Function `loadLevel` gets a string (level name) and loads level with that name
from levels/ folder. It converts the levels ground and units from numbers to
string identifiers, which in turn are used in other parts of this program.
]]

--- @module
local loader = {}

loader.groundNumToString = {
    [0] = 'grass',
    [1] = 'factory',
    [2] = 'city',
    [3] = 'airport',
    [4] = 'seaport',
    [5] = 'hq',
}

-- encode units with integers; define string names for readability
loader.unitNumToString = {
    [0] = nil,
    [1] = 'soldier_normal',
    [2] = 'soldier_mech',
    [3] = 'tank_light',
    [4] = 'tank_medium',
    [5] = 'tank_heavy',
    [6] = 'tank_ultra',
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
    local levelData = require('levels/' .. name)
    
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
