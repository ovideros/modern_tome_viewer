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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

load("/data-orcs/general/objects/objects.lua")

newEntity{ base = "BASE_LORE",
	define_as = "NOTE1",
	name = "a journal", lore="sunwall-observatory-1",
	desc = _t[[A journal.]],
	rarity = false,
	encumberance = 0,
}

newEntity{ base = "BASE_WIZARD_HAT", define_as = "CAP_UNDISTURBED_MIND",
	power_source = {arcane=true, psionic=true},
	unique = true,
	name = "Cap of the Undisturbed Mind",
	unided_name = _t"red cap",
	desc = _t[[To prevent losing your mental health when gazing at the horrors of the Void there are still living brain tissues embedded into this cap.
With it you can spend your time stargazing without fear.]],
	color = colors.RED, image = "object/artifact/cap_of_the_undisturbed_mind.png",
	level_range = {16, 25},
	plot = true, quest = true,
	rarity = 300,
	cost = 100,
	material_level = 3,
	special_desc = function(self) return _t"Allows you to resist the most terrible assaults on your mind." end,
	wielder = {
		combat_def = -10,
		combat_spellpower = -10,
		combat_mindpower = -10,
		combat_dam = -10,
		inc_stats = { [Stats.STAT_WIL] = 4 },
		confusion_immune = 1,
		mindwall_immune = 1,
		resists = {
			[DamageType.DARKNESS] = 10,
			[DamageType.ARCANE] = 10,
			[DamageType.COLD] = 10,
		},
	},
}

newEntity{ define_as = "YETI_ASTRAL_MUSCLE",
	power_source = {arcane=true},
	unique = true,
	type = "flesh", subtype="muscle",
	unided_name = _t"flesh",
	name = "Yeti's Muscle Tissue (Astral)",
	level_range = {1, 1},
	display = "*", color=colors.VIOLET, image = "object/yeti_muscle_tissue.png",
	encumber = 1,
	plot = true, quest = true,
	yeti_muscle_tissue = true,
	desc = _t[[Muscle tissue, extracted from a powerful yeti. Somewhere, somebody or something is bound to be interested!]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,

	on_pickup = function(self, who)
		game.player:grantQuest("orcs+weissi")
	end,
}
