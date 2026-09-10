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

newRecipe{ id = "HEALING_SALVE",
	name = _t"Healing Salve", icon = "talents/healing_salve.png",
	desc = _t[[A powerful healing salve.
To be used with the medical injector implant.]],
	base_ml = 2, max_ml = 5,
	random_schematic = {level=1, rarity=50, cost=80},
	auto_hotkey_item = true,
	talents = {
		T_THERAPEUTICS = 2,
	},
	ingredients = {
		TROLL_INTESTINE = 1,
		HERBS = 4,
	},
}

newRecipe{ id = "PAIN_SUPPRESSOR_SALVE",
	name = _t"Pain Suppressor Salve", icon = "talents/pain_suppressor_salve.png",
	desc = _t[[A powerful salve that steels your body for a while, letting you survive below 0 life while increasing resistances.
To be used with the medical injector implant.]],
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=50, cost=50},
	auto_hotkey_item = true,
	talents = {
		T_THERAPEUTICS = 1,
	},
	ingredients = {
		SANDWORM_TOOTH = 2,
		HERBS = 3,
	},
}

newRecipe{ id = "FROST_SALVE",
	name = _t"Frost Salve", icon = "talents/frost_salve.png",
	desc = _t[[A powerful salve that can clean physical detrimental effects from your body and grant a frost aura (cold, darkness and nature affinity).
To be used with the medical injector implant.]],
	base_ml = 1, max_ml = 5,
	random_schematic = {level=5, rarity=50, cost=80},
	auto_hotkey_item = true,
	talents = {
		T_THERAPEUTICS = 2,
	},
	ingredients = {
		FROST_ANT_STINGER = 2,
		HERBS = 3,
	},
}

newRecipe{ id = "FIERY_SALVE",
	name = _t"Fiery Salve", icon = "talents/fiery_salve.png",
	desc = _t[[A powerful salve that can clean magical detrimental effects from your body and grant a fiery aura (fire, light and lightning affinity).
To be used with the medical injector implant.]],
	base_ml = 2, max_ml = 5,
	random_schematic = {level=10, rarity=50, cost=90},
	auto_hotkey_item = true,
	talents = {
		T_THERAPEUTICS = 3,
	},
	ingredients = {
		RITCH_STINGER = 2,
		HERBS = 3,
	},
}

newRecipe{ id = "WATER_SALVE",
	name = _t"Water Salve", icon = "talents/water_salve.png",
	desc = _t[[A powerful salve that can clean mental detrimental effects from your body and grant a water aura (blight, mind and acid affinity).
To be used with the medical injector implant.]],
	base_ml = 2, max_ml = 5,
	random_schematic = {level=15, rarity=50, cost=110},
	auto_hotkey_item = true,
	talents = {
		T_THERAPEUTICS = 3,
	},
	ingredients = {
		SQUID_INK = 1,
		HERBS = 3,
	},
}

newRecipe{ id = "UNSTOPPABLE_FORCE_SALVE",
	name = _t"Unstoppable Force Salve", icon = "talents/unstoppable_force_salve.png",
	desc = _t[[A powerful salve that makes you more resilient to physical, mental and magic effects and grants increased healing.
To be used with the medical injector implant.]],
	base_ml = 3, max_ml = 5,
	random_schematic = {level=25, rarity=50, cost=120},
	auto_hotkey_item = true,
	talents = {
		T_THERAPEUTICS = 5,
	},
	ingredients = {
		MINOTAUR_NOSE = 1,
		HERBS = 3,
	},
	items = {
		['TINKER_FROST_SALVE'] = _t"frost salve",
		['TINKER_FIERY_SALVE'] = _t"fiery salve",
		['TINKER_WATER_SALVE'] = _t"water salve",
	},
}

