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

local Particles = require "engine.Particles"

newBirthDescriptor{
	type = "class",
	name = "Tinker",
	desc = {
		_t"Tinkers use steamtech to power their attacks, defenses, ...",
	},
	locked = function(birther) return birther:isDescriptorSet("world", "Orcs") or profile.mod.allow_build.orcs_tinker_eyal end,
	locked_desc = _t"Build, experiment, discover. The path of inventions is never over!",
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Sawbutcher = "allow",
			Gunslinger = "allow",
			Psyshot = "allow",
			Annihilator = "allow",
		},
	},
	copy = {
		resolvers.inscription("IMPLANT:_STEAM_GENERATOR", {newmode=true, cooldown=32, power=5}, 1),
		resolvers.inscription("IMPLANT:_MEDICAL_INJECTOR", {cooldown=1, cooldown_mod=100, power=100}, 2),
		resolvers.inscription("IMPLANT:_MEDICAL_INJECTOR", {cooldown=1, cooldown_mod=100, power=100}, 3),
		resolvers.inventory{ id=true, 
			{defined="TINKER_HEALING_SALVE1", base_list="mod.class.Object:/data-orcs/general/objects/tinker.lua"},
			{defined="TINKER_FROST_SALVE1", base_list="mod.class.Object:/data-orcs/general/objects/tinker.lua"},
		},
		resolvers.generic(function(e)
			e:addNewHotkey("inventory", ("%s healing salve"):tformat(_t"simple"))
			e:addNewHotkey("inventory", ("%s frost salve"):tformat(_t"simple"))
		end),
		resolvers.inventory{ id=true, 
			{defined="APE", base_list="mod.class.Object:/data-orcs/general/objects/quest-artifacts.lua"},
		},
		can_tinker = {steamtech=1}, -- this allows randbosses to equip tinkers
	},
	game_state = {
		merge_tinkers_data = true,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Sawbutcher",
	locked = function(birther) return birther:isDescriptorSet("world", "Orcs") or profile.mod.allow_build.orcs_tinker_eyal end,
	locked_desc = _t"Build, experiment, discover. The path of inventions is never over!",
	desc = {
		_t"A formidable behemoth of war using steamsaws to improve his deadliness.",
		_t"Their most important stats are: Strength and Cunning",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +5 Strength, +0 Dexterity, +1 Constitution",
		_t"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +3 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# 2",
	},
	power_source = {steam=true, technique=true},
	stats = { str=5, cun=3, con=1, },
	talents_types = {
		["steamtech/butchery"]={true, 0.3},
		["steamtech/sawmaiming"]={true, 0.3},
		["steamtech/battlefield-management"]={true, 0.3},
		["steamtech/battle-machinery"]={true, 0.3},
		["steamtech/automated-butchery"]={false, 0.3},
		["steamtech/furnace"]={false, 0.3},
		["steamtech/chemistry"]={true, 0.2},
		["steamtech/physics"]={true, 0.2},
		["steamtech/blacksmith"]={true, 0.2},
		["steamtech/engineering"]={false, 0.1},
		["cunning/survival"]={false, 0.2},
		["technique/combat-training"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
		[ActorTalents.T_STEAMSAW_MASTERY] = 1,
		[ActorTalents.T_TO_THE_ARMS] = 1,
		[ActorTalents.T_SMITH] = 1,
		[ActorTalents.T_SAWWHEELS] = 1,
		[ActorTalents.T_THERAPEUTICS] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		max_life = 110,
		resolvers.auto_equip_filters{ MAINHAND={type="weapon", subtype="steamsaw"},
			OFFHAND={type="weapon", subtype="steamsaw"},
		},
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="steamsaw", name="iron steamsaw", base_list="mod.class.Object:/data-orcs/general/objects/steamsaw.lua", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="steamsaw", name="iron steamsaw", base_list="mod.class.Object:/data-orcs/general/objects/steamsaw.lua", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="hands", name="iron gauntlets", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="feet", name="pair of iron boots", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
		resolvers.attachtinkerbirth{ id=true,
			{defined="TINKER_ROCKET_BOOTS1"},
		},
		resolvers.learn_schematic"HEALING_SALVE",
		resolvers.learn_schematic"ROCKET_BOOTS",
		resolvers.learn_schematic"STEAMSAW",
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Gunslinger",
	desc = {
		_t"A tinker who dual-wields steamguns to great effect.",
		_t"Their most important stats are: Cunning and Dexterity",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +0 Strength, +4 Dexterity, +1 Constitution",
		_t"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +4 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# -1",
	},
	locked = function(birther) return birther:isDescriptorSet("world", "Orcs") or profile.mod.allow_build.orcs_tinker_eyal end,
	locked_desc = _t"Build, experiment, discover. The path of inventions is never over!",
	power_source = {steam=true, technique=true, technique_ranged=true},
	stats = { cun=4, dex=4, con=1, },
	talents_types = {
		["steamtech/gunner-training"]={true, 0.3},
		["steamtech/gunslinging"]={true, 0.3},
		["steamtech/bullets-mastery"]={true, 0.3},
		["steamtech/avoidance"]={true, 0.3},
		["steamtech/automation"]={false, 0.3},
		["steamtech/elusiveness"]={true, 0.3},
		["steamtech/chemistry"]={true, 0.2},
		["steamtech/physics"]={true, 0.2},
		["steamtech/blacksmith"]={false, 0.1},
		["steamtech/engineering"]={true, 0.2},
		["cunning/survival"]={false, -0.1},
		["technique/combat-training"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_SMITH] = 1,
		[ActorTalents.T_THERAPEUTICS] = 1,
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_STRAFE] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_STEAMGUN_MASTERY] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.auto_equip_filters{ MAINHAND={type="weapon", subtype="steamgun"},
			OFFHAND={type="weapon", subtype="steamgun"},
			QUIVER={type="ammo", subtype="shot"}
		},
		resolvers.equip{ id=true,
			{type="weapon", subtype="steamgun", name="iron steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="steamgun", name="iron steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", autoreq=true, ego_chance=-1000},
			{type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="head", name="rough leather hat", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="cloak", name="kruk cloak", base_list="mod.class.Object:/data-orcs/general/objects/special-misc.lua", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
		resolvers.attachtinkerbirth{ id=true,
			{defined="TINKER_FOCUS_LEN1", base_list="mod.class.Object:/data-orcs/general/objects/tinker.lua"},
		},
		resolvers.learn_schematic"FOCUS_LEN",
		resolvers.learn_schematic"STEAMGUN",
		resolvers.generic(function(e)
			e.auto_shoot_talent = e.T_SHOOT
		end),
	},
	copy_add = {
		life_rating = -1,
	},
	party_copy = {
		known_tinkers = {
			PAIN_SUPPRESSOR_SALVE = true,
		}
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Psyshot",
	locked = function(birther) return (birther:isDescriptorSet("world", "Orcs") or profile.mod.allow_build.orcs_tinker_eyal) and profile.mod.allow_build.tinker_psyshot end,
	locked_desc = _t"Bend the mind, bend the tech. All around inspire dread.",
	desc = {
		_t"Powerful psionics are able to enter a gestalt with steam generators and technology to enhance their own mental prowess.",
		_t"The Psyshot combines this ability to gestalt to enhance his mindstar all the while shooting her steamgun to devastate the enemy lines.",
		_t"Their most important stats are: Cunning, Willpower and Dexterity",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +0 Strength, +3 Dexterity, +0 Constitution",
		_t"#LIGHT_BLUE# * +0 Magic, +3 Willpower, +3 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# -1",
	},
	power_source = {steam=true, psionic=true, technique_ranged=true},
	stats = { cun=3, dex=3, wil=3, },
	talents_types = {
		["steamtech/avoidance"]={false, 0.3},
		["steamtech/chemistry"]={true, 0.2},
		["steamtech/physics"]={true, 0.2},
		["steamtech/blacksmith"]={false, 0.1},
		["steamtech/engineering"]={true, 0.2},
		["psionic/nightmare"]={false, 0.3},
		["cunning/survival"]={false, -0.1},
		["technique/combat-training"]={true, 0.3},
		["psionic/gestalt"]={true, 0.3},
		["steamtech/psytech-gunnery"]={true, 0.3},
		["steamtech/thoughts-of-iron"]={true, 0.3},
		["steamtech/mechstar"]={true, 0.3},
		["psionic/action-at-a-distance"]={true, 0.3},
		["psionic/psionic-fog"]={true, 0.3},
		["steamtech/dread"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_SMITH] = 1,
		[ActorTalents.T_THERAPEUTICS] = 1,
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_GESTALT] = 1,
		[ActorTalents.T_PSYSHOT] = 1,
		[ActorTalents.T_METALSTAR] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.auto_equip_filters{ MAINHAND={type="weapon", subtype="steamgun"},
			OFFHAND={type="weapon", subtype="mindstar"},
			QUIVER={type="ammo", subtype="shot"}
		},
		resolvers.equip{ id=true,
			{type="weapon", subtype="steamgun", name="iron steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="feet", name="pair of rough leather boots", autoreq=true, ego_chance=-1000},
		},
		resolvers.attachtinkerbirth{ id=true,
			{defined="TINKER_ROCKET_BOOTS1", base_list="mod.class.Object:/data-orcs/general/objects/tinker.lua"},
		},
		resolvers.learn_schematic"FOCUS_LEN",
		resolvers.learn_schematic"ROCKET_BOOTS",
		resolvers.learn_schematic"STEAMGUN",
		resolvers.generic(function(e)
			e.auto_shoot_talent = e.T_SHOOT
		end),
	},
	copy_add = {
		life_rating = -1,
	},
	party_copy = {
		known_tinkers = {
			PAIN_SUPPRESSOR_SALVE = true,
		}
	},
}

local shield_special = function(e) -- allows any object with shield combat
	local combat = e.shield_normal_combat and e.combat or e.special_combat
	return combat and combat.block
end

newBirthDescriptor{
	type = "subclass",
	name = "Annihilator",
	desc = {
		_t"The Annihilator is a master of destruction, wielding the most devastating steamtech inventions to lay waste to their foes.",
		_t"While normally wielding a steamgun loaded with experimental ammunition and an electrically charged shield, they can equip heavy weapons such as flamethrowers.",
		_t"More adept at technology than most other tinkers, they supplement their weapons with automated turrets, mechanical minions and other such devices.",		
		_t"Their most important stats are: Cunning and Dexterity",
		_t"#GOLD#Stat modifiers:",
		_t"#LIGHT_BLUE# * +0 Strength, +4 Dexterity, +0 Constitution",
		_t"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +5 Cunning",
		_t"#GOLD#Life per level:#LIGHT_BLUE# -1",
	},
	locked = function(birther) return (birther:isDescriptorSet("world", "Orcs") or profile.mod.allow_build.orcs_tinker_eyal) and profile.mod.allow_build.tinker_annihilator end,
	locked_desc = _t"Research. Tinker. Annihilate.",
	power_source = {steam=true, technique=true, technique_ranged=true},
	stats = { cun=5, dex=4, con=0, },
	talents_types = {
		["steamtech/magnetism"]={true, 0.3},
		["steamtech/heavy-weapons"]={true, 0.3},
		["steamtech/gadgets"]={true, 0.3},
		["steamtech/demolition"]={true, 0.3},
		["steamtech/turrets"]={true, 0.3},		
		["steamtech/mecharachnid"]={false, 0.3},
		["steamtech/artillery"]={false, 0.3},
		["steamtech/chemical-warfare"]={false, 0.3},		
		["steamtech/chemistry"]={true, 0.2},
		["steamtech/physics"]={true, 0.2},
		["steamtech/blacksmith"]={false, 0.1},
		["steamtech/engineering"]={true, 0.2},
		["cunning/survival"]={false, -0.1},
		["technique/combat-training"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_SMITH] = 1,
		[ActorTalents.T_THERAPEUTICS] = 1,
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_AUTOLOADER] = 1,
		[ActorTalents.T_DEPLOY_TURRET] = 1,
		[ActorTalents.T_HEAVY_WEAPONS] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 2,
	},
	copy = {
		max_life = 90,
		resolvers.auto_equip_filters{ MAINHAND={type="weapon", subtype="steamgun"},
			OFFHAND = {special=shield_special},
			QUIVER={type="ammo", subtype="shot"}
		},
		resolvers.equip{ id=true,
			{type="weapon", subtype="steamgun", name="iron steamgun", base_list="mod.class.Object:/data-orcs/general/objects/steamgun.lua", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="hands", name="iron gauntlets", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
		-- They dont start with a tinker attached, but are compensated by starting with a point in heavy weapons
		-- resolvers.attachtinkerbirth{ id=true,
		-- 	{defined="TINKER_TOXIC_CANNISTER_LAUNCHER1"},
		-- },
		-- resolvers.learn_schematic"TOXIC_CANNISTER_LAUNCHER",
		resolvers.learn_schematic"ROCKET_BOOTS",
		resolvers.learn_schematic"STEAMGUN",
		resolvers.generic(function(e)
			e.auto_shoot_talent = e.T_SHOOT
		end),
	},
	copy_add = {
		life_rating = -1,
	},
	party_copy = {
		known_tinkers = {
			PAIN_SUPPRESSOR_SALVE = true,
		}
	},
}