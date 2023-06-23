--- @module
local unit_db = {}

-- infantry
unit_db.soldier_normal = require("units.soldier_normal")
unit_db.soldier_mech   = require("units.soldier_mech")

-- tanks
unit_db.soldier_tp       = require("units.soldier_tp")
unit_db.slime            = require("units.slime")
unit_db.tank_light       = require("units.tank_light")
unit_db.tank_medium      = require("units.tank_medium")
unit_db.tank_heavy       = require("units.tank_heavy")
unit_db.tank_ultra       = require("units.tank_ultra")
unit_db.tank_laser       = require("units.tank_laser")
unit_db.artillery        = require("units.artillery")
unit_db.artillery_rocket = require("units.artillery_rocket")
unit_db.bomb             = require("units.bomb")
unit_db.flak_rocket      = require("units.flak_rocket")
unit_db.flak             = require("units.flak")

-- planes
unit_db.heli_tp       = require("units.heli_tp")
unit_db.heli_attack   = require("units.heli_attack")
unit_db.plane_fighter = require("units.plane_fighter")
unit_db.plane_bomber  = require("units.plane_bomber")
unit_db.plane_stealth = require("units.plane_stealth")
unit_db.rocket        = require("units.rocket")

-- ships
unit_db.ship_robot     = require("units.ship_robot")
unit_db.ship_tp        = require("units.ship_tp")
unit_db.ship_destroyer = require("units.ship_destroyer")
unit_db.ship_submarine = require("units.ship_submarine")
unit_db.ship_battle    = require("units.ship_battle")
unit_db.ship_carrier   = require("units.ship_carrier")




return unit_db
