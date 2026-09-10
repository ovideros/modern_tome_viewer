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

name = _t"A Ritch Party"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"Our ultimate goal on the mainland is to get rid of the Sunwall once and for all."
	desc[#desc+1] = _t"To do that we will prepare a special surprise to help our final attack."
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"Go to the Ritch Hive in the mountains north of the Erúan desert and collect a big pile of ritch eggs.  About 30 viable eggs should be sufficient."
	desc[#desc+1] = _t"When you have enough, find a tunnel leading north and use the special sand shredder gloves tinker to open a path under the Gates of Morning."
	desc[#desc+1] = _t"Finally, place the eggs in a protected spot to hatch.  With luck, they will provide a distraction while you later assault the city."
	if self:isStatus(self.COMPLETED, "collect") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have collected enough eggs.#WHITE#"
	end
	if self:isStatus(self.COMPLETED, "tunnel") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have tunnelled close enough to the Gates of Morning.#WHITE#"
	end
	if self:isStatus(self.COMPLETED, "place") then
		desc[#desc+1] = _t"#LIGHT_GREEN#* You have placed the little surprise.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_grant = function(self)
	local Talents = require "engine.interface.ActorTalents"
	local p = game:getPlayer(true)

	local o = mod.class.Object.new{
		power_source = {steam=true},
		type = "tinker", subtype = "steamtech",
		identified=true, no_unique_lore=true,
		name = _t"Stralite Sand Shredder", display = '*', color=colors.UMBER, unique=true, image = "object/artifact/stralite_sand_shredder.png",
		desc = _t[[Automatically deploy a huge rotating drill when you hit a sandwall, carving out a big part of it quickly.]],
		cost = 0, quest=true,
		encumber = 0,
		is_tinker = "steamtech",
		rarity = false,
		metallic = true,
		on_slot ="HANDS",
		material_level = 4,
		object_tinker = {
			wielder = {
				learn_talent = {[Talents.T_TINKER_SAND_SHREDDER] = 1},
			},
		},
		on_drop = function(self, who)
			if who == game.player then
				game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
				return true
			end
		end,
	}

	if p:canUseTinker(o) then
		local attach_inven, attach_item, free = p:findTinkerSpot(o)
		local worn = false
		if attach_inven and attach_item and free then
			worn = p:doWearTinker(nil, nil, o, attach_inven, attach_item, nil, false)
		end
		
		if not worn then
			p:addObject("INVEN", o)
			p:sortInven()		
		end
	else
		-- For poor tinker-less people
		local o = mod.class.Object.new{
			power_source = {steam=true},
			slot = "HANDS",
			type = "armor", subtype="hands",
			identified=true, no_unique_lore=true,
			name = _t"Stralite Sand Shredder", unique=true, image = "object/artifact/stralite_sand_shredder.png",
			desc = _t[[Automatically deploy a huge rotating drill when you hit a sandwall, carving out a big part of it quickly.]],
			add_name = " (#ARMOR#)",
			display = "[", color=colors.RED,
			image = "object/artifact/stralite_sand_shredder.png",
			moddable_tile = resolvers.moddable_tile("gloves"),
			encumber = 1,
			wielder={combat = {accuracy_effect = "axe", physspeed = 0},},
			cost = 0, quest=true,
			rarity = false,
			metallic = true,
			material_level = 4,
			wielder = {
				combat_armor = 1,
				combat = {
					dam = resolvers.rngavg(5, 8),
					apr = 1,
					physcrit = 1,
					dammod = {dex=0.4, str=-0.6, cun=0.4 },
				},
				learn_talent = {[Talents.T_TINKER_SAND_SHREDDER] = 1},
			},
			on_drop = function(self, who)
				if who == game.player then
					game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
					return true
				end
			end,
		}
		o:resolve() o:resolve(nil, true)
		p:addObject("INVEN", o)
		p:sortInven()		
	end
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted("place") then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("orcs+free-prides")
	end
end
