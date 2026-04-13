local Class = require("src.hump.class")
local Tilesets = require("src.tilesets")

local log = require("src.log")
log.level = LOGLEVEL

local Cursor = Class.new()

local HOLD_DIRECTIONS = {
    w = {-1, 0},
    s = {1, 0},
    a = {0, -1},
    d = {0, 1},
}

function Cursor:init(map)
    assert(map)

    self.map = map
    self.x = 1
    self.y = 1
    self.is_select = false
    self.hold_key = nil
    self.hold_delay = 0.22
    self.hold_interval = 0.08
    self.hold_elapsed = 0
    self.hold_repeating = false
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
        log.error("y beyond bounds: " .. y)
        return
    elseif x < 0 or x > WIDTH_TILES then
        log.error("x beyond bounds: " .. x)
        return
    end

    self.y = y
    self.x = x
end

function Cursor:update(key)
    if  
        key == "w" then self:moveRel(-1, 0)              elseif
        key == "s" then self:moveRel(1, 0)               elseif
        key == "d" then self:moveRel(0, 1)               elseif
        key == "a" then self:moveRel(0, -1)              elseif
        key == "k" then return self:select()             elseif
        key == "l" then self:de_select()                 elseif
        key == "e" then self:moveAbs(1000, 1000) 
    end
end

function Cursor:begin_hold(key)
    if not HOLD_DIRECTIONS[key] then
        return
    end

    self.hold_key = key
    self.hold_elapsed = 0
    self.hold_repeating = false
end

function Cursor:end_hold(key)
    if key ~= self.hold_key then
        return
    end

    self.hold_key = nil
    self.hold_elapsed = 0
    self.hold_repeating = false
end

function Cursor:update_hold(dt)
    if not self.hold_key then
        return false
    end

    if not love.keyboard.isDown(self.hold_key) then
        self.hold_key = nil
        self.hold_elapsed = 0
        self.hold_repeating = false
        return false
    end

    self.hold_elapsed = self.hold_elapsed + dt
    local dy, dx = unpack(HOLD_DIRECTIONS[self.hold_key])
    local did_move = false

    if not self.hold_repeating then
        if self.hold_elapsed < self.hold_delay then
            return false
        end

        self.hold_elapsed = self.hold_elapsed - self.hold_delay
        self.hold_repeating = true
        self:moveRel(dy, dx)
        did_move = true
    end

    while self.hold_elapsed >= self.hold_interval do
        self.hold_elapsed = self.hold_elapsed - self.hold_interval
        self:moveRel(dy, dx)
        did_move = true
    end

    return did_move
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
    if self.map.is_select then
        return self.map:move_unit(self.y, self.x)
    else
        return self.map:select(self.y, self.x)
    end
end

function Cursor:de_select()
    self.map:de_select(self.y, self.x)
end


return {
    Cursor = Cursor,
}
