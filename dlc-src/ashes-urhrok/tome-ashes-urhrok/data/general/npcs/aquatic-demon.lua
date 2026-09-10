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

-- last updated:  10:46 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")


newEntity{ base = "BASE_NPC_AQUATIC_DEMON", define_as = "WALROG",
	name = "Walrog", color=colors.DARK_SEA_GREEN, unique=true,
	type = "demon", subtype = "major",
	desc = _t"Walrog, the lord of Water, is #AQUAMARINE#fearsome#LAST# to behold. The water boils and writhes around him as if trying to escape, frothing steam making his form indistinct.  He does not seem surprised to see you.",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/aquatic_demon_walrog.png", display_h=2, display_y=-1}}},
	level_range = {20, nil}, exp_worth = 1,
	rarity = 50,
	rank = 3.5,
	life_rating = 25, life = 500,
	autolevel = "warriormage",
	combat_armor = 45, combat_def = 0,
	combat = { dam=resolvers.mbonus(46, 20), atk=15, apr=7, dammod={str=0.9} },
	combat = {damtype=DamageType.ICE},

	reduce_detrimental_status_effects_time = 70,
	combat_spell_friendlyfire = 100,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	resists={
		[DamageType.COLD] = resolvers.mbonus(50, 30),
		[DamageType.FIRE] = resolvers.mbonus(50, 30),
	},

	resolvers.talents{
		[Talents.T_TIDAL_WAVE] = {base=4, every=4, max=10},
		[Talents.T_FREEZE] = {base=4, every=6, max=8},
		[Talents.T_FROST_GRAB] = {base=3, every=4, max=8},
		[Talents.T_DEMON_SEED_ACID_CONE] = {base=3, every=5, max=8},
		[Talents.T_BODY_OF_ICE] = {base=5, every=5, max=10},
		[Talents.T_FROZEN_GROUND] = {base=4, every=4, max=10},
		[Talents.T_UTTERCOLD] = {base=4, every=5, max=10},
		[Talents.T_HEAT] = {base=4, every=5, max=10},
		[Talents.T_BLASTWAVE] = {base=4, every=5, max=10},
		[Talents.T_INFERNO] = {base=4, every=5, max=10},
	},
	resolvers.sustains_at_birth(),

	on_death_lore = "walrog",
}

-- Remove ourself
local nw = loading_list[#loading_list]
loading_list[#loading_list] = nil

-- Replace the original walrog
for i = 1, #loading_list do if loading_list[i].name == "Walrog" then
	local e = loading_list[i]
	e:replaceWith(nw)
	break
end end
