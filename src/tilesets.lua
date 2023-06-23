-- set pixel perfect scaling 
love.graphics.setDefaultFilter("nearest", "nearest")

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
        img:getDimensions()
    )
end

-- ground tileset
local ground = {}
ground.spritesheet = love.graphics.newImage("img/ground/0.png")
ground.quadSpecs = {
    grass   = {y = 2 , x = 6, sizeY = 1, sizeX = 1                 },
    city    = {y = 3 , x = 1, sizeY = 2, sizeX = 1, hasOwner = true},
    factory = {y = 5 , x = 1, sizeY = 2, sizeX = 1, hasOwner = true},
    airport = {y = 7 , x = 1, sizeY = 2, sizeX = 1, hasOwner = true},
    seaport = {y = 9 , x = 1, sizeY = 2, sizeX = 1, hasOwner = true},
    hq      = {y = 11, x = 1, sizeY = 2, sizeX = 1, hasOwner = true},
}
ground.quads = {}
for name, spec in pairs(ground.quadSpecs) do
    ground.quads[name] = {}

    -- if ground can be owned, loop over number of sprites
    if spec.hasOwner then
        ground.quads[name][0] = getQuad(spec.y, spec.x + 5, spec.sizeY, spec.sizeX, ground.spritesheet)
        for i = 1, 5 do 
            ground.quads[name][i] = getQuad(spec.y, spec.x + i - 1, spec.sizeY, spec.sizeX, ground.spritesheet)
        end
    
    -- if ground can not be owned, just set 0th sprite
    else
        ground.quads[name][0] = getQuad(spec.y, spec.x, spec.sizeY, spec.sizeX, ground.spritesheet)
    end
end


-- unit tileset
local units = {}
units.spritesheet = love.graphics.newImage("img/units/0.png")
units.quadSpecs = {
    soldier_normal   = {y = 1, x = 1 , sizeY = 1, sizeX = 1},
    soldier_mech     = {y = 1, x = 2 , sizeY = 1, sizeX = 1},
    soldier_tp       = {y = 1, x = 3 , sizeY = 1, sizeX = 1},
    slime            = {y = 1, x = 4 , sizeY = 1, sizeX = 1},
    tank_light       = {y = 1, x = 5 , sizeY = 1, sizeX = 1},
    tank_medium      = {y = 1, x = 6 , sizeY = 1, sizeX = 1},
    tank_heavy       = {y = 1, x = 7 , sizeY = 1, sizeX = 1},
    tank_ultra       = {y = 1, x = 8 , sizeY = 1, sizeX = 1},
    tank_laser       = {y = 1, x = 9 , sizeY = 1, sizeX = 1},
    artillery        = {y = 1, x = 10, sizeY = 1, sizeX = 1},
    artillery_rocket = {y = 1, x = 11, sizeY = 1, sizeX = 1},
    bomb             = {y = 1, x = 12, sizeY = 1, sizeX = 1},
    flak_rocket      = {y = 1, x = 13, sizeY = 1, sizeX = 1},
    flak             = {y = 1, x = 14, sizeY = 1, sizeX = 1},
    heli_tp          = {y = 1, x = 15, sizeY = 1, sizeX = 1},
    heli_attack      = {y = 1, x = 16, sizeY = 1, sizeX = 1},
    plane_fighter    = {y = 1, x = 17, sizeY = 1, sizeX = 1},
    plane_bomber     = {y = 1, x = 18, sizeY = 1, sizeX = 1},
    plane_stealth    = {y = 1, x = 19, sizeY = 1, sizeX = 1},
    rocket           = {y = 1, x = 20, sizeY = 1, sizeX = 1},
    ship_robot       = {y = 1, x = 21, sizeY = 1, sizeX = 1},
    ship_tp          = {y = 1, x = 22, sizeY = 1, sizeX = 1},
    ship_destroyer   = {y = 1, x = 23, sizeY = 1, sizeX = 1},
    ship_submarine   = {y = 1, x = 24, sizeY = 1, sizeX = 1},
    ship_battle      = {y = 1, x = 25, sizeY = 1, sizeX = 1},
    ship_carrier     = {y = 1, x = 26, sizeY = 1, sizeX = 1},
}
units.quads = {}
for name, spec in pairs(units.quadSpecs) do
    units.quads[name] = {}
    for i = 1, 5 do 
        -- ground.quads[name][i] = getQuad(spec.y, spec.x - i, spec.sizeY, spec.sizeX, ground.spritesheet)
        units.quads[name][i] = getQuad(spec.y + i - 1, spec.x, spec.sizeY, spec.sizeX, units.spritesheet)
    end
end


-- cursor tíleset
local cursor = {}
cursor.quads = {}
cursor.spritesheet = love.graphics.newImage("img/cursor/cursor.png")
cursor.quads.cursor = getQuad(1, 1, 1, 1, cursor.spritesheet)

-- overlay tileset
local overlays = {}
overlays.quads = {}
overlays.spritesheet = love.graphics.newImage("img/overlays/move.png")
overlays.quads.overlays = getQuad(1, 1, 1, 1, overlays.spritesheet)




tilesets.ground = ground
tilesets.units = units
tilesets.cursor = cursor
tilesets.overlays = overlays

return tilesets
