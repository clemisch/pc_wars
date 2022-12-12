-- `Pause` is a HUMP Gamestate
local Pause = {}

local overlayWidth = 500
local overlayHeight = 300

function Pause:enter(from)
    if DEBUG then
        print("Entering gamestate <Pause>")
    end

    self.name = "Pause"
    self.from = from
end

function Pause:draw()
    -- draw underlying old gamestate
    self.from:draw()

    -- draw overlay
    love.graphics.rectangle(
        'fill',
        WIDTH_PIXELS / 2 - overlayWidth / 2,
        HEIGHT_PIXELS / 2 - overlayHeight / 2,
        overlayWidth, overlayHeight
    )
end

function Pause:update(dt)
    -- trigger update of globalTime
    self.from:update(dt)
end

function Pause:keypressed(key)
    if  key == 'p' or key == 'escape' then Gamestate.pop() end
end     

return {
    Pause = Pause,
}
