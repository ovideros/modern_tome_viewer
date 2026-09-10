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

newRecipe{ id = "THUNDERCLAP_COATING",
	name = _t"Thunderclap Coating", icon = "shockbolt/object/tinkers_thunderclap_coating_t5.png",
	desc = _t"Coat your weapon in a substance that will react destructively on impact, causing your attacks to burst out in an area.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=50, cost=80},
	talents = {
		T_EXPLOSIVES = 1,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}


newRecipe{ id = "STEAMGUN",
	name = _t"Steamgun", icon = "shockbolt/object/steamgun_voratun.png",
	desc = _t"Dismantle any one sling, add some amazing steampower to it and make a powerful steamgun to fire a bullet hell at your foes!",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=30, cost=80},
	talents = {
		T_EXPLOSIVES = 1,
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 7,
	},
	fake_slot = "WEAPON",
	special = {
		{desc=_t"a sling (not unique)", cond=function(tdef, party, actor)
			local found = false
			actor:inventoryApply(actor:getInven(actor.INVEN_INVEN), function(inven, item, o) if tdef.object_filter(o) then found = true end end)
			return found
		end},
	},
	object_filter = function(o)
		if o.type == "weapon" and o.subtype == "sling" and
		   not o.quest and not o.special and (not o.unique or o.randart) and o.combat then
			return true
		end
	end,
	create = function(tdef, party, actor, ml, silent, onend)
		actor:showEquipInven(_t"Convert which sling?", tdef.object_filter, function(o, inven, item)
			if not o then return end
			local gun = game.zone:makeEntity(game.level, "object", {define_as="STEAMGUN_BASE"..ml, ignore_material_restriction=true, base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", ego_chance=-1000}, nil, true)
			print("STEAMGUN_BASE"..ml, gun)
			if not gun then return end
			local basename = gun.name

			actor:removeObject(inven, item, true)

			if o.ego_list then game.zone:setEntityEgoList(gun, o.ego_list) end
			gun:resolve()
			gun:resolve(nil, true)
			gun:identify(true)

			if o.randart or o.rare then
				gun.randart = o.randart
				gun.rare = o.rare
				if o.namescheme and o.unided_namescheme then
					gun.unided_name = o.unided_namescheme:tformat(gun.unided_name or basename)
					gun.name = o.namescheme:tformat(_t(basename))
					if o.randart then gun.unique = o.namescheme:format(basename) end
				end
				gun.no_unique_lore = true
			end

			actor:addObject(inven, gun)
			game.zone:addEntity(game.level, o, "object")
			actor:sortInven()
			game.log("Converted %s into %s", o:getName{do_color=true}, gun:getName{do_color=true})

			onend(true)
			return true
		end)
	end,
}

newRecipe{ id = "HEADLAMP",
	name = _t"Headlamp", icon = "shockbolt/object/tinkers_headlamp_t5.png",
	desc = _t"So much more convenient than a lantern on your waist.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=50, cost=80},
	talents = {
		T_EXPLOSIVES = 1,
	},
	ingredients = {
		LUMP_ORE = 1,
		HERBS = 1,
	},
}

newRecipe{ id = "ABLATIVE_ARMOUR",
	name = _t"Ablative Armour", icon = "shockbolt/object/tinkers_ablative_armour_t5.png",
	desc = _t"Reinforcing your armour with explosions isn't as crazy as it sounds!  Adds armor and resists very large hits.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=20, rarity=100, cost=160},
	talents = {
		T_EXPLOSIVES = 2,
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 2,
		HERBS = 2,
	},
}

newRecipe{ id = "INCENDIARY_GROOVE",
	name = _t"Incendiary Groove", icon = "shockbolt/object/tinkers_incendiary_groove_t5.png",
	desc = _t"A special reservoir seeps liquid fire onto the weapon, adding fire damage and setting the ground on fire when you hit.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=30, rarity=100, cost=180},
	talents = {
		T_EXPLOSIVES = 4,
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 2,
		HERBS = 2,
	},
}

newRecipe{ id = "THUNDER_GRENADE",
	name = _t"Thunder Grenade", icon = "shockbolt/object/tinkers_thunder_grenade_t5.png",
	desc = _t"Small radius, but stuns quite well.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=15, rarity=75, cost=120},
	talents = {
		T_EXPLOSIVES = 3,
	},
	ingredients = {
		LUMP_ORE = 2,
		HERBS = 1,
	},
}

newRecipe{ id = "GUN_PAYLOAD",
	name = _t"Steamgun: Payload", icon = "shockbolt/object/artifact/payload.png",
	desc = _t"The pinnacle of steamguns technology. Critical strikes with this gun will feel like a massive explosion of flames! And it actually will be one!",
	base_ml = 5, max_ml = 5,
	unique = true,
	talents = {
		T_SMITH = 3,
		T_EXPLOSIVES = 5,
		T_MECHANICAL = 2,
	},
	ingredients = {
		LUMP_ORE = 40,
		MECHANICAL_CORE = 1,
	},
	items = {
		TINKER_INCENDIARY_GROOVE5 = _t"incendiary groove",
		GEM_FIRE_OPAL = _t"fire opal",
		GEM_PEARL = _t"pearl",
		GEM_DIAMOND = _t"diamond",
		GEM_BLOODSTONE = _t"bloodstone",
	},
}

newRecipe{ id = "EXPLOSIVE_SHELL",
	name = _t"Explosive Shell", icon = "shockbolt/object/tinkers_explosive_shell_t5.png",
	desc = _t"A special shot that explodes on impact.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=50, cost=80},
	talents = {
		T_EXPLOSIVES = 1,
	},
	ingredients = {
		LUMP_ORE = 1,
		HERBS = 1,
	},
}

newRecipe{ id = "FLARE_SHELL",
	name = _t"Flare Shell", icon = "shockbolt/object/tinkers_flare_shell_t5.png",
	desc = _t"A special shot that releases intense light on impact.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=15, rarity=75, cost=120},
	talents = {
		T_EXPLOSIVES = 3,
	},
	ingredients = {
		LUMP_ORE = 1,
		HERBS = 2,
	},
}

-- newRecipe{ id = "INCENDIARY_SHELL",
-- 	name = _t"Incendiary Shell", icon = "shockbolt/object/tinkers_winterchill_edge_t5.png",
-- 	desc = _t"A special shot that erupts in flames of destruction on impact!",
-- 	base_ml = 1, max_ml = 5,
-- 	random_schematic = {level=30, rarity=100, cost=180},
-- 	talents = {
-- 		T_EXPLOSIVES = 4,
-- 	},
-- 	ingredients = {
-- 		LUMP_ORE = 2,
-- 		HERBS = 2,
-- 	},
-- }

newRecipe{ id = "SOLID_SHELL",
	name = _t"Solid Shell", icon = "shockbolt/object/tinkers_solid_shell_t5.png",
	desc = _t"A special shot that packs a punch.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=25, rarity=70, cost=170},
	talents = {
		T_EXPLOSIVES = 3,
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 2,
		HERBS = 1,
	},
}

newRecipe{ id = "SAW_SHELL",
	name = _t"Saw Shell", icon = "shockbolt/object/tinkers_saw_shell_t5.png",
	desc = _t"A special shot that slices 'n' dices.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=50, cost=80},
	talents = {
		T_EXPLOSIVES = 1,
		T_MECHANICAL = 1,
	},
	ingredients = {
		LUMP_ORE = 2,
		HERBS = 1,
	},
}

newRecipe{ id = "MAGNETIC_SHELL",
	name = _t"Magnetic Shell", icon = "shockbolt/object/tinkers_magnetic_shell_t5.png",
	desc = _t"A special shot that magnetises on impact.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=50, cost=80},
	talents = {
		T_EXPLOSIVES = 1,
		T_ELECTRICITY = 1,
	},
	ingredients = {
		LUMP_ORE = 2,
		HERBS = 1,
	},
}

newRecipe{ id = "ANTIMAGIC_SHELL",
	name = _t"Antimagic Shell", icon = "shockbolt/object/tinkers_antimagic_shell_t5.png",
	desc = _t"A special shot filled with antimagic sap.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=50, cost=80},
	talents = {
		T_EXPLOSIVES = 2,
		T_THERAPEUTICS = 1,
	},
	ingredients = {
		LUMP_ORE = 1,
		HERBS = 2,
	},
}

newRecipe{ id = "CORROSIVE_SHELL",
	name = _t"Corrosive Shell", icon = "shockbolt/object/tinkers_corrosive_shell_t5.png",
	desc = _t"A special shot that releases acid on impact.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=50, cost=80},
	talents = {
		T_EXPLOSIVES = 2,
		T_CHEMISTRY = 1,
	},
	ingredients = {
		LUMP_ORE = 1,
		HERBS = 2,
	},
}

-- newRecipe{ id = "IMPALER_SHELL",
-- 	name = _t"Impaler Shell", icon = "shockbolt/object/tinkers_thunderclap_coating_t5.png",
-- 	desc = _t"A special shot that nails the target to the wall.",
-- 	base_ml = 1, max_ml = 5,
-- 	random_schematic = {level=12, rarity=100, cost=160},
-- 	talents = {
-- 		T_EXPLOSIVES = 2,
-- 		T_SMITH = 2,
-- 	},
-- 	ingredients = {
-- 		LUMP_ORE = 3,
-- 		HERBS = 1,
-- 	},
-- }

newRecipe{ id = "HOOK_SHELL",
	name = _t"Hook Shell", icon = "shockbolt/object/tinkers_hook_shell_t5.png",
	desc = _t"A special shot moving yourself, or others quickly.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=12, rarity=100, cost=160},
	talents = {
		T_EXPLOSIVES = 2,
		T_MECHANICAL = 2,
	},
	ingredients = {
		LUMP_ORE = 3,
		HERBS = 1,
	},
}

newRecipe{ id = "VOLTAIC_SHELL",
	name = _t"Voltaic Shell", icon = "shockbolt/object/tinkers_voltaic_shell_t5.png",
	desc = _t"A special shot that releases electricity on impact.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=12, rarity=100, cost=160},
	talents = {
		T_EXPLOSIVES = 2,
		T_ELECTRICITY = 2,
	},
	ingredients = {
		LUMP_ORE = 3,
		HERBS = 1,
	},
}

newRecipe{ id = "BOTANICAL_SHELL",
	name = _t"Botanical Shell", icon = "shockbolt/object/tinkers_botanical_shell_t5.png",
	desc = _t"A special shot grows moss on impact.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=22, rarity=100, cost=160},
	talents = {
		T_EXPLOSIVES = 3,
		T_THERAPEUTICS = 2,
	},
	ingredients = {
		LUMP_ORE = 1,
		HERBS = 3,
	},
}

newRecipe{ id = "TOXIC_SHELL",
	name = _t"Toxic Shell", icon = "shockbolt/object/tinkers_toxic_shell_t5.png",
	desc = _t"A special shot that contains a deadly toxin.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=30, rarity=100, cost=220},
	talents = {
		T_EXPLOSIVES = 4,
		T_CHEMISTRY = 2,
	},
	ingredients = {
		LUMP_ORE = 1,
		HERBS = 3,
	},
}
