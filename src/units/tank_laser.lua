--- @module
local tank_laser = {}

tank_laser.type = "vehicle"
tank_laser.lp = 100
tank_laser.hardness = 1

tank_laser.att_soft = 80
tank_laser.att_hard = 80
tank_laser.att_air = 0
tank_laser.range = 1
tank_laser.direct_fire = true
tank_laser.can_build = false
tank_laser.producer = "factory"

tank_laser.movement = 5
tank_laser.moveaction = true

tank_laser.cost = 10000


return tank_laser
