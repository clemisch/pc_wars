-- `BuyMenu` is a HUMP Gamestate
local BuyMenu = {}

function BuyMenu:init() 

end


function BuyMenu:enter(from)
    if DEBUG then
        print("Initializing gamestate <BuyMenu>")
    end

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

