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

load("/data-cults/general/npcs/scourge-drake.lua")
load("/data/general/npcs/horror.lua", rarity(3, 30))
load("/data/general/npcs/all.lua", rarity(4, 350))

newEntity{ base = "BASE_NPC_HORROR",
	name = "awoken tentacle tree", color=colors.DARK_GREEN,
	desc = _t"One of the tentacle tree has awakened!",
	image = "invis.png",
	resolvers.nice_tile{tall=1},
	level_range = {20, nil},
	is_tentacle_tree = 1,
	rank = 3,
	autolevel = "warriormage",
	max_life = 400, life_rating = 15,
	insanity_regen = 25,
	combat_armor = resolvers.levelup(30, 1, 1.5), combat_def = 0,
	combat = { dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 2.2), atk=500, apr=10 },

	never_move = 1,

	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },

	body = { MAINHAND=1, OFFHAND=1, INVEN = 10 },

	resists = { [DamageType.FIRE] = -20, [DamageType.LIGHT] = -45 },

	see_invisible = 20,

	force_tentacle_hand = 1,
	resolvers.talents{
		[Talents.T_MUTATED_HAND] = {base=3, every=6},
		[Talents.T_TENDRILS_ERUPTION] = {base=3, every=6},
		[Talents.T_LASH_OUT] = {base=3, every=6},
		[Talents.T_TENTACLE_CONSTRICT] = {base=3, every=6},
	},
}

newEntity{ define_as = "KROLTAR_THE_SCOURGE",
	allow_infinite_dungeon = true,
	type = "dragon", subtype = "scourge", unique = true,
	name = "Kroltar the Scourge",
	display = "D", color=colors.VIOLET,
	resolvers.nice_tile{tall=1},
	desc = _t[[Kroltar, the mightiest fire wyrm to have ever walked Eyal. It was said that a group of dwarves had slain him, but something has taken up residence in the once proud creature's body, reanimating it into a twisted new lifeform.]],
	killer_message = _t"and fed to the corrupt writhing tentacles",
	level_range = {25, nil}, exp_worth = 2,
	max_life = 330, life_rating = 19, fixed_rating = true,
	insanity_regen = 7,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 4,
	size_category = 5,
	combat_armor = 17, combat_def = 14,
	infravision = 10,
	instakill_immune = 1,
	stun_immune = 1,
	move_others=true,
	no_difficulty_random_class = true,

	combat = { dam=resolvers.levelup(resolvers.rngavg(25,110), 1, 2), atk=resolvers.rngavg(25,70), apr=25, dammod={str=1.1} },

	resists = { [DamageType.BLIGHT] = 100 },

	body = { INVEN = 20, MAINHAND=1, OFFHAND=1, BODY=1 },
	-- resolvers.drops{chance=100, nb=1, {defined="FROST_TREADS", random_art_replace={chance=75}}, },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=10, {type="money"} },

	resolvers.talents{
		[Talents.T_BLOODSPRING]=1,
		[Talents.T_SPINE_OF_THE_WORLD]=1,

		[Talents.T_SHED_SKIN]={base=4, every=6},
		[Talents.T_CULTS_OVERGROWTH]={base=4, every=6},

		[Talents.T_AUGMENT_DESPAIR]={base=5, every=7},
		[Talents.T_TENTACLED_WINGS]={base=5, every=5},
		[Talents.T_MAGGOT_BREATH]={base=5, every=4},
		[Talents.T_DECAYING_GROUNDS]={base=5, every=6},

		[Talents.T_MUTATED_HAND] = {base=3, every=6},
		[Talents.T_LASH_OUT] = {base=3, every=6},
		[Talents.T_TENTACLE_CONSTRICT] = {base=3, every=6},
	},
	resolvers.sustains_at_birth(),
	resolvers.genericlast(function(e)
		-- Bonus loot due to zone difficulty
		for i = 1,3 do
			local CultsDLC = require "mod.class.CultsDLC"
			local art = CultsDLC.generateCorruptedItem()
			if art then e:addObject(e.INVEN_INVEN, art) end
		end
	end),
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(2, "infusion"),

	on_die = function(self)
		game:setAllowedBuild("wyrmic_scourge", true)
	end,
}
