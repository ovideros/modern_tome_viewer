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
	name = _t"The Teacher's Abode",
	level_range = {1, 1},
	level_scheme = "player",
	is_cults_book = "book-texture-impossible", no_worldport = true,
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
--	all_lited = true,
--	day_night = true,
	-- persistent = "zone",
	ambient_music = {"The Ancients.ogg"},
	min_material_level = 1,
	max_material_level = 1,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "!school",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},

	specific_ui = function(ui, zone, x, y)
		if not zone.current_lesson or zone.current_lesson < 1 or zone.current_lesson > 4 then return end
		local UI = require "engine.ui.Base"

		if not zone._tmp_data.frame then zone._tmp_data.frame = UI:makeFrame("ui/tooltip/", 200, 80) end

		if not zone._tmp_data.tex or zone._tmp_data.last_lesson ~= zone.current_lesson or zone.update_lesson then
			local FontPackage = require "engine.FontPackage"
			if not zone._tmp_data.font then zone._tmp_data.font = core.display.newFont(FontPackage:getFont("insular", "default"), 16) end
			local text
			if zone.current_lesson == 1 then
				text = ("Lesson 1: Entropic Gift\n%d/3 entropic gifts used"):tformat(zone.lesson1_effects)
			elseif zone.current_lesson == 2 then
				text = ("Lesson 2: Netherblast\n%d/4 netherblasts used"):tformat(zone.lesson2_hits)
			elseif zone.current_lesson == 3 then
				text = ("Lesson 3: Fatebreaker\n%d/2 fatebreakers used"):tformat(zone.lesson3_cast)
			elseif zone.current_lesson == 4 then
				text = _t"Lesson 4: Unravel Existence\nCoordonate with students"
			end
			local c = colors.YELLOW
			zone._tmp_data.tex, zone._tmp_data.nblines, zone._tmp_data.wline = zone._tmp_data.font:draw(text, text:toTString():maxWidth(zone._tmp_data.font), colors.unpack(c))
			zone._tmp_data.last_lesson = zone.current_lesson
			zone.update_lesson = nil
		end

		zone._tmp_data.frame.w = zone._tmp_data.wline + 60
		zone._tmp_data.frame.h = math.max(zone._tmp_data.tex[1].h * zone._tmp_data.nblines + 16, 120)
		UI:drawFrame(zone._tmp_data.frame, x, y, 1, 1, 1, 0.65)
		for i = 1, #zone._tmp_data.tex do
			local item = zone._tmp_data.tex[i]
			item._tex:toScreenFull(x + 10, y + (zone._tmp_data.frame.h - zone._tmp_data.tex[1].h) / 2, item.w, item.h, item._tex_w, item._tex_h)
			y = y + item.h
		end
	end,

	on_turn = function(zone)
		if game.turn % 10 ~= 0 then return end
		if zone.just_entered then zone.just_entered = false return end

		if zone.current_lesson == 0 then
			game.party:learnLore("cults-cultist-unlock-lesson-1")
			zone.current_lesson = 1
			zone.lesson1_effects = 0
		end
	end,

	to_lesson2 = function(zone)
		if zone.lesson1_effects >= 3 then
			game.party:learnLore("cults-cultist-unlock-lesson-2")
			zone.current_lesson = 2
			zone.lesson2_hits = 0
			for uid, e in pairs(game.level.entities) do if e.is_student then
				e:learnTalent(e.T_NETHERBLAST, 1, 1)
			end end
		end
	end,

	to_lesson3 = function(zone)
		if zone.lesson2_hits >= 4 then
			game.party:learnLore("cults-cultist-unlock-lesson-3")
			zone.current_lesson = 3
			zone.lesson3_cast = 0
			for uid, e in pairs(game.level.entities) do if e.is_student then
				e:learnTalent(e.T_FATEBREAKER, 1, 1)
			end end
		end
	end,

	to_lesson4 = function(zone)
		if zone.lesson3_cast >= 2 then
			game.party:learnLore("cults-cultist-unlock-lesson-4")
			zone.current_lesson = 4
			for uid, e in pairs(game.level.entities) do if e.is_student then
				if e.is_hithre then
					e:learnTalent(e.T_NIHIL, 1, 5)
					e:learnTalent(e.T_UNRAVEL_EXISTENCE, 1, 5)
					e.on_unravel_existence_npc = function(self)
						-- Switch dummies faction so that the hypostatis doesnt attack them stupidly
						for uid, e in pairs(game.level.entities) do if e.training_dummy then e.invulnerable = 1 e.faction = "neutral" end end
						game.party:learnLore("cults-cultist-unlock-lesson-4-fail")
						local m = game.zone:makeEntityByName(game.level, "actor", "HYPOSTASIS", true)
						game.zone.book_source.book_ended = true
						return m
					end					
				else
					e:learnTalent(e.T_DARK_WHISPERS, 1, 1)
				end
			end end
		end
	end,

	on_enter = function(lev)
		game.party:learnLore("cults-cultist-unlock-intro")
		game.zone.current_lesson = 0
		game.zone.just_entered = true
	end,
}
