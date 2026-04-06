--- @module
local ship_carrier = {}

ship_carrier.type = "ship"
ship_carrier.target_type = "sea"
ship_carrier.attack_types = {}
ship_carrier.lp = 100
ship_carrier.hardness = 1

ship_carrier.att_soft = 0
ship_carrier.att_hard = 0
ship_carrier.att_air = 0
ship_carrier.range = 1
ship_carrier.direct_fire = true
ship_carrier.can_build = true
ship_carrier.producer = "seaport"

ship_carrier.movement = 5
ship_carrier.moveaction = true

ship_carrier.cost = 10000


return ship_carrier
