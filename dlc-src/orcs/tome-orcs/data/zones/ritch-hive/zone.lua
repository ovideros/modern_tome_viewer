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
	name = _t"Ritch Hive",
	level_range = {12, 18},
	level_scheme = "player",
	max_level = 4,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	ambient_music = "orcs/insect.ogg",
	min_material_level = 2,
	max_material_level = 3,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer", zoneclass=true,
			nb_rooms = 10,
			edge_entrances = {4,6},
			rooms = {"forest_clearing"},
			lite_room_chance = 90,
			['.'] = "UNDERGROUND_SAND",
			['#'] = "SANDWALL",
			['-'] = "CRACKS",
			up = "SAND_LADDER_UP",
			down = "SAND_LADDER_DOWN",
			door = "UNDERGROUND_SAND",
			egg = "SAND_RITCH_EGGS",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {25, 35},
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
	levels = {
		[1] = {
			generator = { 
				map = { up = "SAND_LADDER_UP_WILDERNESS" },
				actor = {class = "engine.generator.actor.Random" },
			},
		},
		[3] = {
			no_autoexplore = true,
			no_level_connectivity = true,
			generator = { map = { no_tunnels = true, edge_entrances = false } },
		},
		[4] = {
			no_autoexplore = true,
			no_level_connectivity = true,
			width = 10, height = 130,
			generator = {
				map = {
					force_last_stair = true,
					no_tunnels = true,
					zoneclass = false,
					nb_rooms = 15,
					rooms = {"!gems", "!pit", "!mother"},
					edge_entrances = {2, 8},
					up = "SAND_LADDER_UP",
					down = "SAND_INCUBATOR",
				},
				actor = {
					nb_npc = {0, 0},
				},
			},
		},
	},
	on_turn = function(self)
		if game.level.level == 4 and self.ritches_collected >= 30 then
			local p = game:getPlayer(true)
			if p.y and p.y <= 10 and p:isQuestStatus("orcs+ritch-hive", engine.Quest.COMPLETED, "collect") then
				p:setQuestStatus("orcs+ritch-hive", engine.Quest.COMPLETED, "tunnel")
			end
		end
	end,

	on_enter = function(lev, old_lev, newzone)
		local Dialog = require("engine.ui.Dialog")
		if lev == 1 and not game.level.shown_warning and game.player:hasQuest("orcs+ritch-hive") then
			Dialog:simpleLongPopup(_t"Ritch Hive", _t[[You arrive in a maze of shifty sand tunnels.
But you have with you the power of technology! You have been given a #GOLD#Stralite Sand Shredder#LAST#. Use it to dig yourself a path should there be none to be found.
#{italic}#Simply walk into a wall with the shredder equipped and the sand will crumble before you!#{normal}#

Beware to not draw too much attention to yourself, and do not forget to collect the eggs!]], 600)
			game.level.shown_warning = true
		end
	end,

	ritches_collected = 0,

	specific_ui = function(ui, zone, x, y)
		local ritch = game.zone.grid_list.SAND_RITCH_EGGS_FOR_DISPLAY
		if not ritch then return end
		if not zone.ritches_collected then return end
		if game:getPlayer(true):isQuestStatus("orcs+ritch-hive", engine.Quest.DONE) then return end
		local UI = require "engine.ui.Base"

		if not zone._tmp_data.frame then zone._tmp_data.frame = UI:makeFrame("ui/tooltip/", 250, 70) end

		if not zone._tmp_data.tex or zone._tmp_data.last_count ~= zone.ritches_collected then
			local FontPackage = require "engine.FontPackage"
			if not zone._tmp_data.font then zone._tmp_data.font = core.display.newFont(FontPackage:getFont("default"), 18) end
			local text = ("%d Collected"):tformat(zone.ritches_collected)
			local c = colors.GREY
			if zone.ritches_collected >= 30 then c = colors.LIGHT_GREEN
			elseif zone.ritches_collected >= 10 then c = colors.YELLOW
			end
			zone._tmp_data.tex, zone._tmp_data.nblines, zone._tmp_data.wline = zone._tmp_data.font:draw(text, text:toTString():maxWidth(zone._tmp_data.font), colors.unpack(c))
			zone._tmp_data.last_count = zone.ritches_collected
		end

		zone._tmp_data.frame.w = zone._tmp_data.wline + 60
		zone._tmp_data.frame.h = math.max(zone._tmp_data.tex[1].h * zone._tmp_data.nblines + 16, 50)
		UI:drawFrame(zone._tmp_data.frame, x, y, 1, 1, 1, 0.65)
		ritch:toScreen(nil, x + 6, y + 6, 32, 32)
		for i = 1, #zone._tmp_data.tex do
			local item = zone._tmp_data.tex[i]
			item._tex:toScreenFull(x + 55, y + (zone._tmp_data.frame.h - zone._tmp_data.tex[1].h) / 2, item.w, item.h, item._tex_w, item._tex_h)
			y = y + item.h
		end
	end
}