newRecipe{ id = "POISON_GROOVE",
	name = _t"Poison Groove", icon = "shockbolt/object/tinkers_poison_groove_t5.png",
	desc = _t"Poison grooves can be attached to weapons to apply a stacking poison on attacks.  While this is ideal for stacking simple damage, you can't help but wonder if you could inflict stronger effects with more knowledge..",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=20, rarity=50, cost=160},
	talents = {
		T_THERAPEUTICS = 3,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

newRecipe{ id = "VIRAL_INJECTOR",
	name = _t"Viral Injector", icon = "shockbolt/object/tinkers_viral_injector_t5.png",
	desc = _t"Viral grooves allow your weapons to apply an infectious agent on contact, dealing immediate blight damage and reducing their highest stat.  While this strain is effective it lacks the ability to spread or adapt to its hosts weaknesses.  Perhaps there are better methods to be found.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=30, rarity=50, cost=200},
	talents = {
		T_THERAPEUTICS = 3,
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

newRecipe{ id = "LIFE_SUPPORT",
	name = _t"Life Support Suit", icon = "shockbolt/object/artifact/life_support_suit.png",
	desc = _t"Apply your extensive therapeutics knowledge to try and defeat death itself!",
	base_ml = 5, max_ml = 5,
	unique = true,
	talents = {
		T_THERAPEUTICS = 5,
		T_CHEMISTRY = 4,
		T_EXPLOSIVES = 2,
	},
	ingredients = {
		LUMP_ORE = 5,
		HERBS = 20,
		PRIMAL_CORE = 1,
	},
	items = {
		TINKER_UNSTOPPABLE_FORCE_SALVE5 = _t"unstoppable force salve",
		GEM_FIRE_OPAL = _t"fire opal",
		GEM_PEARL = _t"pearl",
		GEM_DIAMOND = _t"diamond",
		GEM_BLOODSTONE = _t"bloodstone",
	},
}

newRecipe{ id = "SECOND_SKIN",
	name = _t"Second Skin", icon = "shockbolt/object/tinkers_second_skin_t5.png",
	desc = _t"Not only does it help seal wounds, protecting you from bleeding and enhancing your healing, it also protects from armour chafe!",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=50, cost=80},
	talents = {
		T_THERAPEUTICS = 2,
	},
	ingredients = {
		HERBS = 3,
	},
}

newRecipe{ id = "AIR_RECYCLER",
	name = _t"Air Recycler", icon = "shockbolt/object/tinkers_air_recycler_t5.png",
	desc = _t"Helps keep your airway open and lets you hold your breath longer.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=50, cost=80},
	talents = {
		T_THERAPEUTICS = 1,
		T_MECHANICAL = 1,
	},
	ingredients = {
		HERBS = 2,
		LUMP_ORE = 2,
	},
}

-- newRecipe{ id = "SMELLING_SALTS",
-- 	name = _t"Smelling Salts", icon = "shockbolt/object/tinkers_viral_injector_t5.png",
-- 	desc = _t"A pungent aroma to keep you alert.",
-- 	base_ml = 1, max_ml = 5,
-- 	random_schematic = {level=10, rarity=50, cost=80},
-- 	talents = {
-- 		T_THERAPEUTICS = 1,
-- 	},
-- 	ingredients = {
-- 		HERBS = 3,
-- 	},
-- }

newRecipe{ id = "MOSS_TREAD",
	name = _t"Moss Tread", icon = "shockbolt/object/tinkers_moss_tread_t5.png",
	desc = _t"Where you walk nature grows! Well moss. Sticky moss.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=50, cost=80},
	talents = {
		T_THERAPEUTICS = 2,
	},
	ingredients = {
		HERBS = 4,
	},
}

newRecipe{ id = "FUNGAL_WEB",
	name = _t"Fungal Web", icon = "shockbolt/object/tinkers_fungal_web_t5.png",
	desc = _t"This mesh of fungal threads absorbs nutrients for salves to provide you with added healing!",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=50, cost=80},
	talents = {
		T_THERAPEUTICS = 3,
	},
	ingredients = {
		HERBS = 5,
	},
}
