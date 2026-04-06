--- @module
local rocket = {}

rocket.type = "plane"
rocket.target_type = "air"
rocket.attack_types = {"land", "sea"}
rocket.lp = 100
rocket.hardness = 1

rocket.att_soft = 80
rocket.att_hard = 80
rocket.att_air = 0
rocket.range = 1
rocket.direct_fire = true
rocket.can_build = false
rocket.producer = "airport"

rocket.transport_capacity = 0
rocket.can_transport = false

rocket.movement = 5
rocket.moveaction = true

rocket.cost = 10000


return rocket
