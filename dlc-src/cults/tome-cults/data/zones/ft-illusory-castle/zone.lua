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

local possible_colors = { "ORANGE", "LIGHT_BLUE", "AQUAMARINE", "GOLD", "LIGHT_STEEL_BLUE", "FIREBRICK", "PINK", "ORCHID", "PURPLE", "VIOLET", "HONEYDEW", "ANTIQUE_WHITE", "OLIVE_DRAB", "DARK_SEA_GREEN", "YELLOW_GREEN", "KHAKI" }

local possible_names = {
	_t"Nervous Energy",
	_t"Prosthetic Conscience",
	_t"The Ends Of Invention",
	_t"Irregular Apocalyse",
	_t"No More Mr Nice Guy",
	_t"Profit Margin",
	_t"Trade Surplus",
	_t"Flexible Demeanour",
	_t"Just Read The Instructions",
	_t"Of Course I Still Love You",
	_t"Limiting Factor",
	_t"Cargo Cult",
	_t"Little Rascal",
	_t"So Much For Subtlety",
	_t"Unfortunate Conflict Of Evidence",
	_t"Youthful Indiscretion",
	_t"Gunboat Diplomat",
	_t"Zealot",
	_t"Kiss My Ass",
	_t"Prime Mover",
	_t"Just Testing",
	_t"Xenophobe",
	_t"Very Little Gravitas Indeed",
	_t"What Are The Civilian Applications?",
	_t"Congenital Optimist",
	_t"Size Isn't Everything",
	_t"Sweet and Full of Grace",
	_t"Different Tan",
	_t"Fate Amenable To Change",
	_t"Grey Area",
	_t"It's Character Forming",
	_t"Jaundiced Outlook",
	_t"Problem Child",
	_t"Reasonable Excuse",
	_t"Recent Convert",
	_t"Tactical Grace",
	_t"Unacceptable Behaviour",
	_t"Steely Glint",
	_t"Highpoint",
	_t"Shoot Them Later",
	_t"Attitude Adjuster",
	_t"Killing Time",
	_t"Frank Exchange Of Views",
	_t"Death and Gravity",
	_t"Ethics Gradient",
	_t"Honest Mistake",
	_t"Quietly Confident",
	_t"Sleeper Service",
	_t"Uninvited Guest",
	_t"Use Psychology",
	_t"What Is The Answer and Why?",
	_t"Wisdom Like Silence",
	_t"Zero Gravitas",
	_t"Serious Callers Only",
	_t"Not Invented Here",
}
local levels_names = {}
while #levels_names < 14 do levels_names[#levels_names+1] = rng.tableRemove(possible_names) end

local possible_maps = {
	{
		inner_width = 15, inner_height = 15,
		generator = { map = {
			realclass = "engine.generator.map.Maze",
			door = "GLASSDOOR",
			floor = "SOLID_FLOOR",
			wall = "GLASSWALL",
		}, },
	},
	{
		inner_width = 15, inner_height = 15,
		generator = { map = {
			realclass = "engine.generator.map.TileSet",
			tileset = {"3x3/base", "3x3/tunnel", "3x3/windy_tunnel"},
			tunnel_chance = 100,
			center_room = 1,
			['.'] = "SOLID_FLOOR",
			['#'] = "GLASSWALL",
			['+'] = "GLASSDOOR",
			["'"] = "GLASSDOOR",
		}, },
	},
	{
		inner_width = 14, inner_height = 14,
		generator = { map = {
			realclass = "engine.generator.map.Building",
			max_block_w = 7, max_block_h = 7,
			max_building_w = 3, max_building_h = 3,
			floor = "SOLID_FLOOR",
			external_floor = "SOLID_FLOOR",
			wall = "GLASSWALL",
			door = "GLASSDOOR",
		}, },
	},
	{
		no_level_connectivity = true,
		outerspace = true,
		inner_width = 70, inner_height = 70,
		generator = { map = {
			realclass = "engine.generator.map.Static",
			map = "!circle",
		}, },
	},
	entrance = {
		inner_width = 70, inner_height = 70,
		generator = { map = {
			realclass = "engine.generator.map.Static",
			map = "!entrance",
		}, },
	},
	final = {
		inner_width = 70, inner_height = 70,
		generator = { map = {
			realclass = "engine.generator.map.Static",
			map = "!final",
		}, },
	},
}

