--- @module
local plane_stealth = {}

plane_stealth.type = "plane"
plane_stealth.target_type = "air"
plane_stealth.attack_types = {"land", "sea", "air"}
plane_stealth.lp = 100
plane_stealth.hardness = 1

plane_stealth.att_soft = 80
plane_stealth.att_hard = 80
plane_stealth.att_air = 0
plane_stealth.range = 1
plane_stealth.direct_fire = true
plane_stealth.can_build = false
plane_stealth.producer = "airport"

plane_stealth.movement = 5
plane_stealth.moveaction = true

plane_stealth.cost = 10000


return plane_stealth
