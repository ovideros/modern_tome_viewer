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
	name = _t"A cave from ages old",
	level_range = {1, 1},
	level_scheme = "player",
	is_cults_book = "book-texture-fire", no_worldport = true,
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
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			zoneclass= true,
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
	levels =
	{
		[1] = {
			width = 20, height = 20,
			generator = { map = {
				class = "engine.generator.map.Cavern",
				zoom = 16,
				min_floor = 200,
				floor = function() if rng.percent(95) then return "CAVEFLOOR" else return "DEAD_BODY" end end,
				wall = "CAVEWALL",
				up = "CAVEFLOOR",
				down = "CAVE_LADDER_DOWN",
				door = "CAVEFLOOR",
			}, },
		},
		[2] = {
			width = 40, height = 40,
			generator = { map = {
				class = "engine.generator.map.Cavern",
				zoom = 16,
				min_floor = 700,
				floor = function() if rng.percent(95) then return "CAVEFLOOR" else return "DEAD_BODY" end end,
				wall = "CAVEWALL",
				up = "CAVEFLOOR",
				down = "CAVE_LADDER_DOWN",
				door = "CAVEFLOOR",
			}, },
		},
		[3] = {
			generator = { map = {
				class = "engine.generator.map.Octopus",
				main_radius = {0.3, 0.4},
				arms_radius = {0.1, 0.2},
				arms_range = {0.7, 0.8},
				nb_rooms = {7, 7},
				['#'] = {
					"TREE",
					"UNDERGROUND_TREE",
				},
				['.'] = function() if rng.percent(95) then return "UNDERGROUND_FLOOR" else return "UNDERGROUND_DEAD_BODY" end end,
				up = "UNDERGROUND_FLOOR",
				down = "WAY_HOME",
				door = "UNDERGROUND_FLOOR",
				force_last_stair = true,
			}, },
		},
	},

	food_collected = 0,
	specific_ui = function(ui, zone, x, y)
		if not zone.food_collected then return end
		local UI = require "engine.ui.Base"

		if not zone._tmp_data.frame then zone._tmp_data.frame = UI:makeFrame("ui/tooltip/", 200, 70) end

		if not zone._tmp_data.tex or zone._tmp_data.last_count ~= zone.food_collected then
			local FontPackage = require "engine.FontPackage"
			if not zone._tmp_data.font then zone._tmp_data.font = core.display.newFont(FontPackage:getFont("insular", "default"), 16) end
			local text = ("%d Food Collected"):tformat(zone.food_collected)
			local c = colors.GREY
			if zone.food_collected >= 30 then c = colors.LIGHT_GREEN
			elseif zone.food_collected >= 10 then c = colors.YELLOW
			end
			zone._tmp_data.tex, zone._tmp_data.nblines, zone._tmp_data.wline = zone._tmp_data.font:draw(text, text:toTString():maxWidth(zone._tmp_data.font), colors.unpack(c))
			zone._tmp_data.last_count = zone.food_collected
		end

		zone._tmp_data.frame.w = zone._tmp_data.wline + 60
		zone._tmp_data.frame.h = math.max(zone._tmp_data.tex[1].h * zone._tmp_data.nblines + 16, 50)
		UI:drawFrame(zone._tmp_data.frame, x, y, 1, 1, 1, 0.65)
		for i = 1, #zone._tmp_data.tex do
			local item = zone._tmp_data.tex[i]
			item._tex:toScreenFull(x + 10, y + (zone._tmp_data.frame.h - zone._tmp_data.tex[1].h) / 2, item.w, item.h, item._tex_w, item._tex_h)
			y = y + item.h
		end
	end,

	on_enter = function(lev)
		if lev == 1 then
			game.player:grantQuest("cults+grung")
			require("engine.ui.Dialog"):simpleLongPopup(_t"Hungry", _t[[It's a cold night and you did not find anything to eat during the day. Your fur pelt doesn't do much to keep the cold out either. You're about to go out to hunt, but everyone else has warned you that you must not do that. The night is dangerous and there appears to be strange lights in the sky. An ill omen, to say the least. Food has been hard to come by lately, so everyone is just as famished as you are.

The many tentacled ones who sometimes come down from the sky to look at you say that they are going to battle with themselves. You did not really understand why they would fight among themselves, even as it tried to explain it to you. You reconsider the idea of going outside when its warnings come across your mind, but the rumbling in your belly renews your resolve. Everyone in your tribe tonight must eat, no matter what.]], 600)
		end
	end,

	grung_emotes_cooldown = {},
	grung_emote = function(grung, kind)
		local emotes = {
			dead_tentacles = { chance = 3, cooldown = 10,
				_t"Why is there a dead tentacled one here?",
				_t"Corpses are raining from the sky...",
				_t"The many tentacled ones are piling on the ground, forming mass graves.",
			},
			watch_fight = { chance = 3, cooldown = 10,
				_t"What are these things?!",
				_t"Your primitive mind recoils in horror from the thing in front of you.",
				_t"Why are they killing each other? For what reason does this horror have to happen?",
				_t"You have fought against other tribes before, but the bloodshed you saw then is nothing compared to this.",
				_t"You do not have the words you need to articulate your horror.",
			},
			watch_horror = { chance = 3, cooldown = 10,
				_t"Are the many tentacled ones using these creatures against each another?",
				_t"Little of what you're seeing makes sense to you. You simply don't have the words to articulate the terror you're feeling.",
				_t"Why are they killing each other? For what reason does this horror have to happen?",
				_t"You have fought against other tribes before, but the bloodshed you saw then is nothing compared to this.",
			},
			shakes = { chance = 3, cooldown = 10,
				_t"Great blasts of light come from the sky.",
				_t"Indescribable things are emerging from the darkness.",
				_t"Looking up, you see something writhing between the stars. You look away before curiosity gets the better of you.",
				_t"The lights nearly blind you as cascades of swirling colours explode in the darkness above your head.",
			},
			food = { chance = 3, cooldown = 10,
				_t"Terrified by the carnage around it, the rabbit has become easy prey.",
				_t"A good little meal, but you will need more than this.",
				_t"Meat has been a rare treat as of late.",
			},
		}
		if not emotes[kind] then return end
		if not rng.chance(emotes[kind].chance) then return end
		game.zone.grung_emotes_cooldown[kind] = game.zone.grung_emotes_cooldown[kind] or game.turn - 100000
		if game.turn < game.zone.grung_emotes_cooldown[kind] + emotes[kind].cooldown * 10 then return end
		game.zone.grung_emotes_cooldown[kind] = game.turn
		local msg = rng.table(emotes[kind])
		grung:setEmote(require("engine.Emote").new(msg, 120, colors.BLACK))
		game.log("#ANTIQUE_WHITE#Grung: %s", msg)
	end,

	on_turn = function(zone)
		if game.turn % 10 ~= 0 then return end
		if rng.chance(25) then
			game:shakeScreen(30, 5)
			for i = 1, rng.range(1, 3) do
				game.level.map:particleEmitter(game.player.x, game.player.y, 200, "grung_civil_war_flash", {width=engine.Map.viewport.width, height=engine.Map.viewport.height})
			end
			game:playSoundNear(self, "talents/thunderstorm")
			zone.grung_emote(game.player, "shakes")
		end
	end,
}
