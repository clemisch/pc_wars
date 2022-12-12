-- Configuration
function love.conf(t)

    -- global config scalars
    SCALING = 4
    TILESIZE_PIXELS = 16
    WIDTH_TILES = 15
    HEIGHT_TILES = 10
    WIDTH_PIXELS = TILESIZE_PIXELS * WIDTH_TILES * SCALING
    HEIGHT_PIXELS = TILESIZE_PIXELS * HEIGHT_TILES * SCALING

    -- LÖVE config
    t.title = "PC Wars"     -- The title of the window the game is in (string)
    t.version = "11.2"      -- The LÖVE version this game was made for (string)
    t.window.height = HEIGHT_PIXELS
    t.window.width = WIDTH_PIXELS

    -- debug flag
    DEBUG = true
    
    -- For Windows debugging
    t.console = true
end