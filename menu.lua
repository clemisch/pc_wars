-- `Menu` is a HUMP Gamestate
local Menu = {}

function Menu:update(dt)
    --Gamestate.switch(game)

    -- menu code here ...

end

function Menu:draw()
    love.graphics.printf(
        'Press Enter to continue!',
        WIDTH_PIXELS/2 - 50,
        HEIGHT_PIXELS/2 - 100,
        100,
        'center',
        0,
        1)
end

function Menu:keypressed(key)
    if key == 'return' then
        Gamestate.switch(game)
    end
end


return menu