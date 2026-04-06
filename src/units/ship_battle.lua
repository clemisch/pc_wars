--- @module
local ship_battle = {}

ship_battle.type = "ship"
ship_battle.lp = 100
ship_battle.hardness = 1

ship_battle.att_soft = 40
ship_battle.att_hard = 80
ship_battle.att_air = 0
ship_battle.range = 5
ship_battle.direct_fire = true

ship_battle.movement = 5
ship_battle.moveaction = false

ship_battle.cost = 10000


return ship_battle
