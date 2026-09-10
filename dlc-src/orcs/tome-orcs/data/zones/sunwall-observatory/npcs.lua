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
load("/data/general/npcs/feline.lua", switchRarity("mountainpass_rarity"))
load("/data/general/npcs/canine.lua", switchRarity("mountainpass_rarity"))
load("/data/general/npcs/bear.lua", switchRarity("mountainpass_rarity"))
load("/data/general/npcs/plant.lua", switchRarity("mountainpass_rarity"))
load("/data-orcs/general/npcs/yeti.lua", switchRarity"unused")

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "STAR_GAZER",
	base = "BASE_SUNWALL_MAGE",
	subtype = "elf", female = true,
	name = "Star Gazer", color=colors.PURPLE,
	resolvers.nice_tile{tall=1},
	desc = _t[[This astromancer radiates the power of all celestial bodies. You can discern a distinct elven shape under the hood and robes.]],
	level_range = {18, nil}, exp_worth = 1 / 5,
	rarity = false, rank =4,
	max_life = 125, life_rating = 12, fixed_rating = true,
	positive_regen = 3, negative_regen = 3,
	
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, HEAD=1, BODY=1, QUIVER=1 },
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="robe", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {defined="STARCALLER", random_art_replace={chance=65}}},
	resolvers.drops{chance=100, nb=1, {defined="CAP_UNDISTURBED_MIND", replace_unique={type="armor", subtype="head", forbid_power_source={antimagic=true}}, autoreq=true}},
	resolvers.drops{chance=100, nb=1, {tome_drops="boss"}},

	combat_armor = 0, combat_def = 5,
	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },

	inc_damage = {all=-50},
	
	resolvers.talents{ 
		[Talents.T_STAFF_MASTERY]={base=3, every=4, max=10},
		[Talents.T_LUNAR_ORB]={base=1, every=4, max=18}, 
		[Talents.T_SOLAR_ORB]={base=1, every=4, max=18}, 
		[Talents.T_PLASMA_BOLT]={base=1, every=4, max=18}, 
		[Talents.T_GALACTIC_PULSE]={base=1, every=5, max=18},
		[Talents.T_GRAVITY_SPIKE]={base=1, every=5, max=18},
		[Talents.T_GRAVITY_LOCUS]={base=1, every=6, max=18},
		[Talents.T_REPULSION_BLAST]={base=1, every=6, max=18},
		[Talents.T_GRAVITY_WELL]={base=1, every=6, max=18},
	},
	resolvers.sustains_at_birth(),
	
	on_die = function(self, who)
		if not game.level.data.first_stargazer_turn then game.level.data.first_stargazer_turn = game.turn end
		game.level.data.killed_stargazers = game.level.data.killed_stargazers or 0
		game.level.data.killed_stargazers = game.level.data.killed_stargazers + 1
		if game.level.data.killed_stargazers >= 5 then
			game.player:grantQuest("orcs+sunwall-observatory")
			game.player:setQuestStatus("orcs+sunwall-observatory", engine.Quest.COMPLETED)

			if game.level.data.first_stargazer_turn and game.turn - game.level.data.first_stargazer_turn <= 70 then
				world:gainAchievement("ORCS_ASTRAL_MULTI_KILL", game.player)
			end
		end
	end,
}

newEntity{ define_as = "ASTRAL_YETI",
	allow_infinite_dungeon = true, unique=true, rank=3.5,
	base = "BASE_NPC_YETI", color=colors.PURPLE,
	name = "Astral-Infused Yeti",
	resolvers.nice_tile{tall=1},
	desc = _t[[You wonder how this yeti can have wandered so far from its native habitat in the Clork Peninsula. You also wonder what happened to it that produced the celestial energies-wielding creature you angrily marching towards you.]],
	level_range = {30, nil}, exp_worth = 2,
	rarity = false,
	max_life = 350, life_rating = 17, fixed_rating = true,
	combat_armor = 15, combat_def = 15, combat_armor_hardiness = 70,
	combat = { dam=resolvers.levelup(40, 1, 1.5), atk=resolvers.levelup(30, 1, 1), apr=3 },
	stats = { str=30, dex=15, con=15 },
	resolvers.auto_equip_filters("Brawler"),
	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]={base=3, every=10, max=5},
		[Talents.T_DOUBLE_STRIKE]={base=2, every=5, max=10},
		[Talents.T_RUSH]={base=2, every=8, max=10},
		[Talents.T_ALGID_RAGE]={base=2, every=8, max=10},
		[Talents.T_THICK_FUR]={base=2, every=8, max=10},
		[Talents.T_UNARMED_MASTERY]={base=2, every=8, max=10},
		[Talents.T_REFLEX_DEFENSE]={base=2, every=8, max=10},
		[Talents.T_GLYPH_OF_PARALYSIS]={base=2, every=8, max=10},
		[Talents.T_GLYPH_OF_EXPLOSION]={base=2, every=8, max=10},
		[Talents.T_SHADOW_SIMULACRUM]={base=2, every=8, max=10},
		[Talents.T_CIRCLE_OF_BLAZING_LIGHT]={base=2, every=8, max=10},
		[Talents.T_MOONLIGHT_RAY]={base=2, every=8, max=10},
	},
	
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	
	resolvers.drops{chance=100, nb=1, {defined="YETI_ASTRAL_MUSCLE"} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
}
