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

load("/data/general/npcs/skeleton.lua", rarity(0))
load("/data/general/npcs/ghoul.lua", rarity(0))
load("/data/general/npcs/ghost.lua", rarity(4))
load("/data/general/npcs/vampire.lua", rarity(4))
load("/data/general/npcs/lich.lua", rarity(4))
load("/data/general/npcs/bone-giant.lua", rarity(3))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_VAMPIRE", define_as = "NECROMANCER",
	name = "Chanting Necromancer",
	color=colors.PURPLE,
	resolvers.nice_tile{tall=1},
	desc = _t[[A grim looking necromancer vampire. It seems to be draining the krogs of their life force for some nefarious purpose.]],
	killer_message = _t"and raised to serve",
	level_range = {20, nil}, exp_worth = 1,
	max_life = 150, life_rating = 11, fixed_rating = true,
	rank = 3,
	is_necromancer = 1,
	
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, ego_chance=100, autoreq=true},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, ego_chance=100, autoreq=true},
	},
	resolvers.drops{chance=50, nb=1, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_STAFF_MASTERY]= {base=4, every=8, max=10},
		[Talents.T_INVOKE_DARKNESS]={base=3, every=7, max=10},
		[Talents.T_BLUR_SIGHT]={base=3, every=7, max=10},
		[Talents.T_ROTTING_DISEASE]={base=3, every=7, max=10},
		[Talents.T_CIRCLE_OF_DEATH]={base=3, every=7, max=10},
		[Talents.T_INVISIBILITY]={base=3, every=7, max=10},
	},

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(1, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),

	on_die = function(self, who)
		local quest = game.player:hasQuest("cults+krogs-rescue")
		if not quest then return end
		quest:checkKills(game.player)
	end,
}

newEntity{ base = "BASE_NPC_LICH", define_as = "GRAND_NECROMANCER",
	name = "Grand Necromancer",
	color=colors.PURPLE,
	resolvers.nice_tile{tall=1},
	desc = _t[[You can hardly believe your eyes, standing in from of you as the grand master of the necromancers is a lich.]],
	killer_message = _t"and raised to serve",
	level_range = {22, nil}, exp_worth = 1,
	max_life = 250, life_rating = 15, fixed_rating = true,
	rank = 3.5,
	is_necromancer = 1,
	
	resolvers.talents{
		[Talents.T_STAFF_MASTERY]= {base=4, every=8, max=10},
		[Talents.T_INVOKE_DARKNESS]={base=3, every=7, max=10},
		[Talents.T_INVISIBILITY]={base=3, every=7, max=10},
		[Talents.T_HYMN_OF_SHADOWS]={base=3, every=7, max=10},
		[Talents.T_MOONLIGHT_RAY]={base=3, every=7, max=10},
		[Talents.T_SHADOW_BLAST]={base=3, every=7, max=10},
		[Talents.T_TWILIGHT_SURGE]={base=3, every=7, max=10},
		[Talents.T_STARFALL]={base=3, every=7, max=10},
	},

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(2, "rune"),
	resolvers.inscriptions(1, {"manasurge rune"}),

	on_die = function(self, who)
		local quest = game.player:hasQuest("cults+krogs-rescue")
		if not quest then return end
		quest:checkKills(game.player)
	end,
}

newEntity{
	define_as = "CAPTIVE_KROG",
	type = "giant", subtype = "krog",
	display = "O", color=colors.GREEN,
	name = "captive krog",
	desc = _t[[How this giant, this force of Nature has been captured and subdued is proof that the necromancers are not to be treated lightly.]],
	resolvers.nice_tile{tall=1},
	level_range = {20, nil}, exp_worth = 1,
	is_captive_krog = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },

	rank = 3,
	size_category = 4,
	infravision = 10,
	life_regen = 0,
	
	resolvers.racial(),
	resolvers.sustains_at_birth(),
	resolvers.inscriptions(2, "infusion"),

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=14, mag=14, con=14 },
	combat = { dammod={str=1, mag=0.5}},
	combat_armor = 8, combat_def = 6,
	not_power_source = {arcane=true},

	max_life = resolvers.rngavg(150,170), life_rating = 14,

	faction = "zigur",

	on_die = function(self, who)
		local quest = game.player:hasQuest("cults+krogs-rescue")
		if not quest then return end
		quest:checkKills(game.player)
	end,
	on_added_to_level = function(self)
		self:setEffect(self.EFF_TIME_PRISON, 39, {})
		self.life = self.max_life * 0.1
	end,
}
