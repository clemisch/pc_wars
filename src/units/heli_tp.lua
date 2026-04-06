--- @module
local heli_tp = {}

heli_tp.type = "plane"
heli_tp.target_type = "air"
heli_tp.attack_types = {}
heli_tp.lp = 100
heli_tp.hardness = 1

heli_tp.att_soft = 0
heli_tp.att_hard = 0
heli_tp.att_air = 0
heli_tp.range = 1
heli_tp.direct_fire = true
heli_tp.can_build = true
heli_tp.producer = "airport"

heli_tp.transport_capacity = 1
heli_tp.can_transport = function(unit) return unit.type == "inf" end

heli_tp.movement = 5
heli_tp.moveaction = true

heli_tp.cost = 10000


return heli_tp
