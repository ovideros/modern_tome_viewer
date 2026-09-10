-- ToME - Tales of Maj'Eyal:
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

newSequenceEffect{ id = "FONT_SACRIFICE",
	message = _t"#PURPLE#A Font of Sacrifice appears nearby!",
	single_use = true,
	trigger = function(portal, x, y)
		local spot = game.level:pickSpotRemove{type="spawn", subtype="tools"}
		if not spot then return end
	
		local list = mod.class.Grid:loadList("/data-cults/general/grids/fonts.lua")
		local g = list.FONT_SACRIFICE:clone()
		game.level.map(spot.x, spot.y, engine.Map.TERRAIN, g)
	end,
}

newSequenceEffect{ id = "ENTROPIC_VOID",
	message = _t"#PURPLE#A portal appears inside the Occult Egress!",
	trigger = function(portal, x, y)
		local Particles = require "engine.Particles"
		portal.add_displays[#portal.add_displays]:addParticles(Particles.new("occult_egress_portal", 5, {}))
		portal.change_zone = "cults+entropic-void"
		portal.change_level = 1
		portal.change_level_check = function(self, player)
			local Dialog = require "engine.ui.Dialog"
			Dialog:yesnoPopup(_t"Portal", _t"You feel this portal leads to a place from where you are likely to not come back.", function(ret) if ret then
				game:changeLevel(self.change_level, self.change_zone)
			end end, _t"Enter", _t"Save your life and stay!")
			return true
		end
	end,
}

newSequenceEffect{ id = "DREM_ORIGIN",
	message = _t"#PURPLE#A portal appears inside the Occult Egress!",
	trigger = function(portal, x, y)
		local Particles = require "engine.Particles"
		portal.add_displays[#portal.add_displays]:addParticles(Particles.new("occult_egress_portal", 5, {}))
		portal.change_zone = "cults+dremshor-tunnel"
		portal.change_level = 1
	end,
}

newSequenceEffect{ id = "EGRESS_SPLATTER",
	message = _t"#PURPLE#A portal appears inside the Occult Egress, this is likely where the adventurer went!",
	trigger = function(portal, x, y)
		local Particles = require "engine.Particles"
		portal.add_displays[#portal.add_displays]:addParticles(Particles.new("occult_egress_portal", 5, {}))
		portal.change_zone = "cults+test" -- dosnt matter
		portal.change_level = 1
		portal.change_level_check = function(self, player)
			local zone, boss = game.state:createRandomZone()
			zone.generator.actor.abord_no_guardian = true
			zone.post_process = function(level)
				if level.level ~= 1 then return end

				local x, y = rng.range(0, level.map.w-1), rng.range(0, level.map.h-1)
				local tries = 0
				while (level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") or level.map.room_map[x][y].special) and tries < 100 do
					x, y = rng.range(0, level.map.w-1), rng.range(0, level.map.h-1)
					tries = tries + 1
				end
				if tries < 100 then
					local g = level.map(x, y, engine.Map.TERRAIN):cloneFull()
					g.name = _t"splattered remains of an adventurer"
					g.display='&' g.color_r=255 g.color_g=0 g.color_b=0 g.notice = true
					g.add_displays = g.add_displays or {}
					g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/cults_splatter_adventurer.png"}
					g:altered()
					game.zone:addEntity(level, g, "terrain", x, y)

					local lore = game.zone.object_list.BASE_LORE
					local o = lore:cloneFull{
						name = _t"log entry", lore="cults-occult-egress-2",
						desc = _t[[A paper scrap.]],
						rarity = false,
						encumberance = 0,
					}
					game.zone:addEntity(level, o, "object", x, y)
				end				
			end
			game:changeLevel(1, zone, {direct_switch=true})
			return true
		end
	end,
}

for i = 1, 3 do
newSequenceEffect{ id = "RANDOM_ARTIFACT"..i,
	message = _t"#PURPLE#An item appears on the egress!",
	single_use = true,
	trigger = function(portal, x, y)
		local o, tries = nil, 100
		while not o and tries > 0 do
			o = game.zone:makeEntity(game.level, "object", {unique=true, not_properties={"lore"}}, nil, true)
			if o then
				game.zone:addEntity(game.level, o, "object", x, y)
				break
			end
		end
	end,
}
end

newSequenceEffect{ id = "SLOW_PATROLS",
	message = _t"#PURPLE#For an instant you feel as if time slowed down over the world! #{italic}#(worldmap patrols permanently slowed down)#{normal}#",
	single_use = true,
	trigger = function(portal, x, y)
		game.state.cults_slow_patrols = true

		game:onLevelLoad("wilderness-1", function(zone, level, data)
			-- Alter existing ones
			for uid, e in pairs(level.entities) do
				if e.on_encounter and e.unit_power then e.movement_speed = (e.movement_speed or 1) / 2 end
			end

			-- Alter future ones
			local function alter(list)
				if not list then return end
				for id, e in ipairs(list) do
					if e.on_encounter and e.unit_power then e.movement_speed = (e.movement_speed or 1) / 2 end
				end
			end
			alter(level:getEntitiesList("maj_eyal_encounters"))
			alter(level:getEntitiesList("fareast_encounters_npcs"))
			alter(level:getEntitiesList("orcs_fareast_encounters_npcs"))
		end)
	end,
}
