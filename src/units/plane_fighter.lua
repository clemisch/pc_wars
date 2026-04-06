--- @module
local plane_fighter = {}

plane_fighter.type = "plane"
plane_fighter.target_type = "air"
plane_fighter.attack_types = {"air"}
plane_fighter.lp = 100
plane_fighter.hardness = 1

plane_fighter.att_soft = 0
plane_fighter.att_hard = 0
plane_fighter.att_air = 100
plane_fighter.range = 1
plane_fighter.direct_fire = true
plane_fighter.can_build = true
plane_fighter.producer = "airport"

plane_fighter.movement = 5
plane_fighter.moveaction = true

plane_fighter.cost = 10000


return plane_fighter
