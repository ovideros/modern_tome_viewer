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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

load("/data-orcs/general/objects/objects.lua")
load("/data/general/objects/lore/sunwall.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "a journal", lore="orcs-gates-morning-"..i,
	desc = _t[[A journal.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_RING", define_as = "RING_LOST_LOVE",
	power_source = {psionic=true, arcane=true},
	unique = true,
	name = "Ring of Lost Love", color = colors.LIGHT_BLUE, image="object/artifact/ring_of_the_lost_love.png",
	unided_name = _t"pure crimson ring",
	desc = _t[[This crimson ring has a palpable bittersweet feel to it.
Inside it is engraved the phrase #{italic}#"To Aeryn, my love, my life. Yours forever. John"#{normal}#]],
	level_range = {30, 35},
	rarity = false,
	cost = 600,
	material_level = 4,

	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 6, [Stats.STAT_LCK] = -10 },
		resists = {
			[DamageType.MIND] = 25,
		},
	},

	special_desc = function(self) return _t"You feel something is #{bold}#very wrong#{normal}# with this ring." end,

	-- Pop john next time we're on the worldmap
	on_pickup = function(self)
		self.on_pickup = nil

		game:onLevelLoad("wilderness-1", function(zone, level)
			-- Wont trigger if the ring is lost
			local has_ring = game.player:findInAllInventoriesBy("define_as", "RING_LOST_LOVE")
			if not has_ring then return end
			has_ring.plot = true

			local spot = game.level:pickSpot{type="world-encounter", subtype="fallen-john"}
			if not spot then return end

			local g = mod.class.WorldNPC.new{
				name=_t"Crimson Templar John",
				type="humanoid", subtype="human", faction="neutral",
				display='@', color=colors.CRIMSON,
				image = "npc/humanoid_human_crimson_templar_john.png",
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_human_crimson_templar_john.png", display_h=2, display_y=-1}}},
				can_talk = "orcs+john-worldmap",
				cant_be_moved = false,
				unit_power = 3000,
			}
			g:resolve() g:resolve(nil, true)
			game.zone:addEntity(game.level, g, "actor", spot.x, spot.y)
		end)
	end,
}
