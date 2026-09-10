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
	define_as = "CRATER_SPLATTER",
	type = "floor", subtype = "rocks",
	name = "demon killed by a meteor", image = "terrain/red_floating_rocks05_01.png",
	add_displays = {
		class.new{z=4, image="terrain/impact_crater_lava.png", display_w=4, display_h=4, display_x=-1.5, display_y=-1.5},
		class.new{z=5, image="terrain/demon_cratter_splatter.png", display_w=4, display_h=4, display_x=-1.5, display_y=-1.5},
	},
	display = '*', color_r=255, color_g=255, color_b=0,
	_noalpha = false,
}

newEntity{
	define_as = "CRATER",
	type = "floor", subtype = "rocks",
	name = "impact crater", image = "terrain/red_floating_rocks05_01.png",
	add_displays = {
		class.new{z=4, image="terrain/impact_crater_lava.png", display_w=4, display_h=4, display_x=-1.5, display_y=-1.5},
	},
	display = '*', color_r=255, color_g=255, color_b=0,
	_noalpha = false,
}

newEntity{
	define_as = "CONTROLLING_CRYSTAL",
	type = "floor", subtype = "rocks", image = "terrain/red_floating_rocks05_01.png", add_mos = {{image="terrain/malrok_wall/control_gem.png"}},
	name = "tracking control crystal",
	display = '*', color_r=255, color_g=255, color_b=0,
	_noalpha = false,
	--does_block_move = true,
	pass_projectile = true,
	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return false end
		if self.broken then return false end

		who:restInit(20, _t"destroying the crystal", _t"destroyed the crystal", function(cnt, max)
			if cnt > max then
				game.log("#VIOLET#The crystal is destroyed!")
				game.bignews:say(120, "#YELLOW#The disturbance has attracted the Planar Controller!")
				self.broken = true
				self.add_mos[1].image = "terrain/malrok_wall/control_gem_shattered.png"
				self:removeAllMOs()
				game.level.map:updateMap(x, y)
				game:onTickEnd(function()
					who:setQuestStatus("ashes-urhrok+start-ashes", engine.Quest.COMPLETED, "crystal")
				end)
			end
		end)

		return true
	end,
	always_remember = true,
	notice = true,
	special = true,
	special_minimap = colors.YELLOW,
}

newEntity{
	define_as = "PORTAL_NEXT", image = "terrain/red_floating_rocks05_01.png", add_mos = {{image="terrain/demon_portal.png"}},
	type = "floor", subtype = "floor",
	name = "portal to the next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "PORTAL_PREV", image = "terrain/red_floating_rocks05_01.png", add_mos = {{image="terrain/demon_portal.png"}},
	type = "floor", subtype = "floor",
	name = "portal to the previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "PORTAL_EYAL", 
	type = "floor", subtype = "floor",
	name = "portal to somewhere on Eyal",
	image = "terrain/red_floating_rocks05_01.png", add_displays = {
		class.new{z=3, image="terrain/planar_demon_portal_ground_down.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2},
		class.new{z=16, image="terrain/planar_demon_portal_ground_up.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2},
	},
	on_added = function(self, level, x, y)
		local ps = self.add_displays[1]:addParticles(require("engine.Particles").new("farportal_vortex", 1, {rot=3, size=42, vortex="shockbolt/terrain/planar_demon_vortex"}))
		ps.dy = -0.05
	end,
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1, change_zone = "wilderness",
	change_level_check = function(self)
		local player = game:getPlayer(true)
		player:setQuestStatus("ashes-urhrok+start-ashes", engine.Quest.COMPLETED, "escaped")

		game:changeLevel(2, (rng.table{"trollmire","ruins-kor-pul","scintillating-caves","rhaloren-camp","norgos-lair","heart-gloom"}), {direct_switch=true})

		local a = require("engine.Astar").new(game.level.map, player)

		local sx, sy = util.findFreeGrid(player.x, player.y, 20, true, {[engine.Map.ACTOR]=true})
		while not sx do
			sx, sy = rng.range(0, game.level.map.w - 1), rng.range(0, game.level.map.h - 1)
			if game.level.map(sx, sy, engine.Map.ACTOR) or not a:calc(player.x, player.y, sx, sy) then sx, sy = nil, nil end
		end

		game.level.map:particleEmitter(player.x, player.y, 1, "demon_teleport")

		game:onLevelLoad("wilderness-1", function(zone, level, data)
			local list = {}
			for i = 0, level.map.w - 1 do for j = 0, level.map.h - 1 do
				local idx = i + j * level.map.w
				if level.map.map[idx][engine.Map.TERRAIN] and level.map.map[idx][engine.Map.TERRAIN].change_zone == data.from then
					list[#list+1] = {i, j}
				end
			end end
			if #list > 0 then
				game.player.wild_x, game.player.wild_y = unpack(rng.table(list))
			end
		end, {from=game.zone.short_name})

		require("engine.ui.Dialog"):simplePopup(_t"Safe!", _t"You made it to Eyal! You are not quite sure where, but it can not be worse than the Fearscape.")

		return true
	end,
}
