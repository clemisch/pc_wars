local log = require("src.log")
log.level = LOGLEVEL

local UnloadTarget = {}

function UnloadTarget:enter(from, y, x, cargo_index)
    log.debug("Entering gamestate <UnloadTarget>")

    self.name = "UnloadTarget"
    self.from = from
    self.game = from.game
    self.y = y
    self.x = x
    self.cargo_index = cargo_index

    self.game.cursor:moveAbs(y, x)
    if not self.game:begin_unload_targeting(y, x, cargo_index) then
        Gamestate.pop()
    end
end

function UnloadTarget:update(dt)
    self.game:update(dt)
end

function UnloadTarget:draw()
    self.game:draw()
end

function UnloadTarget:keypressed(key)
    self.game.cursor:begin_hold(key)

    if key == "w" then
        self.game.cursor:moveRel(-1, 0)
        return
    end

    if key == "s" then
        self.game.cursor:moveRel(1, 0)
        return
    end

    if key == "a" then
        self.game.cursor:moveRel(0, -1)
        return
    end

    if key == "d" then
        self.game.cursor:moveRel(0, 1)
        return
    end

    if key == "l" then
        self.game:cancel_unload_targeting()
        self.game.cursor:moveAbs(self.y, self.x)
        Gamestate.pop()
        return
    end

    if key == "k" then
        if self.game:unload_action(self.game.cursor.y, self.game.cursor.x) then
            self.game.cursor:moveAbs(self.y, self.x)
            Gamestate.pop()
        end
        return
    end
end

function UnloadTarget:keyreleased(key)
    self.game.cursor:end_hold(key)
end

function UnloadTarget:resume(pre)
    log.debug("Resuming gamestate <UnloadTarget>")
end

return {
    UnloadTarget = UnloadTarget
}
