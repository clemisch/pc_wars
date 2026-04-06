--- @module
local soldier_normal = {}

soldier_normal.type = "inf"
soldier_normal.target_type = "land"
soldier_normal.attack_types = {"land"}
soldier_normal.lp = 100
soldier_normal.hardness = 0

soldier_normal.att_soft = 46
soldier_normal.att_hard = 0
soldier_normal.att_air = 10
soldier_normal.range = 1
soldier_normal.direct_fire = true
soldier_normal.can_build = true
soldier_normal.producer = "factory"

soldier_normal.transport_capacity = 0
soldier_normal.can_transport = false

soldier_normal.movement = 3
soldier_normal.moveaction = true

soldier_normal.cost = 1000


return soldier_normal
