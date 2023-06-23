-- `BuyMenu` is a HUMP Gamestate
local BuyMenu = {}

function BuyMenu:init() 

end


function BuyMenu:enter(from)
    log.debug("Initializing gamestate <BuyMenu>")

    self.name = "BuyMenu"
    self.from = from
end


function BuyMenu:update(dt)

end


function BuyMenu:draw()
    self.from:draw()

end


function BuyMenu:keypressed(key)

end


function BuyMenu:resume(pre)

end



--- module
return {
    buymenu = BuyMenu
}

