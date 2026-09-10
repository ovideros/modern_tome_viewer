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

newRecipe{ id = "STEAMSAW",
	name = _t"Steamsaw", icon = "shockbolt/object/steamsaw_voratun.png",
	desc = _t"Dismantle any one handed sword/axe/mace, add some amazing steampower to it and make a powerful steamsaw to shred your foes to pieces!",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=30, cost=80},
	talents = {
		T_SMITH = 2,
		T_MECHANICAL = 1,
	},
	ingredients = {
		LUMP_ORE = 7,
	},
	fake_slot = "WEAPON",
	special = {
		{desc=_t"a one handed sword/axe/mace (not unique, without a special damage type)", cond=function(tdef, party, actor)
			local found = false
			actor:inventoryApply(actor:getInven(actor.INVEN_INVEN), function(inven, item, o) if tdef.object_filter(o) then found = true end end)
			return found
		end},
	},
	object_filter = function(o)
		if o.type == "weapon" and (o.subtype == "longsword" or o.subtype == "waraxe" or o.subtype == "mace") and
		   not o.quest and not o.special and (not o.unique or o.randart) and o.combat and (not o.combat.damtype or o.combat.damtype == DamageType.PHYSICAL) then
			return true
		end
	end,
	create = function(tdef, party, actor, ml, silent, onend)
		actor:showEquipInven(_t"Convert which weapon?", tdef.object_filter, function(o, inven, item)
			if not o then return end
			local saw = game.zone:makeEntity(game.level, "object", {define_as="STEAMSAW_BASE"..ml, ignore_material_restriction=true, base_list="mod.class.Object:/data-orcs/general/objects/steamsaw.lua", ego_chance=-1000}, nil, true)
			if not saw then return end
			local basename = saw.name

			actor:removeObject(inven, item, true)

			if o.ego_list then game.zone:setEntityEgoList(saw, o.ego_list) end
			saw:resolve()
			saw:resolve(nil, true)
			saw:identify(true)

			if o.randart or o.rare then
				saw.randart = o.randart
				saw.rare = o.rare
				if o.namescheme and o.unided_namescheme then
					saw.unided_name = o.unided_namescheme:tformat(saw.unided_name or basename)
					saw.name = o.namescheme:tformat(_t(basename))
					if o.randart then saw.unique = o.namescheme:format(basename) end
				end
				saw.no_unique_lore = true
			end

			actor:addObject(inven, saw)
			game.zone:addEntity(game.level, o, "object")
			actor:sortInven()
			game.log("Converted %s into %s", o:getName{do_color=true}, saw:getName{do_color=true})

			onend(true)
			return true
		end)
	end,
}

newRecipe{ id = "FOCUS_LEN",
	name = _t"Focus Lens", icon = "shockbolt/object/tinkers_focus_len_t5.png",
	desc = _t"A simple contraption consisting of a gem and some metal to enhance your sight, detection and infravision! At tier 4 it even allows you to fight while blinded. #{italic}#Amazing!#{normal}#",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=40, cost=80},
	talents = {
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 2,
	},
	items = {
		[function(ml) return ({"GEM_CITRINE","GEM_AQUAMARINE","GEM_QUARTZ","GEM_RUBY","GEM_DIAMOND"})[util.bound(ml, 1, 5)] end] = function(ml) return ({_t"citrine",_t"aquamarine",_t"quartz",_t"ruby",_t"diamond"})[util.bound(ml, 1, 5)] end
	},
}

newRecipe{ id = "TOXIC_CANNISTER_LAUNCHER",
	name = _t"Toxic Cannister Launcher", icon = "shockbolt/object/tinkers_toxic_cannister_launcher_t5.png",
	desc = _t"Amaze your friends with this cannister launcher which lets you project deadly poison clouds with but a wave of your hand. #{italic}#Deadly!#{normal}#",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=70, cost=130},
	talents = {
		T_SMITH = 2,
	},
	ingredients = {
		LUMP_ORE = 10,
		HERBS = 8,
	},
}

newRecipe{ id = "VIRAL_NEEDLEGUN",
	name = _t"Viral Needlegun", icon = "shockbolt/object/tinkers_viral_needlegun_t5.png",
	desc = _t"Blight is not dirty to a Tinker, it is useful! By combining blighted materials with a simple mechanical gun, you can fire a low damaging attack that infects foes with terrible diseases.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=20, rarity=70, cost=150},
	talents = {
		T_SMITH = 3,
	},
	ingredients = {
		LUMP_ORE = 8,
		GHOUL_FLESH = 7,
	},
}

newRecipe{ id = "RAZOR_EDGE",
	name = _t"Razor Edge", icon = "shockbolt/object/tinkers_razor_edge_t5.png",
	desc = _t"Properly working and tempering a metal can make it harder than normal, and hold a sharper edge.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=7, rarity=40, cost=100},
	talents = {
		T_SMITH = 2,
	},
	ingredients = {
		LUMP_ORE = 2,
	},
}

