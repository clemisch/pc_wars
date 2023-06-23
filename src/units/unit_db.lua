--- @module
local unit_db = {}

-- infantry
unit_db.soldier_normal = require("src.units.soldier_normal")
unit_db.soldier_mech   = require("src.units.soldier_mech")

-- tanks
unit_db.soldier_tp       = require("src.units.soldier_tp")
unit_db.slime            = require("src.units.slime")
unit_db.tank_light       = require("src.units.tank_light")
unit_db.tank_medium      = require("src.units.tank_medium")
unit_db.tank_heavy       = require("src.units.tank_heavy")
unit_db.tank_ultra       = require("src.units.tank_ultra")
unit_db.tank_laser       = require("src.units.tank_laser")
unit_db.artillery        = require("src.units.artillery")
unit_db.artillery_rocket = require("src.units.artillery_rocket")
unit_db.bomb             = require("src.units.bomb")
unit_db.flak_rocket      = require("src.units.flak_rocket")
unit_db.flak             = require("src.units.flak")

-- planes
unit_db.heli_tp       = require("src.units.heli_tp")
unit_db.heli_attack   = require("src.units.heli_attack")
unit_db.plane_fighter = require("src.units.plane_fighter")
unit_db.plane_bomber  = require("src.units.plane_bomber")
unit_db.plane_stealth = require("src.units.plane_stealth")
unit_db.rocket        = require("src.units.rocket")

-- ships
unit_db.ship_robot     = require("src.units.ship_robot")
unit_db.ship_tp        = require("src.units.ship_tp")
unit_db.ship_destroyer = require("src.units.ship_destroyer")
unit_db.ship_submarine = require("src.units.ship_submarine")
unit_db.ship_battle    = require("src.units.ship_battle")
unit_db.ship_carrier   = require("src.units.ship_carrier")




return unit_db
