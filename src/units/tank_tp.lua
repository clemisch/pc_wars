--- @module
local tank_tp = {}

tank_tp.type = "vehicle"
tank_tp.target_type = "land"
tank_tp.attack_types = {}
tank_tp.lp = 100
tank_tp.hardness = 1

tank_tp.att_soft = 0
tank_tp.att_hard = 0
tank_tp.att_air = 0
tank_tp.range = 1
tank_tp.direct_fire = true
tank_tp.can_build = true
tank_tp.producer = "factory"

tank_tp.transport_capacity = 1
tank_tp.can_transport = function(unit) return unit.type == "inf" end

tank_tp.movement = 6
tank_tp.moveaction = true

tank_tp.cost = 3000


return tank_tp
