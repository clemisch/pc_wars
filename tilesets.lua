-- set pixel perfect scaling 
love.graphics.setDefaultFilter('nearest', 'nearest')

-- container for all tilesets
local tilesets = {}

-- size of sprite on spritesheets 
local tilesize = {y = 16, x = 16}

local function getQuad(y, x, sizeY, sizeX, img)
    local sizeY = sizeY or 1
    local sizeX = sizeX or 1
    return love.graphics.newQuad(
        (x - 1) * tilesize.x,
        (y - 1) * tilesize.y,
        sizeX * tilesize.x,
        sizeY * tilesize.y,
        img:getDimensions())
end

-- ground tileset
local ground = {}
ground.spritesheet = love.graphics.newImage('img/ground/0.png')
ground.quadSpecs = {
    factory = {y = 5, x = 6, sizeY = 2, sizeX = 1, hasOwner = true},
    city    = {y = 3, x = 6, sizeY = 2, sizeX = 1, hasOwner = true},
    grass   = {y = 2, x = 6, sizeY = 1, sizeX = 1},
}
ground.quads = {}
for name, spec in pairs(ground.quadSpecs) do
    ground.quads[name] = {}

    -- if ground can be owned, loop over number of sprites
    if spec.hasOwner then
        for i = 5, 0, -1 do 
            ground.quads[name][i] = getQuad(spec.y, spec.x - i, spec.sizeY, spec.sizeX, ground.spritesheet)
        end
    
    -- if ground can not be owned, just set 0th sprite
    else
        ground.quads[name][0] = getQuad(spec.y, spec.x, spec.sizeY, spec.sizeX, ground.spritesheet)
    end
end


-- unit tileset
local units = {}
units.spritesheet = love.graphics.newImage('img/units/0.png')
units.quadSpecs = {
    soldierNormal = {y = 1, x = 1, sizeY = 1, sizeX = 1},
    soldierMech   = {y = 1, x = 2, sizeY = 1, sizeX = 1},
    -- tankLight     = {y = 3, x = 1, sizeY = 2, sizeX = 1}
}
units.quads = {}
for name, spec in pairs(units.quadSpecs) do
    units.quads[name] = {}
    for i = 0, 4 do 
        -- ground.quads[name][i] = getQuad(spec.y, spec.x - i, spec.sizeY, spec.sizeX, ground.spritesheet)
        units.quads[name][i] = getQuad(spec.y + i, spec.x, spec.sizeY, spec.sizeX, units.spritesheet)
    end
end


-- cursor tíleset
local cursor = {}
cursor.quads = {}
cursor.spritesheet = love.graphics.newImage('img/cursor/cursor.png')
cursor.quads.cursor = getQuad(1, 1, 1, 1, cursor.spritesheet)

-- overlay tileset
local overlays = {}
overlays.quads = {}
overlays.spritesheet = love.graphics.newImage('img/overlays/move.png')
overlays.quads.overlays = getQuad(1, 1, 1, 1, overlays.spritesheet)




tilesets.ground = ground
tilesets.units = units
tilesets.cursor = cursor
tilesets.overlays = overlays

return tilesets
