--- @module
local tank_heavy = {}

tank_heavy.type = "vehicle"
tank_heavy.target_type = "land"
tank_heavy.attack_types = {"land", "sea"}
tank_heavy.lp = 100
tank_heavy.hardness = 1

tank_heavy.att_soft = 80
tank_heavy.att_hard = 80
tank_heavy.att_air = 0
tank_heavy.range = 1
tank_heavy.direct_fire = true
tank_heavy.can_build = true
tank_heavy.producer = "factory"

tank_heavy.transport_capacity = 0
tank_heavy.can_transport = false

tank_heavy.movement = 5
tank_heavy.moveaction = true

tank_heavy.cost = 10000


return tank_heavy
