--- @module
local tank_light = {}

tank_light.type = "vehicle"
tank_light.target_type = "land"
tank_light.attack_types = {"land", "sea"}
tank_light.lp = 100
tank_light.hardness = 1

tank_light.att_soft = 80
tank_light.att_hard = 80
tank_light.att_air = 0
tank_light.range = 1
tank_light.direct_fire = true
tank_light.can_build = true
tank_light.producer = "factory"

tank_light.transport_capacity = 0
tank_light.can_transport = false

tank_light.movement = 5
tank_light.moveaction = true

tank_light.cost = 10000


return tank_light
