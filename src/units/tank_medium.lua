--- @module
local tank_medium = {}

tank_medium.type = "vehicle"
tank_medium.target_type = "land"
tank_medium.attack_types = {"land", "sea"}
tank_medium.lp = 100
tank_medium.hardness = 1

tank_medium.att_soft = 80
tank_medium.att_hard = 80
tank_medium.att_air = 0
tank_medium.range = 1
tank_medium.direct_fire = true
tank_medium.can_build = true
tank_medium.producer = "factory"

tank_medium.transport_capacity = 0
tank_medium.can_transport = false

tank_medium.movement = 5
tank_medium.moveaction = true

tank_medium.cost = 10000


return tank_medium
