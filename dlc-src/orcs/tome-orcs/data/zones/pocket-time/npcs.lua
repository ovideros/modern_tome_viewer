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

local alter = function(add, mult)
	add = add or 0
	mult = mult or 1
	return function(e)
		if e.rarity then
			local list = {
				"T_DISINTEGRATION", "T_DUST_TO_DUST",
				"T_GRAVITY_SPIKE", "T_GRAVITY_LOCUS", "T_REPULSION_BLAST",
				"T_SPATIAL_TETHER", "T_DIMENSIONAL_ANCHOR", "T_BANISH",
				"T_TEMPORAL_BOLT",
				"T_REALITY_SMEARING", "T_ATTENUATE", 
				"T_TEMPORAL_FUGUE",
				"T_ENERGY_DECOMPOSITION", "T_ENTROPY",
				"T_DIMENSIONAL_STEP",
			}
			local ts = {}
			for i = 1, 1 + (e.rank or 2) do
				ts[ Talents[rng.tableRemove(list)] ] = {base=5, every=4}
			end
			e[#e+1] = resolvers.talents(ts)
			e.rarity = math.ceil(e.rarity * mult + add)
			e.name = (rng.table{_t"timeswapped %s", _t"splitted %s", _t"temporal %s", _t"paradox %s"}):tformat(e:getName())
		end
	end
end

load("/data/general/npcs/all.lua", alter(0, 1))


newEntity{ define_as = "MALTOTH",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "human", unique = true,
	name = "Maltoth the Mad",
	display = "p", color=colors.VIOLET,
	desc = _t[[This wretched human seems stuck in temporal flux.]],
	killer_message = _t"and dispersed across the timelines",
	level_range = {50, nil}, exp_worth = 2,
	max_life = 500, life_rating = 18, fixed_rating = true,
	max_mana = 850, mana_regen = 40,
	rank = 5,
	size_category = 2,
	infravision = 10,
	stats = { str=10, dex=12, cun=14, mag=25, con=16 },

	instakill_immune = 1,
	blind_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FINGER=2, BELT=1, NECK=1, TOOL=1 },
	resolvers.auto_equip_filters("Archmage", true),
	equipment = resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {unique=true} },

	resists = { [DamageType.TEMPORAL] = 50, },

	resolvers.talents{
		[Talents.T_STAFF_MASTERY]={base=5, every=4},
		[Talents.T_FREEZE]={base=5, every=4},
		[Talents.T_ICE_SHARDS]={base=5, every=4},
		[Talents.T_LIGHTNING]={base=5, every=4},
		[Talents.T_SHOCK]={base=5, every=4},
		[Talents.T_HURRICANE]={base=5, every=4},
		[Talents.T_NOVA]={base=5, every=4},
		[Talents.T_THUNDERSTORM]={base=5, every=4},
		[Talents.T_TEMPEST]={base=5, every=4},
		[Talents.T_FLAMESHOCK]={base=5, every=4},
		[Talents.T_BLASTWAVE]={base=5, every=4},
		[Talents.T_BURNING_WAKE]={base=5, every=4},
		[Talents.T_CLEANSING_FLAMES]={base=5, every=4},
		[Talents.T_HEAL]={base=5, every=4},
		[Talents.T_ARCANE_SHIELD]={base=5, every=4},
		[Talents.T_PHASE_DOOR]={base=5, every=4},

		[Talents.T_TEMPORAL_FORM]=1,
		[Talents.T_CAUTERIZE]=1,
		[Talents.T_METEORIC_CRASH]=1,
	},

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(1, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),
}

local boss_to_use = loading_list.MALTOTH
if world.majeyal_campaign_last_winner then
	local pwinner = world.majeyal_campaign_last_winner
	if pwinner.version[1] == game.__mod_info.version[1] and	pwinner.version[2] == game.__mod_info.version[2] and pwinner.version[3] == game.__mod_info.version[3] and table.same_values(pwinner.addons or {}, table.keys(game.__mod_info.addons)) then
		boss_to_use = class.new(pwinner)
	end
end
loading_list.BOSS = boss_to_use
