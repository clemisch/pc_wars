--- @module
local bomb = {}

bomb.type = "vehicle"
bomb.target_type = "land"
bomb.attack_types = {"land", "sea"}
bomb.lp = 100
bomb.hardness = 0

bomb.att_soft = 100
bomb.att_hard = 100
bomb.att_air = 0
bomb.range = 1
bomb.direct_fire = true
bomb.can_build = false
bomb.producer = "factory"

bomb.transport_capacity = 0
bomb.can_transport = false

bomb.movement = 5
bomb.moveaction = true

bomb.cost = 30000


return bomb
