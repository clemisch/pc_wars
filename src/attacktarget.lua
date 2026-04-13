local log = require("src.log")
log.level = LOGLEVEL

local AttackTarget = {}

function AttackTarget:enter(from, y, x)
    log.debug("Entering gamestate <AttackTarget>")

    self.name = "AttackTarget"
    self.from = from
    self.game = from.game
    self.y = y
    self.x = x

    self.game.cursor:moveAbs(y, x)
    self.game:begin_attack_targeting(y, x)
end

function AttackTarget:update(dt)
    self.game:update(dt)
end

function AttackTarget:draw()
    self.game:draw()
end

function AttackTarget:keypressed(key)
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
        self.game:cancel_attack_targeting()
        self.game.cursor:moveAbs(self.y, self.x)
        Gamestate.pop()
        return
    end

    if key == "k" then
        if self.game:attack_action(self.game.cursor.y, self.game.cursor.x) then
            Gamestate.pop()
            Gamestate.pop()
        end
        return
    end
end

function AttackTarget:keyreleased(key)
    self.game.cursor:end_hold(key)
end

function AttackTarget:resume(pre)
    log.debug("Resuming gamestate <AttackTarget>")
end

return {
    AttackTarget = AttackTarget
}
