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

return {
	name = _t"Internment Camp",
	display_name = function(x, y)
		if game.level.level == 2 then return _t"Internment Camp (Rak'Shor)" end
		if game.level.level == 3 then return _t"Internment Camp (Vor)" end
		if game.level.level == 4 then return _t"Internment Camp (Gorbat)" end
		if game.level.level == 5 then return _t"Internment Camp (Grushnak)" end
		return _t"Strange Clearing"
	end,
	variable_zone_name = true,
	level_range = {20, 25},
	level_scheme = "player",
	max_level = 6,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	all_lited = true,
	day_night = true,
	persistent = "zone",
	ambient_music = "orcs/internment.ogg",
	min_material_level = 2,
	max_material_level = 3,
	generator =  {
		map = {
			class = "engine.generator.map.Building",
			max_block_w = 20, max_block_h = 20,
			max_building_w = 10, max_building_h = 10,
			floor = function() return rng.percent(95) and "UNDERGROUND_FLOOR" or "BURNT_TREE" end,
			external_floor = "UNDERGROUND_FLOOR",
			wall = "WOODEN_BARRICADE",
			up = "UNDERGROUND_FLOOR",
			down = "UNDERGROUND_FLOOR",
			door = "UNDERGROUND_FLOOR",
			force_last_stair = true,
			lite_room_chance = 100,
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				class = "engine.generator.map.Static",
				map = "orcs+zones/internment-camp",
			}, actor = {
				nb_npc = {0, 0},
			}, object = {
				nb_object = {0, 0},
			}, },
		},
		[2] = {
			camp = "rak-shor-pride",
			generator = { map = {
				edge_entrances = {4, 6},
				up = "TO_MAIN_FROM_RAKSHOR", down = "UNDERGROUND_FLOOR",
			}, actor = {
				class = "mod.class.generator.actor.RandomStairGuard",
				guard = {{define_as="MINDCONTROL_PILLAR", special_rarity="pillar_rarity"}},
				filters = {{type="giant", subtype="ogre"}, {type="humanoid", subtype="orc", special=function(e) return e.pride == "rak-shor" end}, {type="humanoid", subtype="orc", special=function(e) return e.pride == "rak-shor" end}, {type="humanoid", subtype="orc", special=function(e) return e.pride == "rak-shor" end}},
			}, },
		},
		[3] = {
			camp = "vor-pride",
			generator = { map = {
				edge_entrances = {2, 8},
				up = "TO_MAIN_FROM_VOR", down = "UNDERGROUND_FLOOR",
			}, actor = {
				class = "mod.class.generator.actor.RandomStairGuard",
				guard = {{define_as="MINDCONTROL_PILLAR", special_rarity="pillar_rarity"}},
				filters = {{type="giant", subtype="ogre"}, {type="humanoid", subtype="orc", special=function(e) return e.pride == "vor" end}, {type="humanoid", subtype="orc", special=function(e) return e.pride == "vor" end}, {type="humanoid", subtype="orc", special=function(e) return e.pride == "vor" end}},
			}, },
		},
		[4] = {
			camp = "gorbat-pride",
			generator = { map = {
				edge_entrances = {8, 2},
				up = "TO_MAIN_FROM_GORBAT", down = "UNDERGROUND_FLOOR",
			}, actor = {
				class = "mod.class.generator.actor.RandomStairGuard",
				guard = {{define_as="MINDCONTROL_PILLAR", special_rarity="pillar_rarity"}},
				filters = {{type="giant", subtype="ogre"}, {type="humanoid", subtype="orc", special=function(e) return e.pride == "gorbat" end}, {type="humanoid", subtype="orc", special=function(e) return e.pride == "gorbat" end}, {type="humanoid", subtype="orc", special=function(e) return e.pride == "gorbat" end}},
			}, },
		},
		[5] = {
			camp = "grushnak-pride",
			generator = { map = {
				edge_entrances = {6, 4},
				up = "TO_MAIN_FROM_GRUSHNAK", down = "UNDERGROUND_FLOOR",
			}, actor = {
				class = "mod.class.generator.actor.RandomStairGuard",
				guard = {{define_as="MINDCONTROL_PILLAR", special_rarity="pillar_rarity"}},
				filters = {{type="giant", subtype="ogre"}, {type="humanoid", subtype="orc", special=function(e) return e.pride == "grushnak" end}, {type="humanoid", subtype="orc", special=function(e) return e.pride == "grushnak" end}, {type="humanoid", subtype="orc", special=function(e) return e.pride == "grushnak" end}},
			}, },
		},
	},
	post_process = function(level)
		-- Setup zones
		for _, z in ipairs(level.custom_zones or {}) do
			if z.type == "no-teleport" then
				for x = z.x1, z.x2 do for y = z.y1, z.y2 do
					game.level.map.attrs(x, y, "no_teleport", true)
				end end
			end
		end

		game:placeRandomLoreObjectScale("NOTE", {{}, {1}, {2}, {3}, {4}}, level.level)
	end,
	free_orcs = function()
		for uid, e in pairs(game.level.entities) do if e.subdued_orc then
			e.subdued_orc = nil
			e.name = e.name:gsub(" %(subdued%)", "")
			e.faction = "orc-pride"
			e.emote_random = nil
			e:setTarget(nil)
			e:doEmote(_t"Freedom! Let's rally to Kruk Pride!")
		end end
	end,
	reveal_truth = function()
		local map = game.level.map
		for x = 0, map.w - 1 do for y = 0, map.h - 1 do
			local g = map(x, y, map.TERRAIN)
			if g and not g.change_level then
				local ng
				if g.type == "wall" then ng = game.zone.grid_list.WOODEN_BARRICADE
				else ng = game.zone.grid_list.UNDERGROUND_FLOOR end
				map(x, y, map.TERRAIN, ng)
			end
		end end
		while true do
			local spot = game.level:pickSpotRemove{type="pop", subtype="door"}
			if not spot then break end
			map(spot.x, spot.y, map.TERRAIN, game.zone.grid_list.UNDERGROUND_FLOOR)
		end

		game.nicer_tiles:postProcessLevelTiles(game.level)
		require("engine.ui.Dialog"):simpleLongPopup(_t"Mindwall", _t[[Mindwall's will falters and reveals the truth about your surroundings.

As Mindwall's body crumbles you can sense a burst of psionic forces splitting up and flying to new hosts.]], 600)
	end,
}
