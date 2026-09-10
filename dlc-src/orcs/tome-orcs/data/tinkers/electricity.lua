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

newRecipe{ id = "LIGHTNING_COIL",
	name = _t"Lightning Coil", icon = "shockbolt/object/tinkers_lightning_coil_t5.png",
	desc = _t"Lightning coils can be attached to melee weapons to generate a short range beam of electricity on melee crits.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=20, rarity=50, cost=80},
	talents = {
		T_ELECTRICITY = 3,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

newRecipe{ id = "MANA_COIL",
	name = _t"Mana Coil", icon = "shockbolt/object/tinkers_mana_coil_t5.png",
	desc = _t"Mana coils can be attached to staves to improve mana regeneration and cast a lightning spell on spell hits.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=15, rarity=70, cost=110},
	talents = {
		T_ELECTRICITY = 2,
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 5,
	},
	items = {
		GEM_SAPPHIRE = _t"sapphire",
	},
}

newRecipe{ id = "ARCANE_DYNAMO",
	name = _t"Arcane Dynamo", icon = "shockbolt/object/tinkers_mana_coil_t5.png",
	desc = _t"Arcane Dynamos build a bridge between arcane forces and steamtech, regenerating steam supplies when casting spells and allowing the use of Technomancy.",
	base_ml = 1, max_ml = 5,
	-- random_schematic = {level=15, rarity=70, cost=110}, -- Not randomly learnt
	talents = {
		T_ELECTRICITY = 2,
		T_MECHANICAL = 2,
	},
	ingredients = {
		LUMP_ORE = 7,
	},
	items = {
		GEM_AMETHYST = _t"amethyst",
	},
}

newRecipe{ id = "SHOCKING_TOUCH",
	name = _t"Shocking Touch", icon = "shockbolt/object/tinkers_shocking_touch_t5.png",
	desc = _t"Gives you the Electric Touch. Higher tiers will chain.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=18, rarity=50, cost=150},
	talents = {
		T_ELECTRICITY = 3,
	},
	ingredients = {
		LUMP_ORE = 2,
	},
}

newRecipe{ id = "DEFLECTION_FIELD",
	name = _t"Deflection Field", icon = "shockbolt/object/tinkers_deflection_field_t5.png",
	desc = _t"Protect yourself with the Power of Magnetism! Attach this device to your belt and watch those bullets miss every time! (not guaranteed to work every time)",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=50, cost=80},
	talents = {
		T_ELECTRICITY = 2,
	},
	ingredients = {
		LUMP_ORE = 2,
	},
}

newRecipe{ id = "GALVANIC_RETRIBUTOR",
	name = _t"Galvanic Retributor", icon = "shockbolt/object/tinkers_galvanic_retribution_t5.png",
	desc = _t"Fortify your shield with electricity and prepare to unleash GALVANIC RETRIBUTION against your attackers!",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=30, rarity=100, cost=160},
	talents = {
		T_ELECTRICITY = 4,
	},
	ingredients = {
		LUMP_ORE = 4,
	},
}

-- newRecipe{ id = "GAUSS_ACCELERATOR",
-- 	name = _t"Gauss Accelerator", icon = "shockbolt/object/tinkers_lightning_coil_t5.png",
-- 	desc = _t"Use the amazing Power of Electricity to give your Steamgun some extra punch!",
-- 	base_ml = 1, max_ml = 5,
-- 	random_schematic = {level=1, rarity=100, cost=160},
-- 	talents = {
-- 		T_ELECTRICITY = 2,
-- 	},
-- 	ingredients = {
-- 		LUMP_ORE = 2,
-- 	},
-- }

newRecipe{ id = "SHOCKING_EDGE",
	name = _t"Shocking Edge", icon = "shockbolt/object/tinkers_shocking_edge_t5.png",
	desc = _t"Attaching a capacitor to your weapon in just the right way is a great way to shock your enemies.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=100, cost=160},
	talents = {
		T_ELECTRICITY = 2,
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

newRecipe{ id = "SAW_STORM",
	name = _t"Steamsaw: Stormcutter", icon = "shockbolt/object/artifact/stormcutter.png",
	desc = _t"The pinnacle of steamsaws technology. Every one of your hits will unleash the power of the storm onto your foes, chaining between them and stunning them!",
	base_ml = 5, max_ml = 5,
	unique = true,
	talents = {
		T_SMITH = 4,
		T_ELECTRICITY = 5,
		T_MECHANICAL = 3,
	},
	ingredients = {
		LUMP_ORE = 40,
		MECHANICAL_CORE = 1,
	},
	items = {
		TINKER_SHOCKING_EDGE5 = _t"shocking edge",
		GEM_FIRE_OPAL = _t"fire opal",
		GEM_PEARL = _t"pearl",
		GEM_DIAMOND = _t"diamond",
		GEM_BLOODSTONE = _t"bloodstone",
	},
}

newRecipe{ id = "VOLTAIC_SENTRY",
	name = _t"Voltaic Sentry", icon = "shockbolt/object/tinkers_voltaic_sentry_t5.png",
	desc = _t"Just drop it down and watch the sparks fly when your enemies get near.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=20, rarity=100, cost=160},
	talents = {
		T_ELECTRICITY = 4,
		T_MECHANICAL = 1,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

newRecipe{ id = "MENTAL_STIMULATOR",
	name = _t"Mental Stimulator", icon = "shockbolt/object/tinkers_mental_stimulator_t5.png",
	desc = _t"Supercharge your thinking and give your brain a boost with the Mental Stimulator!",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=50, cost=80},
	talents = {
		T_ELECTRICITY = 1,
	},
	ingredients = {
		LUMP_ORE = 2,
	},
}

newRecipe{ id = "POWER_DISTRIBUTOR",
	name = _t"Power Distributor", icon = "shockbolt/object/tinkers_power_distributor_t5.png",
	desc = _t"The Power Distributor V2 ensures you have the energy where and when you need it, without any of the side effects like V1 had.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=20, rarity=100, cost=160},
	talents = {
		T_ELECTRICITY = 2,
		T_THERAPEUTICS = 1,
	},
	ingredients = {
		LUMP_ORE = 2,
		HERBS = 2,
	},
}

newRecipe{ id = "WHITE_LIGHT_EMITTER",
	name = _t"White Light Emitter", icon = "shockbolt/object/tinkers_white_light_emitter_t5.png",
	desc = _t"Add more light to your light!",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=20, rarity=100, cost=160},
	talents = {
		T_ELECTRICITY = 2,
		T_CHEMISTRY = 1,
	},
	ingredients = {
		LUMP_ORE = 3,
		HERBS = 1,
	},
}
