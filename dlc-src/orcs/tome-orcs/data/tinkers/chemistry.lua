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

newRecipe{ id = "WINTERCHILL_EDGE",
	name = _t"Winterchill Edge", icon = "shockbolt/object/tinkers_winterchill_edge_t5.png",
	desc = _t"Heat is energy.  Using your knowledge of physics, chemistry, and blacksmithing you can add a chilling edge to your weapons.  While the damage this deals is relatively small each blow will also cause your enemies to lose one tenth of a turn.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=20, rarity=50, cost=150},
	talents = {
		T_CHEMISTRY = 3,
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

newRecipe{ id = "ACID_GROOVE",
	name = _t"Acid Groove", icon = "shockbolt/object/tinkers_acid_groove_t5.png",
	desc = _t"Allows your weapon to spray caustic acid on hit, reducing armor.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=50, cost=160},
	talents = {
		T_CHEMISTRY = 1,
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

newRecipe{ id = "BRAIN_CAP",
	name = _t"Brain Cap", icon = "shockbolt/object/tinkers_mind_cap_t5.png",
	desc = _t"By mounting a brain in a jar in a stralite frame this marvel will increases your mental resistances and allow you to emit a powerful magic disrupting wave.",
	base_ml = 4, max_ml = 4,
	random_schematic = {level=25, rarity=200, cost=120},
	unique = true,
	talents = {
		T_CHEMISTRY = 4,
		T_THERAPEUTICS = 4,
		T_EXPLOSIVES = 2,
	},
	ingredients = {
		LUMP_ORE = 8,
		BRAIN_JAR = 1,
	},
}

newRecipe{ id = "BRAIN_FLARE",
	name = _t"Brain Flare", icon = "shockbolt/object/tinkers_mind_flare_t5.png",
	desc = _t"By mounting a brain in a jar in a stralite frame this marvel will increases your mental resistances and to invade your foe's minds, taking control.",
	base_ml = 4, max_ml = 4,
	random_schematic = {level=25, rarity=200, cost=120},
	unique = true,
	talents = {
		T_CHEMISTRY = 4,
		T_THERAPEUTICS = 4,
		T_EXPLOSIVES = 2,
	},
	ingredients = {
		LUMP_ORE = 8,
		BRAIN_JAR = 1,
	},
}

newRecipe{ id = "WATERPROOF_COATING",
	name = _t"Waterproof Coating", icon = "shockbolt/object/tinkers_waterproof_coating_t5.png",
	desc = _t"Old cloak not keeping you as dry as it used to? A waterproof coating it just what you need!",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=50, cost=80},
	talents = {
		T_CHEMISTRY = 1,
	},
	ingredients = {
		HERBS = 2,
	},
}

newRecipe{ id = "FIREPROOF_COATING",
	name = _t"Fireproof Coating", icon = "shockbolt/object/tinkers_fireproof_coating_t5.png",
	desc = _t"New cloak doesn't have all the resistances you wanted? A fireproof coating it just what you need!",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=75, cost=120},
	talents = {
		T_CHEMISTRY = 2,
	},
	ingredients = {
		HERBS = 2,
	},
}

newRecipe{ id = "FLASH_POWDER",
	name = _t"Flash Powder", icon = "shockbolt/object/tinkers_flash_powder_t5.png",
	desc = _t"What is better than throwing sand in someone's face? Throwing sand that shines as bright as the Sun!",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=8, rarity=50, cost=120},
	talents = {
		T_CHEMISTRY = 1,
	},
	ingredients = {
		LUMP_ORE = 2,
		HERBS = 1,
	},
}

newRecipe{ id = "ITCHING_POWDER",
	name = _t"Itching Powder", icon = "shockbolt/object/tinkers_itching_powder_t5.png",
	desc = _t"The 'Crawling Ants' itching powder will distract your enemies from any complicated actions.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=75, cost=120},
	talents = {
		T_CHEMISTRY = 2,
	},
	ingredients = {
		LUMP_ORE = 1,
		HERBS = 2,
	},
}

newRecipe{ id = "ROGUE_GALLERY",
	name = _t"Rogue's Gallery", icon = "shockbolt/object/artifact/rogues_gallery.png",
	desc = _t"Lined with reactive mechanisms, this cloak is equipped for any situation you might possibly encounter, and several you couldn't possibly encounter!",
	base_ml = 5, max_ml = 5,
	unique = true,
	talents = {
		T_THERAPEUTICS = 2,
		T_CHEMISTRY = 5,
		T_EXPLOSIVES = 4,
	},
	ingredients = {
		LUMP_ORE = 5,
		HERBS = 20,
		PRIMAL_CORE = 1,
	},
	items = {
		TINKER_FLASH_POWDER5 = _t"flash powder",
		GEM_FIRE_OPAL = _t"fire opal",
		GEM_PEARL = _t"pearl",
		GEM_DIAMOND = _t"diamond",
		GEM_BLOODSTONE = _t"bloodstone",
	},
}

newRecipe{ id = "RUSTPROOF_COATING",
	name = _t"Rustproof Coating", icon = "shockbolt/object/tinkers_rustproof_coating_t5.png",
	desc = _t"Protects your armour from nasty corrosives like swamp, sea spray, acids, orc sweat, drake saliva...",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=75, cost=120},
	talents = {
		T_CHEMISTRY = 2,
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 1,
		HERBS = 2,
	},
}

newRecipe{ id = "ALCHEMISTS_HELPER",
	name = _t"Alchemist's Helper", icon = "shockbolt/object/tinkers_alchemists_helper_t5.png",
	desc = _t"An ingenius collection of tough no-spill pockets allows you to keep all those dangerous reagents close at hand. (increases acid, fire, nature and blight damage.)",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=75, cost=120},
	talents = {
		T_CHEMISTRY = 3,
		T_THERAPEUTICS = 1,
	},
	ingredients = {
		HERBS = 4,
	},
}

newRecipe{ id = "BLACK_LIGHT_EMITTER",
	name = _t"Black Light Emitter", icon = "shockbolt/object/tinkers_black_light_emitter_t5.png",
	desc = _t"Make the invisible visible.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=20, rarity=100, cost=160},
	talents = {
		T_CHEMISTRY = 2,
		T_ELECTRICITY = 1,
	},
	ingredients = {
		LUMP_ORE = 2,
		HERBS = 2,
	},
}
