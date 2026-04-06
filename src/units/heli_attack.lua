--- @module
local heli_attack = {}

heli_attack.type = "plane"
heli_attack.target_type = "air"
heli_attack.attack_types = {"land", "air"}
heli_attack.lp = 100
heli_attack.hardness = 1

heli_attack.att_soft = 60
heli_attack.att_hard = 55
heli_attack.att_air = 45
heli_attack.range = 1
heli_attack.direct_fire = true
heli_attack.can_build = true
heli_attack.producer = "airport"

heli_attack.transport_capacity = 0
heli_attack.can_transport = false

heli_attack.movement = 5
heli_attack.moveaction = true

heli_attack.cost = 10000


return heli_attack