newRecipe{ id = "ARMOUR_REINFORCEMENT",
	name = _t"Armour Reinforcement", icon = "shockbolt/object/tinkers_armour_reinforcement_t5.png",
	desc = _t"Want more defense? Wear more armour!",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=40, cost=80},
	talents = {
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 4,
	},
}

newRecipe{ id = "CRYSTAL_EDGE",
	name = _t"Crystal Edge", icon = "shockbolt/object/tinkers_crystal_edge_t5.png",
	desc = _t"Adding a crystal blade to your weapon will make it the flashiest around! (with added light damage and increased critical multiplier)",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=30, rarity=80, cost=160},
	talents = {
		T_SMITH = 4,
	},
	ingredients = {
		LUMP_ORE = 1,
	},
	items = {
		[function(ml) return ({"GEM_CITRINE","GEM_AQUAMARINE","GEM_QUARTZ","GEM_RUBY","GEM_DIAMOND"})[util.bound(ml, 1, 5)] end] = function(ml) return ({_t"citrine",_t"aquamarine",_t"quartz",_t"ruby",_t"diamond"})[util.bound(ml, 1, 5)] end
	},
}

newRecipe{ id = "CRYSTAL_PLATING",
	name = _t"Crystal Plating", icon = "shockbolt/object/tinkers_crystal_plating_t5.png",
	desc = _t"Boring armour not fancy enough? Bling it up with crystal plating!  Increases all of your base stats.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=20, rarity=80, cost=160},
	talents = {
		T_SMITH = 3,
	},
	ingredients = {
		LUMP_ORE = 2,
	},
	items = {
		[function(ml) return ({"GEM_CITRINE","GEM_AQUAMARINE","GEM_QUARTZ","GEM_RUBY","GEM_DIAMOND"})[util.bound(ml, 1, 5)] end] = function(ml) return ({_t"citrine",_t"aquamarine",_t"quartz",_t"ruby",_t"diamond"})[util.bound(ml, 1, 5)] end
	},
}

newRecipe{ id = "HANDS_CREATION",
	name = _t"Hands of Creation", icon = "shockbolt/object/artifact/hands_of_creation.png",
	desc = _t"From your hands have been wrought incredible works. Your works have been forged in fire, and so have you.",
	base_ml = 5, max_ml = 5,
	unique = true,
	talents = {
		T_SMITH = 5,
		T_ELECTRICITY = 3,
		T_EXPLOSIVES = 2,
	},
	ingredients = {
		LUMP_ORE = 10,
		HERBS = 10,
		PRIMAL_CORE = 1,
	},
	items = {
		TINKER_SHOCKING_TOUCH5 = _t"shocking touch",
		GEM_FIRE_OPAL = _t"fire opal",
		GEM_PEARL = _t"pearl",
		GEM_DIAMOND = _t"diamond",
		GEM_BLOODSTONE = _t"bloodstone",
	},
}

newRecipe{ id = "SPIKE_ATTACHMENT",
	name = _t"Spike Attachment", icon = "shockbolt/object/tinkers_spike_attachment_t5.png",
	desc = _t"Adding metal spikes to anything makes it more dangerous. (and also unwieldy and inconvenient)",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=10, rarity=60, cost=120},
	talents = {
		T_SMITH = 1,
	},
	ingredients = {
		LUMP_ORE = 3,
	},
}

newRecipe{ id = "SILVER_FILIGREE",
	name = _t"Silver Filigree", icon = "shockbolt/object/tinkers_silver_filigree_t5.png",
	desc = _t"In addition to making a weapon look more fancy, it also makes it more deadly against undead and other nasties.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=18, rarity=60, cost=120},
	talents = {
		T_SMITH = 3,
	},
	ingredients = {
		LUMP_ORE = 2,
	},
}

newRecipe{ id = "BACK_SUPPORT",
	name = _t"Back Support", icon = "shockbolt/object/tinkers_back_support_t5.png",
	desc = _t"Just what you need to support your back when lifting heavy things; like armour, weapons or Yetis.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=60, cost=90},
	talents = {
		T_SMITH = 1,
		T_MECHANICAL = 1,
	},
	ingredients = {
		LUMP_ORE = 2,
	},
}

newRecipe{ id = "GROUNDING_STRAP",
	name = _t"Grounding Strap", icon = "shockbolt/object/tinkers_grounding_strap_t5.png",
	desc = _t"Keeping yourself grounded is very important, especially around lightning mages.  Increases lightning and stun resistance.",
	base_ml = 1, max_ml = 5,
	random_schematic = {level=1, rarity=70, cost=120},
	talents = {
		T_SMITH = 1,
		T_ELECTRICITY = 1,
	},
	ingredients = {
		LUMP_ORE = 2,
	},
}