local paths = { left={2,3,4,5}, right={6,7,8,9}, main={10,11,12,13,14}}
local paths_rev = {}
local stairs = {
	[1] = {paths.main[1], paths.left[1], paths.right[1]},
	[paths.main[1]] = {1},
	[paths.left[1]] = {1},
	[paths.right[1]] = {1},
}

-- Generate main paths
for kind, list in pairs(paths) do
	for i = 1, #list - 1 do
		local lvl = list[i]
		local nextlvl = list[i+1]
		paths_rev[lvl] = kind
		stairs[lvl] = stairs[lvl] or {}
		stairs[nextlvl] = stairs[nextlvl] or {}
		table.insert(stairs[lvl], nextlvl)
		table.insert(stairs[nextlvl], lvl)
	end
	paths_rev[list[#list]] = kind
end

-- Add some sidetracking
for _, list in ipairs{paths.left, paths.right} do
	local lvl = list[#list]
	local nextlvl = paths.main[rng.range(1, #paths.main - 2)]
	table.insert(stairs[lvl], nextlvl) -- no direct way back
end

-- Generate level data
local levels_defs = {}
for lvl, links in pairs(stairs) do
	if lvl == 1 then levels_defs[lvl] = table.clone(possible_maps.entrance, true)
	elseif lvl == paths.main[#paths.main] then levels_defs[lvl] = table.clone(possible_maps.final, true)
	else levels_defs[lvl] = table.clone(rng.table(possible_maps), true) end

	-- First level has an exit to reality
	if lvl == 1 then levels_defs[lvl].generator.map.up = "BOOK_OUT" levels_defs[lvl].lore_nb = 1 end
	-- All levels but the first are not actually in the book
	if lvl > 1 then levels_defs[lvl].cults_book_suppress = true end
	-- Last level of the main branch is only accessible once the sidebranchs books have been closed
	if lvl == paths.main[#paths.main-1] then levels_defs[lvl].generator.map.guard_path_to = paths.main[#paths.main] end
	-- Last level of the branches, put the books of binding
	if lvl == paths.left[#paths.left] or lvl == paths.right[#paths.right] then levels_defs[lvl].generator.map.last_branch_level = true levels_defs[lvl].lore_nb = (lvl == paths.left[#paths.left]) and 2 or 3 end
	-- Last level of main branch, put no teleport zones
	if lvl == paths.main[#paths.main] then levels_defs[lvl].generator.map.last_main_level = true levels_defs[lvl].ambient_music = {"cults/illusory_castle_boss.ogg"} end

	-- Apply some random colorscheme to all levels but the first
	if lvl > 1 then
		local color_name = rng.tableRemove(possible_colors)
		local color = table.clone(colors.simple1(colors[color_name], 1))
		levels_defs[lvl].color_theme = color_name
		levels_defs[lvl].color_shown = color
		levels_defs[lvl].color_obscure = {color[1]*0.6, color[2]*0.6, color[3]*0.6, color[4]*0.6}
	end
end

-- print("=============ILLUSORY CASTLE LEVEL ORDER")
-- table.print(levels_names)
-- print("=============ILLUSORY STAIRS")
-- table.print(stairs)

return {
	name = _t"Illusory Castle",
	display_name = function(x, y)
		if game.zone.levels_names[game.level.level] then return ("Illusory Castle - %s"):tformat(game.zone.levels_names[game.level.level]) end
		return _t"Illusory Castle"
	end,
	level_range = {20, 40},
	level_scheme = "player",
	is_cults_book = "book-texture-illusory", no_worldport = true,
	max_level = #levels_names,
	levels_names = levels_names,
	paths_defs = paths,
	paths_rev = paths_rev,
	stairs_defs = stairs,
	decay = {300, 800},
	-- This does NOT add level.level, this is not an error as the zone has a "stupid" number of very small levels not even in order
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + rng.range(-1,2) end,
	width = 70, height = 70,
	-- all_remembered = true,
	-- all_lited = true,
--	day_night = true,
	persistent = "zone",
	ambient_music = {"cults/illusory_castle.ogg"},
	min_material_level = 2,
	max_material_level = 4,
	disabled_sidebranch = 0,
	generator =  {
		map = {
			class = "engine.Generator", zoneclass = true,
			up = "SOLID_FLOOR",
			down = "SOLID_FLOOR",
			exterior_wall = "GLASSWALL",
			base_stair = "BOOK_CHAPTER",
			book_binding = "BOOK_OF_BINDING",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {5, 10},
			guardian = "GLASS_GOLEM",
			guardian_spot = {type="guardian", subtype="guardian"},
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
	levels = levels_defs,

	post_process = function(level)
		if level.data.lore_nb then game:placeRandomLoreObject("NOTE"..level.data.lore_nb) end

		if level.data.outerspace then
			-- Cosmetic stuff
			game.state:makeWeather(level, 6, {max_nb=12, chance=1, dir=120, speed={1.5, 5.9}, r=0.2, g=0.4, b=1, alpha={0.2, 0.4}, particle_name="weather/grey_cloud_%02d"})

			if config.settings.tome.weather_effects then
				local Map = require "engine.Map"
				level.foreground_particle = require("engine.Particles").new("snowing", 1, {width=Map.viewport.width, height=Map.viewport.height, r=1, g=0.25, b=0.1, rv=-0.001, gv=0, bv=-0.001, factor=2, dir=math.rad(110+180)})
			end
		end

		-- Setup zones
		for _, z in ipairs(level.custom_zones or {}) do
			if z.type == "beam" and z.subtype == "beam" then
				if z.reverse then z.x1, z.x2, z.y1, z.y2 = z.x2, z.x1, z.y2, z.y1 end
				level.map:particleEmitter(z.x1, z.y1, math.max(z.x2-z.x1, z.y2-z.y1) * 2, "house_flamebeam", {
					tx = z.x2 - z.x1,
					ty = z.y2 - z.y1,
				})
				level.map:particleEmitter(z.x2, z.y2, math.max(z.x2-z.x1, z.y2-z.y1) * 2, "house_flamebeam", {
					tx = z.x1 - z.x2,
					ty = z.y1 - z.y2,
				})

				local g = game.level.map(z.x1, z.y1, engine.Map.TERRAIN):cloneFull()
				g.name = _t"illusory beam endpoint"
				g:removeAllMOs()
				g:altered()
				g.exit = {x=z.x2, y=z.y2}
				g.block_move = function(self, x, y, who, act)
					if not act or not who or not who.player then return true end
					local ox, oy = who.x, who.y
					game:onTickEnd(function()
						local x, y = util.findFreeGrid(self.exit.x, self.exit.y, 5, true, {[engine.Map.ACTOR]=true})
						if not x then x, y = self.exit.x, self.exit.y end
						who:move(x, y, true)
						if config.settings.tome.smooth_move > 0 then
							who:resetMoveAnim()
							who:setMoveAnim(ox, oy, 24, 5)
						end
					end)
					return true
				end
				game.zone:addEntity(game.level, g, "terrain", z.x1, z.y1)

				local g = game.level.map(z.x2, z.y2, engine.Map.TERRAIN):cloneFull()
				g.name = _t"illusory beam endpoint"
				g:removeAllMOs()
				g:altered()
				g.exit = {x=z.x1, y=z.y1}
				g.block_move = function(self, x, y, who, act)
					if not act or not who or not who.player then return true end
					local ox, oy = who.x, who.y
					game:onTickEnd(function()
						local x, y = util.findFreeGrid(self.exit.x, self.exit.y, 5, true, {[engine.Map.ACTOR]=true})
						if not x then x, y = self.exit.x, self.exit.y end
						who:move(x, y, true)
						if config.settings.tome.smooth_move > 0 then
							who:resetMoveAnim()
							who:setMoveAnim(ox, oy, 24, 5)
						end
					end)
					return true
				end
				game.zone:addEntity(game.level, g, "terrain", z.x2, z.y2)
			end
		end
	end,

	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)
	end,

	on_enter = function(lev)
		local p = game:getPlayer(true)

		if lev == 1 then p:grantQuest("cults+illusory-castle") end

		p:setEffect(p.EFF_ILLUSORY_CASTLE_MADNESS, 1, {})

		game.log('#%s#Welcome to chapter "%s"!', game.level.data.color_theme or "WHITE", game:getZoneName())

		if not game.zone.seen_suppressed_levels and lev > 1 then
			game.zone.seen_suppressed_levels = true
			require("engine.ui.Dialog"):simplePopup(_t"Illusory Castle", _t"Strange, it seems the book only serves as an entry to an actual physical zone... somewhere.")
		end
	end,

	on_leave = function(lev, old_lev, newzone)
		if not newzone then return end
		if newzone.short_name == "cults+ft-illusory-castle" then return end
		local p = game:getPlayer(true)
		p:removeEffect(p.EFF_ILLUSORY_CASTLE_MADNESS, true, true)
	end,
}
