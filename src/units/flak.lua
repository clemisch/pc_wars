--- @module
local flak = {}

flak.type = "vehicle"
flak.target_type = "land"
flak.attack_types = {"air"}
flak.lp = 100
flak.hardness = 1

flak.att_soft = 80
flak.att_hard = 15
flak.att_air = 0
flak.range = 1
flak.direct_fire = true
flak.can_build = true
flak.producer = "factory"

flak.movement = 5
flak.moveaction = true

flak.cost = 10000


return flak
