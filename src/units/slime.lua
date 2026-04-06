--- @module
local slime = {}

slime.type = "vehicle"
slime.target_type = "land"
slime.attack_types = {"land", "sea"}
slime.lp = 100
slime.hardness = 1

slime.att_soft = 80
slime.att_hard = 80
slime.att_air = 0
slime.range = 1
slime.direct_fire = true
slime.can_build = false
slime.producer = "factory"

slime.transport_capacity = 0
slime.can_transport = false

slime.movement = 5
slime.moveaction = true

slime.cost = 10000


return slime
