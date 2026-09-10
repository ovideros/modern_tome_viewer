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

load("/data-orcs/general/npcs/undead-drake.lua", rarity(0))

load("/data/general/npcs/fire-drake.lua", rarity(3))
load("/data/general/npcs/cold-drake.lua", rarity(3))
load("/data/general/npcs/storm-drake.lua", rarity(3))
load("/data/general/npcs/multihued-drake.lua", rarity(3))
load("/data/general/npcs/wild-drake.lua", rarity(3))

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_UNDEAD_DRAKE", define_as = "URESLICH",
	allow_infinite_dungeon = true, unique=true,
	name = "Ureslak the Eternal", color=colors.PURPLE, display="D",
	desc = _t[[The legendary Wyrm seems to have fallen, though it doesn't appear to have stuck.]],
	resolvers.nice_tile{tall=1},
	level_range = {35, nil}, exp_worth = 1,
	rank = 4,
	max_life = resolvers.rngavg(170,190), life_rating = 25,
	combat_armor = 30, combat_def = 0,
	on_melee_hit = {[DamageType.DARKNESS]=resolvers.mbonus(25, 10)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,150), 1, 2.2), atk=resolvers.rngavg(25,130), apr=32, dammod={str=1.1, mag=0.3} },
	stats_per_level = 5,
	lite = 1,
	stun_immune = 1,
	blind_immune = 1,
	confusion_immune = 1,
	negative_regen = 0.5,
	soul_regen=1.5,
	soul=10,
	
	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, GEM={max=1, stack_limit=1} },
	equipdoll = "alchemist_golem",
	make_escort = {
		{type="undead", name="undead wyrm", number=4, no_subescort=true},
	},

	resolvers.talents{
		[Talents.T_RAZE]={base=5, every=7},
		[Talents.T_INFECTIOUS_MIASMA]={base=5, every=5},
		[Talents.T_NECROTIC_BREATH]={base=5, every=4},
		[Talents.T_VAMPIRIC_SURGE]={base=5, every=6},
		
		[Talents.T_CALL_SHADOWS]={base=4, every=6},
		[Talents.T_FOCUS_SHADOWS]={base=4, every=6},
		[Talents.T_SHADOW_MAGES]={base=2, every=6},
		[Talents.T_SHADOW_WARRIORS]={base=2, every=6},
		[Talents.T_HYMN_OF_SHADOWS]={base=1, every=6},
		[Talents.T_MOONLIGHT_RAY]={base=5, every=6},
		[Talents.T_SHADOW_BLAST]={base=5, every=6},
		[Talents.T_TWILIGHT_SURGE]={base=5, every=6},

		[Talents.T_DRACONIC_BODY] = 1,
		[Talents.T_DRACONIC_WILL] = 1,
		[Talents.T_SPINE_OF_THE_WORLD] = 1,
	},
	resolvers.sustains_at_birth(),
	
	resolvers.drops{chance=100, nb=1, {defined="URESLAK_FOCUS", random_art_replace={chance=75}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	on_die = function(self)
		game:setAllowedBuild("wyrmic_undead", true)
		local p = game.party:findMember{main=true}
		if p.descriptor.subclass == "Wyrmic"  then
			if p:knowTalentType("spell/undead-drake") == nil then
				p:learnTalentType("spell/undead-drake", false)
				p:setTalentTypeMastery("spell/undead-drake", 1.3)
			end
		end

		local femur, femur_item, femur_inven = game.player:findInAllInventoriesBy("define_as", "URESLAK_FEMUR")
		if femur and game.player:getInven(femur_inven) and game.player:getInven(femur_inven).worn then
			world:gainAchievement("ORCS_URESLAK_URESLAK_FEMUR", game.player)
		end
	end,
}
