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

load("/data/general/grids/malrok_walls.lua")
load("/data/general/grids/void.lua", function(e) if e.image then e.image = e.image:gsub("^terrain/floating_rocks", "terrain/red_floating_rocks") end end)
load("/data/general/grids/burntland.lua", function(e) if e.image == "terrain/grass_burnt1.png" then e.image = "terrain/red_floating_rocks05_01.png" end end)

newEntity{
	define_as = "PORTAL_MAIN", 
	type = "floor", subtype = "floor",
	name = "portal to the main island",
	image = "terrain/red_floating_rocks05_01.png", add_displays = {class.new{z=3, image="terrain/planar_demon_portal_ground_down.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2}, class.new{z=16, image="terrain/planar_demon_portal_ground_up.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2}},
	on_added = function(self, level, x, y) local ps = self.add_displays[1]:addParticles(require("engine.Particles").new("farportal_vortex", 1, {rot=3, size=42, vortex="shockbolt/terrain/planar_demon_vortex"})) ps.dy = -0.05 end,
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	change_level_check = function(self, player)
		local spot = game.level:pickSpot{type="portal", subtype="arrival"}
		if spot then
			player:move(spot.x, spot.y, true)
			if core.shader.active(4) then
				game.level.map:particleEmitter(spot.x, spot.y, 2, "shader_ring_rotating", {rotation=0, radius=2, life=30, img="felfire_01_1"}, {type="firesurge"})
			else
				game.level.map:particleEmitter(spot.x, spot.y, 1, "demon_teleport")
			end
		end
		return true
	end,
}

newEntity{
	define_as = "PORTAL_ARRIVAL", 
	type = "floor", subtype = "floor",
	name = "portal to the arrival platform",
	image = "terrain/red_floating_rocks05_01.png", add_displays = {class.new{z=3, image="terrain/planar_demon_portal_ground_down.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2}, class.new{z=16, image="terrain/planar_demon_portal_ground_up.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2}},
	on_added = function(self, level, x, y) local ps = self.add_displays[1]:addParticles(require("engine.Particles").new("farportal_vortex", 1, {rot=3, size=42, vortex="shockbolt/terrain/planar_demon_vortex"})) ps.dy = -0.05 end,
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	change_level_check = function(self, player)
		local spot = game.level:pickSpot{type="portal", subtype="main"}
		if spot then
			player:move(spot.x, spot.y, true)
			if core.shader.active(4) then
				game.level.map:particleEmitter(spot.x, spot.y, 2, "shader_ring_rotating", {rotation=0, radius=2, life=30, img="felfire_01_1"}, {type="firesurge"})
			else
				game.level.map:particleEmitter(spot.x, spot.y, 1, "demon_teleport")
			end
		end
		return true
	end,
}

newEntity{
	define_as = "PORTAL_PREV", 
	type = "floor", subtype = "floor",
	name = "portal to previous level",
	image = "terrain/red_floating_rocks05_01.png", add_displays = {class.new{z=3, image="terrain/planar_demon_portal_ground_down.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2}, class.new{z=16, image="terrain/planar_demon_portal_ground_up.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2}},
	resolvers.generic(function(self) local ps = self.add_displays[1]:addParticles(require("engine.Particles").new("farportal_vortex", 1, {rot=3, size=42, vortex="shockbolt/terrain/planar_demon_vortex"})) ps.dy = -0.05 end),
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "PORTAL_NEXT", 
	type = "floor", subtype = "floor",
	name = "portal to next level",
	image = "terrain/red_floating_rocks05_01.png", add_displays = {class.new{z=3, image="terrain/planar_demon_portal_ground_down.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2}, class.new{z=16, image="terrain/planar_demon_portal_ground_up.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2}},
	resolvers.generic(function(self) local ps = self.add_displays[1]:addParticles(require("engine.Particles").new("farportal_vortex", 1, {rot=3, size=42, vortex="shockbolt/terrain/planar_demon_vortex"})) ps.dy = -0.05 end),
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "PORTAL_EYAL", 
	type = "floor", subtype = "floor",
	name = "portal to Eyal",
	image = "terrain/red_floating_rocks05_01.png", add_displays = {class.new{z=3, image="terrain/planar_demon_portal_ground_down.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2}, class.new{z=16, image="terrain/planar_demon_portal_ground_up.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2}},
	resolvers.generic(function(self) local ps = self.add_displays[1]:addParticles(require("engine.Particles").new("farportal_vortex", 1, {rot=3, size=42, vortex="shockbolt/terrain/planar_demon_vortex"})) ps.dy = -0.05 end),
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1, change_zone = "wilderness",
	change_level_check = function(self, player)
		if player:isQuestStatus("ashes-urhrok+re-abducted", engine.Quest.COMPLETED, "boss") then
			player:setQuestStatus("ashes-urhrok+re-abducted", engine.Quest.COMPLETED)
		else
			game.log("#CRIMSON#The portal is kept shut for you by a malovelant creature nearby.")
			return true
		end
	end,
}

newEntity{ base = "OUTERSPACE",
	define_as = "OUTERSPACE_SHIELD",
	on_added = function(self, level, x, y) if core.shader.active(4) then
		level.map:particleEmitter(x, y, 10, "shader_shield", {size_factor=8, img="forcefield"}, {type="shield", shieldIntensity=0.1, ellipsoidalFactor=1, time_factor=2000, color={0.9, 0.2, 0.4}})
		level.map:particleEmitter(x, y, 10, "gravity_well2", {size_factor=8, speed_factor=0.5})
	end end,
}

for i = 1, 2 do
newEntity{
	define_as = "TORTURE_RACK"..i, 
	type = "floor", subtype = "floor",
	name = "torture rack",
	image = "terrain/red_floating_rocks05_01.png", add_displays = {class.new{z=3, image="terrain/demon_torture_tools/torture_rack_0"..i..".png"}},
	display = '_', color_r=255, color_g=0, color_b=0,
	notice = true,
	always_remember = true,
	does_block_move = true,
}
end

for i = 1, 4 do
newEntity{
	define_as = "TORTURE_SARC"..i, 
	type = "floor", subtype = "floor",
	name = "iron maiden",
	image = "terrain/red_floating_rocks05_01.png", add_displays = {class.new{z=3, image="terrain/demon_torture_tools/sarcofagus_0"..i..".png"}},
	display = '_', color_r=255, color_g=0, color_b=0,
	notice = true,
	always_remember = true,
	does_block_move = true,
}
end

for i = 1, 6 do
newEntity{ base="MALROK_WALL_NORTH_SOUTH", define_as = "MURAL_PAINTING"..i,
	name="mural painting", lore = "ashes-urhrok-mural-painting-"..i,
	display='#', color=colors.LIGHT_RED,
	image="terrain/malrok_wall/malrok_wall_lore"..i..".png",
	nice_tiler = false,
	block_move=function(self, x, y, e, act, couldpass) if e and e.player and act then game.party:learnLore(self.lore) end return true end
}
end


newEntity{
	define_as = "DEMON_SPIKE", 
	type = "floor", subtype = "floor",
	name = "demonic spike",
	display = '|', color_r=255, color_g=0, color_b=0,
	notice = true,
	always_remember = true,
	does_block_move = true,
	nice_tiler = { method="replace", base={"DEMON_SPIKE", 100, 1, 8}},
}
for i = 1, 8 do
newEntity{
	define_as = "DEMON_SPIKE"..i, base = "DEMON_SPIKE",
	image = "terrain/red_floating_rocks05_01.png", add_displays = {class.new{z=3, image="terrain/demon_spikes/spikes_0"..i..".png"}},
}
end
