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

newEntity{
	define_as = "BASE_NPC_HORROR",
	type = "horror", subtype = "eldritch",
	display = "h", color=colors.WHITE,
	blood_color = colors.BLUE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	faction = "horrors",

	stats = { str=20, dex=20, wil=20, mag=20, con=20, cun=20 },
	combat_armor = 5, combat_def = 10,
	combat = { dam=5, atk=10, apr=5, dammod={str=0.6} },
	infravision = 10,
	max_life = resolvers.rngavg(10,20),
	rank = 2,
	size_category = 3,

	no_breath = 1,
	fear_immune = 1,
}

newEntity{ base = "BASE_NPC_HORROR", define_as = "THE_ONE_THAT_HUNTS",
	name = "The One That Hunts", color=colors.GREEN,
	desc = "And your thought radiant horrors were bad.",
	level_range = {1, nil}, exp_worth = 0,
	rank = 3,
	autolevel = "caster",
	max_life = 400, life_rating = 25,
	combat = { dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 0.5), atk=500, apr=0, dammod={mag=0.7} },
	ai = "tactical", ai_state = { ai_target="target_player", ai_move="move_complex", talent_in=1, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1 }, -- We needs hands for the left one to be free for tentacle combat to work

	resists = {all = 90 },
	damage_affinity = { [DamageType.LIGHT] = 50,  [DamageType.FIRE] = 50, },
	mana_regen = 20, insanity_regen = 20,
	max_mana = 500,

	see_invisible = 20,
	ignore_from_combat_compute = true, -- Otherwise we cant ever leave combat to despawn it lol ;)

	resolvers.talents{
		[Talents.T_MUTATED_HAND]={base=1, every=10},
		[Talents.T_TENDRILS_ERUPTION]={base=1, every=7},
		[Talents.T_COLD_FLAMES]={base=1, every=7},
		[Talents.T_CIRCLE_OF_DEATH]={base=1, every=7},
		[Talents.T_INVISIBILITY]={base=1, every=5},
	},
	resolvers.sustains_at_birth(),

	test = DamageType.FIRE,

	-- Can't ever loose it!
	on_act = function(self)
		if self.disappear_in then
			self.disappear_in = self.disappear_in - 1
			if self.disappear_in < 0 then
				self.is_gone = true
				game:onTickEnd(function() self:disappear(self) end)
				return
			end
		end

		if not game.player or not game.player.x or not self.x then return end
		if core.fov.distance(self.x, self.y, game.player.x, game.player.y) <= 10 then return end
		self:teleportRandom(game.player.x, game.player.y, 5)
	end,
}
