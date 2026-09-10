-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2019 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org
local DamageType = require "engine.DamageType"

newRecipe{ id = "ROCKET_BOOTS",
	name = _t"Rocket Boots", icon = "shockbolt/object/tinkers_rocket_boots_t5.png",
	desc = _t"Attach small steam rocket to your boots, granting faster movement and leaving a trail of fire to burn those foolish enough to follow you.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=5, rarity=50, cost=100},
	talents = {
		T_MECHANICAL = 2,
	},
	ingredients = {
		LUMP_ORE = 5,
	},
}

newRecipe{ id = "HAND_CANNON",
	name = _t"Hand Cannon", icon = "shockbolt/object/tinkers_hand_cannon_t5.png",
	desc = _t"Allows you to fire your equipped shot or arrow ammo via your gloves.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=35, rarity=50, cost=200},
	talents = {
		T_MECHANICAL = 4,
		T_EXPLOSIVES = 2,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

-- newRecipe{ id = "WEAPON_AUTOMATON_1H",
-- 	name = _t"Weapon Automaton: One Handed", icon = "shockbolt/object/tinkers_weapon_automaton_t5.png",
-- 	desc = _t"Creates an automated version of a 1H weapon that will fight for you temporarily.  Once the automaton runs out of the power the weapon will drop to the ground.",
-- 	base_ml = 1, max_ml = 5,
-- 	random_schematic = {level=40, rarity=80, cost=300},
-- 	talents = {
-- 		T_MECHANICAL = 4,
-- 		T_ELECTRICITY = 2,
-- 		T_SMITH = 2,
-- 	},
-- 	ingredients = {
-- 		LUMP_ORE = 3,
-- 	},
-- }

newRecipe{ id = "FATAL_ATTRACTOR",
	name = _t"Fatal Attractor", icon = "shockbolt/object/tinkers_fatal_attractor_t5.png",
	desc = _t"Creates a small psionic device that will taunt nearby enemies and reflect damage received.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=110, cost=150},
	talents = {
		T_MECHANICAL = 2,
		T_ELECTRICITY = 1, 
		T_SMITH = 2,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

newRecipe{ id = "IRON_GRIP",
	name = _t"Iron Grip", icon = "shockbolt/object/tinkers_iron_grip_t5.png",
	desc = _t"Attach powerful steam-powered pistons to your gloves, giving you a tight grip on your weapon (preventing disarming) and allowing you to crush a foe, pinning it and reducing its defense and armour.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=50, cost=80},
	talents = {
		T_MECHANICAL = 1,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

newRecipe{ id = "SPRING_GRAPPLE",
	name = _t"Spring Grapple", icon = "shockbolt/object/tinkers_spring_grapple_t5.png",
	desc = _t"Attach a spring loaded mechanism to your gloves, allowing you to drag enemies into melee range and deliver a quick blow, pinning them in front of you.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=5, rarity=50, cost=80},
	talents = {
		T_MECHANICAL = 1,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

newRecipe{ id = "POWER_ARMOUR",
	name = _t"Steam Powered Armour", icon = "shockbolt/object/artifact/voratun_power_armour.png",
	desc = _t"Using small steam engines and the miracles of the latest automation discoveries you are able to create a Steam Powered Armour. A full plate armour that helps your movement and has intrinsic protection mechanisms.",
	base_ml = 5, max_ml = 5,
	unique = true,
	talents = {
		T_SMITH = 4,
		T_ELECTRICITY = 5,
		T_MECHANICAL = 5,
	},
	ingredients = {
		LUMP_ORE = 50,
		MECHANICAL_CORE = 2,
	},
	items = {
		TINKER_LIGHTNING_COIL5 = _t"lightning coil",
		GEM_FIRE_OPAL = _t"fire opal",
		GEM_PEARL = _t"pearl",
		GEM_DIAMOND = _t"diamond",
		GEM_BLOODSTONE = _t"bloodstone",
	},
}

newRecipe{ id = "SAW_PROJECTOR",
	name = _t"Saw Projector", icon = "shockbolt/object/tinkers_saw_projector_t5.png",
	desc = _t"A mechanical device for launching a spinning buzzsaw! What else could you want?",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=5, rarity=50, cost=80},
	talents = {
		T_MECHANICAL = 1,
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

newRecipe{ id = "KINETIC_STABILISER",
	name = _t"Kinetic Stabiliser", icon = "shockbolt/object/tinkers_kinetic_stabiliser_t5.png",
	desc = _t"Helps keep your feet on the ground, but still allows mobility.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=5, rarity=50, cost=80},
	talents = {
		T_MECHANICAL = 2,
	},
	ingredients = {
		LUMP_ORE = 4,
	},
}
