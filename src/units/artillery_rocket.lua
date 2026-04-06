--- @module
local artillery_rocket = {}

artillery_rocket.type = "vehicle"
artillery_rocket.target_type = "land"
artillery_rocket.attack_types = {"air"}
artillery_rocket.lp = 100
artillery_rocket.hardness = 1

artillery_rocket.att_soft = 90
artillery_rocket.att_hard = 55
artillery_rocket.att_air = 0
artillery_rocket.range = {2, 4}
artillery_rocket.direct_fire = false
artillery_rocket.can_build = true
artillery_rocket.producer = "factory"

artillery_rocket.movement = 3
artillery_rocket.moveaction = false

artillery_rocket.cost = 18000


return artillery_rocket
