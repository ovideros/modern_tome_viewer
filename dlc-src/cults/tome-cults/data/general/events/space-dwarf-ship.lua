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

-- Unique throughout the game
if game.state:doneEvent(event_id) then return end

-- Find a random spot
local x, y = game.state:findEventGrid(level)
if not x then return false end

local id = "spacedwarf-ship-"..game.turn

print("[EVENT] Placing event", id, "at", x, y)

local changer = function(id)
	local npcs = mod.class.NPC:loadList{"/data/general/npcs/horrors.lua"}
	local objects = mod.class.Object:loadList("/data/general/objects/objects.lua")
	local terrains = {}

	terrains.MAP_FLOOR = mod.class.Grid.new{
		define_as = "MAP_FLOOR",
		type = "floor", subtype = "eerie",
		name = _t"floor",
		display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	}

	terrains.MAP_WALL = mod.class.Grid.new{
		define_as = "MAP_WALL",
		type = "wall", subtype = "eerie",
		name = _t"wall",
		display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
		always_remember = true,
		does_block_move = true,
		block_sight = true,
		air_level = -20,
	}

	terrains.MAP_SHIP = mod.class.Grid.new{
		define_as = "MAP_WALL",
		type = "wall", subtype = "eerie",
		name = _t"strange metallic capsule",
		display = '&', color_r=255, color_g=255, color_b=255, back_color=colors.BLUE,
		always_remember = true,
		block_move = function(self, x, y, e, act, couldpass)
			if e and e.player and act then
				if game.zone.searched_dwarf then
					require("engine.ui.Dialog"):simplePopup(_t"Strange metallic capsule", _t[[You have already scavenged what you could understand and use.]])
				else
					local base_list = require("mod.class.Object"):loadList("/data-cults/general/objects/special-misc.lua")
					base_list.__real_type = "object"
					local o = game.zone:makeEntityByName(game.level, base_list, "SPACE_DWARF_TRINKET")
					if not o then return end
					o:identify(true)
					e:addObject(e.INVEN_INVEN, o)
					game.zone.searched_dwarf = true
				
					require("engine.ui.Dialog"):simpleLongPopup(_t"Strange metallic capsule", _t[[The thing in front of you appears to be a strange dome made from green glass. Judging by the crater around it, this dome must have crashed into the earth with tremendous force. Stranger still is the figure seated inside it. It appears to be wearing a suit made of an unknown material and a glass dome over its head. Looking inside the dome, you can plainly see that the figure is a dwarf! There is no mistaking that oversized nose. Judging by the smell, he has been dead for quite some time.

You are fairly sure that the dwarves aren't capable of making something like this and they definitely don't dress like that. So, where did this odd dwarf come from? Taking a closer look, you find a strange device attached to the dwarf's arm. You remove it with no small amount of effort. It is completely unlike anything you have seen before and you're not really sure what to make of it. Perhaps if you hold onto it, you might be able to discern its functionality later.]], 600)
				end
			end
			return true
		end,
	}

	terrains.MAP_STAIR_UP = mod.class.Grid.new{
		define_as = "MAP_STAIR_UP",
		type = "floor", subtype = "eerie",
		name = _t"previous level",
		display = '<', color_r=255, color_g=255, color_b=0,
		notice = true,
		always_remember = true,
		change_level = -1,
		change_level_shift_back = true,
		change_zone_auto_stairs = true,
		name = ("ladder back to %s"):tformat(game.zone.name),
		change_zone = game.zone.short_name,
	}

	local zone = mod.class.Zone.new(id, {
		name = _t"Eerie Cave",
		level_range = game.zone.actor_adjust_level and {math.floor(game.zone:actor_adjust_level(game.level, game.player)*1.05),
			math.ceil(game.zone:actor_adjust_level(game.level, game.player)*1.15)} or {game.zone.base_level, game.zone.base_level}, -- 5-15% higher levels
		__applied_difficulty = true, --Difficulty already applied to parent zone
		level_scheme = "player",
		max_level = 1,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = 50, height = 50,
		ambient_music = "Sinestra.ogg",
		reload_lists = false,
		persistent = "zone",
		
		no_worldport = game.zone.no_worldport,
		min_material_level = util.getval(game.zone.min_material_level),
		max_material_level = util.getval(game.zone.max_material_level),
		generator =  {
			map = {
				class = "mod.class.generator.map.StaticPredrawn",
				map = "cults+spacedwarf-ship",
			},
			actor = {
				class = "mod.class.generator.actor.Random",
				nb_npc = {5, 5},
			},
			object = {
				class = "engine.generator.object.Random",
				filters = {{type="gem"}},
				nb_object = {3, 6},
			},
			trap = {
				class = "engine.generator.trap.Random",
				nb_trap = {0, 0},
			},
		},
		npc_list = npcs,
		grid_list = terrains,
		object_list = objects,
		trap_list = {},
	})
	return zone
end

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g.name = _t"eerie cave"
g.display='>' g.color_r=0 g.color_g=218 g.color_b=255 g.notice = true
g.always_remember = true
g.change_level=1 g.change_zone=id g.glow=true
g:removeAllMOs()
if engine.Map.tiles.nicer_tiles then
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/spaceship_cave_entrance.png", z=5}
end
g.nice_tiler = nil
g:altered()
g:initGlow()
g.real_change = changer
g.change_level_check = function(self)
	game:changeLevel(1, self.real_change(self.change_zone), {temporary_zone_shift=true, direct_switch=true})
	self.change_level_check = nil
	self.real_change = nil
	self.special_minimap = colors.VIOLET
	return true
end
game.zone:addEntity(game.level, g, "terrain", x, y)

local i, j = util.findFreeGrid(x, y, 10, true, {[engine.Map.ACTOR]=true})
if not i then return end

return x, y
