--- @module
local ship_robot = {}

ship_robot.type = "ship"
ship_robot.target_type = "sea"
ship_robot.attack_types = {}
ship_robot.lp = 100
ship_robot.hardness = 1

ship_robot.att_soft = 0
ship_robot.att_hard = 0
ship_robot.att_air = 0
ship_robot.range = 1
ship_robot.direct_fire = true
ship_robot.can_build = false
ship_robot.producer = "seaport"

ship_robot.transport_capacity = 0
ship_robot.can_transport = false

ship_robot.movement = 5
ship_robot.moveaction = true

ship_robot.cost = 10000


return ship_robot
