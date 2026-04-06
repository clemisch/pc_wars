--- @module
local flak_rocket = {}

flak_rocket.type = "vehicle"
flak_rocket.target_type = "land"
flak_rocket.attack_types = {"air"}
flak_rocket.lp = 100
flak_rocket.hardness = 1

flak_rocket.att_soft = 80
flak_rocket.att_hard = 15
flak_rocket.att_air = 0
flak_rocket.range = 3
flak_rocket.direct_fire = true
flak_rocket.can_build = true
flak_rocket.producer = "factory"

flak_rocket.movement = 5
flak_rocket.moveaction = false

flak_rocket.cost = 10000


return flak_rocket
