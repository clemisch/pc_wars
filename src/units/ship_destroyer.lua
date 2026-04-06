--- @module
local ship_destroyer = {}

ship_destroyer.type = "ship"
ship_destroyer.target_type = "sea"
ship_destroyer.attack_types = {"sea", "air"}
ship_destroyer.lp = 100
ship_destroyer.hardness = 1

ship_destroyer.att_soft = 40
ship_destroyer.att_hard = 70
ship_destroyer.att_air = 50
ship_destroyer.range = 1
ship_destroyer.direct_fire = true
ship_destroyer.can_build = true
ship_destroyer.producer = "seaport"

ship_destroyer.transport_capacity = 0
ship_destroyer.can_transport = false

ship_destroyer.movement = 5
ship_destroyer.moveaction = true

ship_destroyer.cost = 10000


return ship_destroyer
