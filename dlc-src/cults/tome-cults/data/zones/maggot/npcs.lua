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

load("/data-cults/general/npcs/blobs.lua", function(e)
	if not e.name then return end
	if not e.inc_damage then e.inc_damage = {} end
	e.inc_damage.all = (e.inc_damage.all or 0) - 15
end)
--load("/data/general/npcs/all.lua", rarity(4, 35))

newEntity{ define_as = "SPINAL_CORD",
	unique=true, rank=4,
	base = "BASE_NPC_BLOB", color=colors.PURPLE,
	name = "The Spinal Cord",
	desc = _t[[One of the centers of the nervous system of the Maggot, if severed the Maggot will surely wither and die.]],
	image = "terrain/spinal_cord/spinal_cord_head_top_a_02.png",
	level_range = {7, nil}, exp_worth = 2,
	rarity = false,
	max_life = resolvers.rngavg(270,300), life_rating = 18, fixed_rating = true,
	combat_armor = 7, combat_def = 0,
	combat = { dam=resolvers.levelup(9, 1, 1), atk=15, apr=6 },
	stats = { str=22, wil=22, mag=22 },
	never_move = 1,
	tier1 = true,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	never_move = 1,
	immune_possession = 1,
	vim_regen = 8,
	
	inc_damage = {all=-25},
	resolvers.talents{
		[Talents.T_BONE_SPEAR]={base=1, every=5, max=8},
		[Talents.T_DARK_WHISPERS]={base=1, every=6, max=6},
		[Talents.T_BONE_GRAB]={base=1, every=8, max=5},
	},
	talent_cd_reduction = {
		[Talents.T_BONE_GRAB] = 10, -- He cant move, so he can grab !
	},
	
	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1 },
	ai_tactic = resolvers.tactic"ranged",
	
	resolvers.drops{chance=100, nb=1, {defined="SPINAL_CAGE", random_art_replace={chance=50}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("cults+start-cults", engine.Quest.COMPLETED, "worm")

		local map = game.level.map
		local g_list = game.zone.grid_list
		for i = 0, map.w - 1 do for j = 0, map.h - 1 do
			local g = map(i, j, map.TERRAIN)
			if g.is_maggot_spine and g.define_as then
				map(i, j, map.TERRAIN, g_list["DEAD_"..g.define_as])
				if i >= map.mx and i < map.mx + map.viewport.mwidth and j >= map.my and j < map.my + map.viewport.mheight then
					map:particleEmitter(i, j, 1, "blood")
				end
			end
		end end
		if self.x then
			map(self.x, self.y, map.TERRAIN, g_list["DEAD_MAGGOT_SPINE_HEAD"])
			map:particleEmitter(self.x, self.y, 1, "blood")
		end
	end,
}
