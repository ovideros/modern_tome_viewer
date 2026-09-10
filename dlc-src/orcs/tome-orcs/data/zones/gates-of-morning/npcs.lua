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
load("/data-orcs/general/npcs/ritch-extended.lua", switchRarity("ritch_rarity"))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "HIGH_SUN_PALADIN_AERYN",
	type = "humanoid", subtype = "human",
	display = "p",
	faction = "sunwall",
	name = "High Sun Paladin Aeryn", color=colors.VIOLET, unique = true,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_high_sun_paladin_aeryn.png", display_h=2, display_y=-1}}},
	desc = _t[[A beautiful woman, clad in shining plate armour. Power radiates from her.]],
	level_range = {30, nil}, exp_worth = 2,
	rank = 5,
	size_category = 4,
	female = true,
	max_life = 450, life_rating = 22, fixed_rating = true,
	infravision = 10,
	stats = { str=25, dex=20, cun=22, mag=26, con=24 },
	instakill_immune = 1,
	teleport_immune = 1,
	move_others=true,
	negative_regen = 10,
	positive_regen = 10,
	never_anger = true,

	open_door = true,

	resolvers.racial(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(3, {}),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FINGER=2 },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="NOTE3"} },
	resolvers.auto_equip_filters("Sun Paladin"),
	resolvers.equip{
		{type="weapon", subtype="mace", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="shield", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="massive", forbid_power_source={antimagic=true}, autoreq=true},
		{defined="RING_LOST_LOVE"},
	},
	resolvers.talents{
		[Talents.T_WEAPONS_MASTERY]={base=3, every=5, max=10},
		[Talents.T_WEAPON_COMBAT]={base=3, every=5, max=10},
		[Talents.T_THICK_SKIN]={base=3, every=5, max=10},
		[Talents.T_ARMOUR_TRAINING]={base=3, every=5, max=10},
		[Talents.T_CHANT_OF_LIGHT]={base=3, every=5, max=10},
		[Talents.T_SEARING_LIGHT]={base=3, every=5, max=10},
		[Talents.T_MARTYRDOM]={base=3, every=5, max=10},
		[Talents.T_BARRIER]={base=3, every=5, max=10},
		[Talents.T_WEAPON_OF_LIGHT]={base=3, every=5, max=10},
		[Talents.T_SECOND_LIFE]={base=3, every=5, max=10},
		[Talents.T_CIRCLE_OF_SANCTITY]={base=3, every=5, max=10},
		[Talents.T_SHIELD_OF_LIGHT]={base=3, every=5, max=10},
		[Talents.T_RETRIBUTION]={base=3, every=5, max=10},
		[Talents.T_HEALING_LIGHT]={base=3, every=5, max=10},
		[Talents.T_BARRIER]={base=3, every=5, max=10},
		[Talents.T_PROVIDENCE]={base=3, every=5, max=10},
		[Talents.T_LUCENT_WRATH]={base=3, every=5, max=10},
		[Talents.T_LIGHTSPEED]={base=3, every=5, max=10},

		[Talents.T_IRRESISTIBLE_SUN]=1,
		[Talents.T_TITAN_S_SMASH]=1,
		[Talents.T_MASSIVE_BLOW]=1,
		[Talents.T_CAUTERIZE]=1,
		[Talents.T_ARCANE_MIGHT]=1,
	},
	resolvers.sustains_at_birth(),

	self_resurrect = 1,
	self_resurrect_msg = _t"#LIGHT_RED#%s concentrates and casts a powerful shield!",
	on_resurrect = function(self)
		game.bignews:saySimple(120, "#GOLD#Before she falls, Aeryn manages to cast a powerful shield!")
		self:setEffect(self.EFF_AERYN_SUN_SHIELD, 100, {})
		local spot = game.level:pickSpot{type="event", subtype="gate-open"}
		local g = game.zone:makeEntityByName(game.level, "terrain", "FLOOR_ROAD_STONE")
		if spot and g then
			game.level.map(spot.x, spot.y, engine.Map.TERRAIN, g)
			game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		end
		game.player:grantQuest("orcs+destroy-sunwall")
	end,

	on_die = function(self)
		game.player:setQuestStatus("orcs+destroy-sunwall", engine.Quest.COMPLETED)
	end,
}

