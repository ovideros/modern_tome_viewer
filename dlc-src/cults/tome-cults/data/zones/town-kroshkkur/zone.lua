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
	name = _t"Kroshkkur, the Hidden Sanctuary",
	level_range = {1, 15},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 1,
	width = 60, height = 60,
	decay = {300, 800, only={object=true}, no_respawn=true},
	persistent = "zone",
	-- all_remembered = true,
	all_lited = true,
	-- Apply a greenish tint to all the map
	color_shown = {0.5, 1, 0.7, 1},
	color_obscure = {0.5*0.6, 1*0.6, 0.7*0.6, 0.6},
	ambient_music = {"cults/kroshkkur.ogg", "weather/town_small_base.ogg"},
	allow_respec = "limited",
	max_material_level = 2,
	store_levels_by_restock = { 8, 25, 40 },
	auto_zone_stair = true,

	generator =  {
		map = {
			class = "mod.class.generator.map.StaticPredrawn",
			map = "!town",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {10, 10},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},

	on_enter = function()
		if not game.player:knowTalent(game.player.T_TELEPORT_KROSHKKUR) then
			game.player:learnTalent(game.player.T_TELEPORT_KROSHKKUR, true, nil, {no_unlearn=true})
		end
	end,

	on_leave = function(lev, old_lev, newzone)
		if not newzone then return end
		if newzone.short_name == "cults+maggot" then return end
		local p = game:getPlayer(true)
		if not p:hasQuest("cults+start-cults") then return end
		if not p:isQuestStatus("cults+start-cults", engine.Quest.PENDING) then return end
		if p:hasEffect(p.EFF_SAVE_KROSHKKUR) then return end

		p:setEffect(p.EFF_SAVE_KROSHKKUR, 998, {threat=_t"The Maggot", quest="cults+start-cults"})
	end,

	post_process = function(level, zone)
		local CultsDLC = require "mod.class.CultsDLC"
		local list = CultsDLC.makeGlyphsSequence()
		CultsDLC.registerGlyphsSequence(list, "DREM_ORIGIN")

		local spots = {}
		for i = 1, 4 do spots[#spots+1] = level:pickSpotRemove{type="spawn", subtype="glyphs"} end
		table.sort(spots, function(a, b) return a.x < b.x end)

		for i, spot in ipairs(spots) do
			CultsDLC.burnGlyphOnTerrain(zone, level, spot.x, spot.y, list[i])
		end
	end,

	foreground = function(level, dx, dx, nb_keyframes)
		local noise = level.tmpdata.noise
		if not noise then
			level.tmpdata.noise = core.noise.new(1)
			noise = level.tmpdata.noise
		end

		local tick = core.game.getTime()

		-- The lerping index between colors
		local x = (1 + noise:fbm_perlin(tick/10000, 4)) / 2

		-- The blackness factor, always lowish except on sudden spikes
		local spike = (1 + noise:fbm_perlin(tick/1000, 4)) / 2
		spike = 1-10^(spike*2)/100

		local c = colors.lerp(colors.YELLOW_GREEN, colors.ROYAL_BLUE, x)
		c[1], c[2], c[3] = c[1] * spike, c[2] * spike, c[3] * spike

		level.map:setShown(c[1], c[2], c[3], 1)
		level.map:setObscure(c[1] * 0.6, c[2] * 0.6, c[3] * 0.6, 1)
	end,
}
