--- @module
local artillery = {}

artillery.type = "vehicle"
artillery.target_type = "land"
artillery.attack_types = {"land", "sea"}
artillery.lp = 150
artillery.hardness = 0

artillery.att_soft = 55
artillery.att_hard = 55
artillery.att_air = 0
artillery.range = {1, 2}
artillery.direct_fire = false
artillery.can_build = true
artillery.producer = "factory"

artillery.transport_capacity = 0
artillery.can_transport = false

artillery.movement = 3
artillery.moveaction = false

artillery.cost = 8000


return artillery