newEntity{ base = "BASE_SUNWALL_WARRIOR",
	name = "halfling pyremaster", color=colors.CRIMSON,
	subtype = "halfling",
	desc = _t[[This tiny ball of fiery hatred came to the Sunwall as reinforcement from the Allied Kingdoms. He shall regret it!]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(140,150), life_rating = 12,
	autolevel = "warriormage",
	allow_mainhand_2h_in_1h = 1,
	resolvers.auto_equip_filters{
	OFFHAND={special=function(e) -- allows any object with shield combat
		local combat = e.shield_normal_combat and e.combat or e.special_combat
		return combat and combat.block
	end}},
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true, forbid_power_source={antimagic=true}},
		{type="armor", subtype="shield", autoreq=true, forbid_power_source={antimagic=true}},
	},
	combat_armor = 0, combat_def = 6,
	autolevel = "warriormage",
	resolvers.talents{ 
		[Talents.T_SHIELD_PUMMEL]={base=3, every=5, max=9}, 
		[Talents.T_BODY_OF_FIRE]={base=3, every=5, max=9}, 
		[Talents.T_WILDFIRE]={base=4, every=5, max=9}, 
		[Talents.T_SLASH]={base=4, every=5, max=9}, 
		[Talents.T_BLINDSIDE]={base=4, every=5, max=9}, 
		[Talents.T_FEED]={base=4, every=5, max=9}, 
		[Talents.T_FEED_STRENGTHS]={base=4, every=5, max=9}, 
	},
	
	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_SUNWALL_WARRIOR",
	name = "shalore liberator", color=colors.BLUE,
	subtype = "shalore",
	desc = _t[[A powerful shalore brawler that came to the Sunwall as reinforcement from the Allied Kingdoms. He shall regret it!]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 2,
	rank = 3,
	max_life = 200, life_rating = 14,
	allow_mainhand_2h_in_1h = 1,
	resolvers.auto_equip_filters("Brawler"),
	resolvers.equip{
		{type="armor", subtype="hands", autoreq=true},
		{type="armor", subtype="light", autoreq=true},
	},
	combat_armor = 0, combat_def = 25,
	autolevel = "warrior",
	resolvers.talents{ 
		[Talents.T_DOUBLE_STRIKE] = {base=3, every=5, max=10},
		[Talents.T_UPPERCUT] = {base=4, every=5, max=10},
		[Talents.T_EMPTY_HAND] = 1,
		[Talents.T_CLINCH] = {base=3, every=5, max=10},
		[Talents.T_MAIM] = {base=3, every=5, max=10},
		[Talents.T_UNARMED_MASTERY] = {base=4, every=6, max=10},
		[Talents.T_WEAPON_COMBAT] = {base=4, every=6, max=10},
		[Talents.T_CONCUSSIVE_PUNCH] = {base=4, every=6, max=10},
		[Talents.T_HAYMAKER] = {base=4, every=6, max=10},
		[Talents.T_UNIFIED_BODY] = {base=4, every=6, max=10},
		[Talents.T_REFLEX_DEFENSE] = {base=4, every=6, max=10},
		[Talents.T_EVASION] = {base=4, every=6, max=10},
		[Talents.T_VITALITY] = {base=4, every=6, max=10},
		[Talents.T_RUSH] = {base=4, every=6, max=10},
	},
	
	resolvers.sustains_at_birth(),
}

newEntity{
	define_as = "BASE_NPC_DEFENSE_ORB",
	type = "immovable", subtype = "orb",
	display = "*", color=colors.WHITE,
	body = { INVEN = 10 },
	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	max_life = 3000, life_rating = 25, life_regen = 0,
	stats = { mag=20, },
	infravision = 10, never_move = 1, never_attack = 1,
	combat_armor = 0, combat_def = 0,
	resists = { all = 70 },
	rank = 3,
	size_category = 1,
	negative_status_effect_immune = 1,
	no_breath = 1,
	orb_rarity = 1,
	faction = "sunwall",
}

newEntity{ base = "BASE_NPC_DEFENSE_ORB",
	name = "sun orb", color=colors.GOLD, blood_color = colors.GOLD,
	desc = _t"A small orb infused with the power of the Sun.", image = "terrain/sun_orb.png",
	level_range = {30, nil}, exp_worth = 1,
	talent_cd_reduction = { [Talents.T_SOLAR_ORB] = 3 },
	resolvers.talents{ [Talents.T_SOLAR_ORB]={base=5, every=3} },
}

newEntity{ base = "BASE_NPC_DEFENSE_ORB",
	name = "moon orb", color=colors.GREY, blood_color = colors.GREY,
	desc = _t"A small orb infused with the power of the Moons.", image = "terrain/moon_orb.png",
	level_range = {30, nil}, exp_worth = 1,
	talent_cd_reduction = { [Talents.T_LUNAR_ORB] = 3 },
	resolvers.talents{ [Talents.T_LUNAR_ORB]={base=5, every=3} },
}

newEntity{ define_as = "LIMMIR",
	type = "humanoid", subtype = "elf",
	display = "p", color=colors.RED,
	name = "Limmir the Jeweler",
	size_category = 3, rank = 3,
	ai = "simple",
	faction = "sunwall",
	can_talk = "jewelry-store",
	can_quest = true,
}

newEntity{ define_as = "MELNELA",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.BLUE,
	name = "Melnela",
	female = true,
	size_category = 3, rank = 2,
	ai = "simple",
	faction = "sunwall",
	can_talk = "ardhungol-start",
	can_quest = true,
}