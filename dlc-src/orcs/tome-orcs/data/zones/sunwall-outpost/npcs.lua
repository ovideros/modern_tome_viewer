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

load("/data-orcs/general/npcs/sunwall-warrior.lua", rarity(0))
load("/data-orcs/general/npcs/sunwall-mage.lua", rarity(0))

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "LEADER_JOHN",
	allow_infinite_dungeon = true, subtype = "human",
	base = "BASE_SUNWALL_WARRIOR",
	name = "Outpost Leader John", color=colors.PURPLE, unique = true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_outpost_leader_john.png", display_h=2, display_y=-1}}},
	desc = _t[[This warrior's armor glows with a bright golden light. He wields an ornate sword and shield, and marches towards you with confidence.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = false, rank =4,
	max_life = 125, life_rating = 14, fixed_rating = true,
	positive_regen = 3, negative_regen = 3,
	resolvers.auto_equip_filters("Sun Paladin"),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true, forbid_power_source={antimagic=true}},
		{type="armor", subtype="shield", autoreq=true, forbid_power_source={antimagic=true}},
		{type="armor", subtype="heavy", autoreq=true, forbid_power_source={antimagic=true}},
	},
	combat_armor = 6, combat_def = 8,
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING] = {base=1, every=10, max=5},
		[Talents.T_SHIELD_PUMMEL]={base=1, every=7, max=8}, 
		[Talents.T_CHANT_OF_FORTRESS]={base=1, every=10, max=5},
		[Talents.T_SEARING_LIGHT]={base=1, every=5, max=8},
		[Talents.T_WEAPON_OF_LIGHT]={base=2, every=5, max=9},
		[Talents.T_HEALING_LIGHT]={base=1, every=6, max=5},
		[Talents.T_SOLAR_ORB]={base=1, every=6, max=5},
		[Talents.T_ASTRAL_PATH]={base=4, every=6, max=9},
	},
	
	resolvers.sustains_at_birth(),
	
	resolvers.drops{chance=100, nb=1, {defined="SUNSTONE", random_art_replace={chance=50}} },
	resolvers.drops{chance=100, nb=1, {defined="NOTE6"} },

	on_die = function(self, who)
		local p = game:getPlayer(true)
		if p.descriptor.class == "Tinker" then
			world.orcs_killed_outpost_leader_john_with = world.orcs_killed_outpost_leader_john_with or {}
			world.orcs_killed_outpost_leader_john_with[p.descriptor.subclass] = true
			if #table.keys(world.orcs_killed_outpost_leader_john_with) >= 2 then
				game:setAllowedBuild("orcs_tinker_eyal", true)
			end
		end

		game.player:grantQuest("orcs+to-mainland")
		game.player:resolveSource():setQuestStatus("orcs+to-mainland", engine.Quest.COMPLETED)
	end,
}


newEntity{
	define_as = "BASE_NPC_KRUK_TOWN",
	type = "humanoid", subtype = "orc",
	display = "p", color=colors.WHITE,
	faction = "kruk-pride",
	never_anger = 1,

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 3,
	size_category = 3,

	open_door = true,
	resolvers.racial(),
	resolvers.inscriptions(1, "infusion"),

	resolvers.talents{ [Talents.T_STEAM_POOL]=1 },
	steam_regen = 18,

	autolevel = "warrior",
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=12, dex=12, cun=12, mag=6, con=12 },
}

newEntity{ base = "BASE_NPC_KRUK_TOWN", define_as = "ORC_RETALIATOR",
	name = "orc retaliator", color=colors.LIGHT_UMBER, image = "npc/humanoid_orc_orc_guard.png",
	desc = _t[[A stern-looking orc, armed to the teeth.]],
	level_range = {10, nil}, exp_worth = 1,
	max_life = 110,
	life_regen = 3,
	resolvers.equip{
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="weapon", subtype="steamsaw", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING] = {base=3, every=10, max=10},
		[Talents.T_SAWWHEELS]={base=2, every=4, max=10},
		[Talents.T_GRINDING_SHIELD]={base=2, every=4, max=10},
		[Talents.T_EXPLOSIVE_SAW]={base=2, every=4, max=10},
		[Talents.T_PUNISHMENT]={base=2, every=4, max=10},
		[Talents.T_FURNACE]={base=2, every=4, max=10}
	},
}

newEntity{ base = "BASE_NPC_KRUK_TOWN", define_as = "ORC_GUNSLINGER",
	name = "orc gunslinger", color=colors.UMBER,
	desc = _t[[A nasty looking orc armed with double steamguns.]],
	level_range = {10, nil}, exp_worth = 1,
	max_life = 110,
	autolevel = "slinger",
	resolvers.equip{
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
		{type="armor", subtype="cloak", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_SHOOT] = 1,
		[Talents.T_STEAMGUN_MASTERY] = {base=1, every=6, max=10},
		[Talents.T_OVERHEAT_BULLETS] = {base=2, every=4, max=10},
		[Talents.T_AUTOMATED_CLOAK_TESSELLATION] = {base=2, every=4, max=10},
		[Talents.T_DOUBLE_SHOTS] = {base=2, every=4, max=10},
		[Talents.T_NET_PROJECTOR] = {base=2, every=4, max=10},
	},
}