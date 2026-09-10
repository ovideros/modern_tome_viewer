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

-- last updated: 9:25 AM 2/5/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_STEAM_GIANT_ARCANE",
	type = "giant", subtype = "steam",
	display = "P", color=colors.BLUE,
	faction = "atmos-tribe",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=2, {type="money"} },
	infravision = 10,
	lite = 1,

	resolvers.inscriptions(1, {"manasurge rune"}),

	life_rating = 14,
	rank = 2,
	size_category = 4,

	open_door = true,

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=15, dex=8, mag=22, con=13 },
	power_source = {arcane=true},
}

newEntity{ base = "BASE_STEAM_GIANT_ARCANE", define_as = "STEAM_GIANT_NECROPSYCH_GHOST",
	name = "necropsych's ghost", color=colors.GREY,
	type = "undead", subtype = "ghost", display = 'G',
	desc = _t[[The spirit of a recently deceased necropsych. It moans painfully but seems impervious to most worldly things.]],
	resolvers.nice_tile{tall=1},
	level_range = {30, nil}, exp_worth = 0,
	rarity = false,
	rank = 2,
	max_life = 1, life_rating = 1, invulnerable = 1,
	autolevel = "wildcaster",
	resolvers.talents{
		[Talents.T_MIND_SEAR]={base=3, every=6, max=10},
	},
	ai_state = {talent_in=1},
}

newEntity{ base = "BASE_STEAM_GIANT_ARCANE",
	name = "steam giant necropsych", color=colors.GREY,
	desc = _t[[Covered in arcane runes of death, this steam giant means business.]],
	resolvers.nice_tile{tall=1},
	level_range = {30, nil}, exp_worth = 1,
	rarity = 7,
	rank = 3,
	max_life = resolvers.rngavg(150, 200),
	resolvers.auto_equip_filters("Necromancer"),
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{
		[Talents.T_STAFF_MASTERY]={base=2, every=6, max=5},
		[Talents.T_IMPENDING_DOOM]={base=3, every=6, max=10},
		[Talents.T_BLURRED_MORTALITY]={base=3, every=6, max=10},
		[Talents.T_FLASH_FREEZE]={base=3, every=6, max=10},
		[Talents.T_ETERNAL_NIGHT]={base=3, every=6, max=10},
		[Talents.T_CIRCLE_OF_DEATH]={base=3, every=6, max=10},
		[Talents.T_RIGOR_MORTIS]={base=3, every=6, max=10},
		[Talents.T_TINKER_TOXIC_CANNISTER_LAUNCHER]={base=3, every=6, max=10},
		[Talents.T_DREAM_HAMMER]={base=3, every=6, max=10},
		[Talents.T_HAMMER_TOSS]={base=3, every=6, max=10},
	},
	resolvers.sustains_at_birth(),
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	ai_tactic=resolvers.tactic("ranged"),

	on_die = function(self, who)
		local ghost = game.zone:makeEntityByName(game.level, "actor", "STEAM_GIANT_NECROPSYCH_GHOST", nil, true)
		if not ghost then return end

		ghost.summon_time = rng.range(8, 15)
		ghost.ai = "summoned"
		ghost.ai_real = "dumb_talented_simple"
		ghost.summoner = self

		game.zone:addEntity(game.level, ghost, "actor", self.x, self.y)
		game.logSeen(ghost, "#LIGHT_DARK#As %s falls you see its spirit rising for revenge.", self:getName())
		if who then ghost:setTarget(who) end
		game.level.map:particleEmitter(ghost.x, ghost.y, 2, "ball_death", {radius=2})
	end,
}

newEntity{ base = "BASE_STEAM_GIANT_ARCANE",
	name = "steam giant blood carver", color=colors.CRIMSON,
	desc = _t[[Blood seems to ooze from the towering giant, yet seemingly to no ill effect.]],
	resolvers.nice_tile{tall=1},
	level_range = {30, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	max_life = resolvers.rngavg(150, 200),
	resolvers.auto_equip_filters("Corruptor"),
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="light", autoreq=true},
	},
	combat_armor = 0, combat_def = 6,
	resolvers.talents{
		[Talents.T_STAFF_MASTERY]={base=2, every=6, max=5},
		[Talents.T_BLOOD_SPRAY]={base=3, every=6, max=10},
		[Talents.T_BLOOD_GRASP]={base=3, every=6, max=10},
		[Talents.T_BLOOD_BOIL]={base=3, every=6, max=10},
		[Talents.T_PESTILENT_BLIGHT]={base=3, every=6, max=10},
		[Talents.T_BLOOD_SPLASH]={base=3, every=6, max=10},
		[Talents.T_CALL_SHADOWS]={base=3, every=6, max=10},
	},
	resolvers.sustains_at_birth(),
	ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
	ai_tactic = {type = "close_range", defend=2, disable=3, heal=2, safe_range=2},
}
