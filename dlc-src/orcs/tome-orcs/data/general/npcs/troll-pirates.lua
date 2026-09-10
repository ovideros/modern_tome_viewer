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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_TROLL_PIRATE",
	type = "giant", subtype = "troll",
	display = "T", color=colors.UMBER,

	combat = { dam=resolvers.levelup(resolvers.mbonus(45, 10), 1, 1), atk=2, apr=6, physspeed=2, dammod={str=1},},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },

	infravision = 10,
	life_rating = 14,
	life_regen = 2,
	max_stamina = 90,
	rank = 2,
	size_category = 4,
	faction = "kar-haib-dominion",

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=20, dex=12, mag=10, con=16, cun=15, },

	open_door = true,

	resists = { [DamageType.FIRE] = -10 },
	fear_immune = 1,
	stun_immune = 0.5,
	ingredient_on_death = "TROLL_INTESTINE",
}

newEntity{ base = "BASE_NPC_TROLL_PIRATE",
	name = "troll pirate", color=colors.YELLOW_GREEN,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_troll_troll_pirate.png", display_h=2, display_y=-1}}},
	resolvers.auto_equip_filters("Rogue"),
	resolvers.equip{
		{type="weapon", subtype="dagger", autoreq=true},
		{type="weapon", subtype="dagger", autoreq=true},
	},
	
	desc = _t[[This is a Troll pirate.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 8, combat_def = 0,
	resolvers.talents{
		[Talents.T_KNIFE_MASTERY]={base=1, every=10, max=5},
		[Talents.T_LETHALITY]={base=2, every=6, max=6},
		[Talents.T_DUAL_WEAPON_DEFENSE]={base=1, every=6, max=6},
		[Talents.T_TOTAL_THUGGERY]={base=1, every=5, max=7},
	},
}

newEntity{ base = "BASE_NPC_TROLL_PIRATE",
	name = "troll marauder", color=colors.GREEN,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_troll_troll_marauder.png", display_h=2, display_y=-1}}},
	desc = _t[[This lean but muscular troll deftly wields two daggers. He glares at you with eyes filled with cunning.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(150,160),
	life_rating = 12,
	resolvers.auto_equip_filters("Marauder"),
	resolvers.equip{
		{type="weapon", subtype="dagger", autoreq=true},
		{type="weapon", subtype="dagger", autoreq=true},
	},
	
	combat_armor = 8, combat_def = 0,
	resolvers.talents{
		[Talents.T_LETHALITY]={base=3, every=6, max=6},
		[Talents.T_TOTAL_THUGGERY]={base=1, every=5, max=8},
		[Talents.T_KNIFE_MASTERY]={base=1, every=6, max=6},
		[Talents.T_DUAL_WEAPON_TRAINING]={base=1, every=6, max=6},
		[Talents.T_DUAL_STRIKE]={base=1, every=6, max=6},
	},
}

newEntity{ base = "BASE_NPC_TROLL_PIRATE",
	name = "troll captain", color=colors.BLUE,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_troll_troll_captain.png", display_h=2, display_y=-1}}},
	desc = _t[[This troll is barking orders to the other trolls around him. He effortlessly holds a longsword in each hand.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 6,
	allow_any_dual_weapons = 1,
	resolvers.auto_equip_filters("Reaver"),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="weapon", subtype="longsword", autoreq=true},
	},
	make_escort = {
		{type="giant", subtype="troll", name="troll pirate", number=4},
	},
	rank = 3,
	max_life = resolvers.rngavg(150,160),
	life_rating = 12,
	combat_armor = 10, combat_def = 0,
	resolvers.talents{
		[Talents.T_DUAL_WEAPON_TRAINING]={base=2, every=6, max=6},
		[Talents.T_DUAL_WEAPON_DEFENSE]={base=2, every=6, max=6},
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=5},
		[Talents.T_DUAL_STRIKE]={base=1, every=6, max=6},
		[Talents.T_SWEEP]={base=1, every=6, max=6},
		
		[Talents.T_RUSH]={base=2, every=6, max=4},
	},
}

newEntity{ base = "BASE_NPC_TROLL_PIRATE",
	name = "troll guard", color=colors.YELLOW_GREEN,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_troll_troll_guard.png", display_h=2, display_y=-1}}},
	resolvers.auto_equip_filters("Bulwark"),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	desc = _t[[This troll carries a large sword and shield, and appears to be wearing segments of armor.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(180,200),
	life_rating=15,
	combat_armor = 14, combat_def = 12,
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING] = {base=2, every=10, max=5},
		[Talents.T_SHIELD_PUMMEL]={base=1, every=10, max=5},
		[Talents.T_WEAPON_COMBAT]={base=2, every=10, max=5},
		[Talents.T_WEAPONS_MASTERY]={base=2, every=10, max=5},
		[Talents.T_DISARM]={base=2, every=7, max=7},
	},
}

newEntity{ base = "BASE_NPC_TROLL_PIRATE",
	name = "troll aquamancer", color=colors.YELLOW_GREEN,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_troll_troll_aquamancer.png", display_h=2, display_y=-1}}},
	resolvers.auto_equip_filters("Archmage"),
	resolvers.equip{ {type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true} },
	autolevel = "caster",
	
	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	desc = _t[[This troll is holding a tall staff in one hand. Tendrils of water circle around it.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 6,
	max_life = resolvers.rngavg(180,200),
	life_rating=15,
	combat_armor = 14, combat_def = 12,
	resolvers.talents{
		[Talents.T_STAFF_MASTERY]={base=1, every=10, max=5},
		[Talents.T_WATER_BOLT]={base=2, every=10, max=5},
		[Talents.T_GLACIAL_VAPOUR]={base=2, every=10, max=5},
		[Talents.T_TIDAL_WAVE]={base=3, every=10, max=5},
	},
}