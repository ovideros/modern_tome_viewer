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

load("/data/general/grids/basic.lua")
load("/data-orcs/general/grids/mechwall.lua")
load("/data/zones/shertul-fortress/grids.lua", function(e)
	if e.define_as == "TRAINING_ORB" then
		e.image = "terrain/marble_floor.png"
	elseif e.define_as == "MONITOR_ORB1" or e.define_as == "MONITOR_ORB2" then
		e.image = "terrain/marble_floor.png"
	end
end)

newEntity{ define_as = "BASE_CHEST",
	type = "floor", subtype = "floor",
	name = "locked chest",
	display='~', color_r=255, color_g=215, color_b=0, notice = true,
	always_remember = true, special_minimap = {b=150, g=50, r=90},
	image = "terrain/mechwall/mech_floor_1_01.png",
	add_mos = { {image=resolvers.rngtable{"object/chest1.png","object/chest2.png","object/chest3.png","object/chest4.png"}}, },
	special = true, force_clone = true,
	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return false end
		if self.chest_opened then return false end
		if not who:hasQuest("orcs+kaltor-shop") or not who:isQuestStatus("orcs+kaltor-shop", engine.Quest.DONE) then return false end

		require("engine.ui.Dialog"):yesnoPopup(_t"Locked Chest", _t"Open the chest with Kaltor's key?", function(ret) if ret then
			self.chest_opened = true
			if self.chest_item then
				game.zone:addEntity(game.level, self.chest_item, "object", x, y)
				game.logSeen(who, "#GOLD#An object rolls from the chest!")
			end
			self.chest_item = nil
			self.block_move = nil
			self.special = nil
			self.autoexplore_ignore = true
			self.name = _t"chest (opened)"

			if self.add_mos and self.add_mos[1] then 
				self.add_mos[1].image = self.add_mos[1].image:gsub("chest", "chestopen")
				self:removeAllMOs()
				game.level.map:updateMap(x, y)
			end
		end end, _t"Open", _t"Leave")

		return false
	end,
}

newEntity{ base= "BASE_CHEST", define_as = "CHEST",
	on_added = function(self)
		local o
		local r = rng.range(0, 99)
		if r < 10 then
			o = game.state:generateRandart{lev=resolvers.current_level+10}
		elseif r < 20 then
			o = game.zone:makeEntity(game.level, "object", {tome={uniques=1}}, nil, true)
		elseif r < 50 then
			o = game.zone:makeEntity(game.level, "object", {tome={double_greater=1}}, nil, true)
		else
			o = game.zone:makeEntity(game.level, "object", {tome={greater_normal=1}}, nil, true)
		end
		self.chest_item = o
	end,
}

newEntity{ base= "BASE_CHEST", define_as = "SUPER_CHEST",
	on_added = function(self)
		local o
		local r = rng.range(0, 99)
		if r < 30 then
			o = game.state:generateRandart{lev=resolvers.current_level+10}
		elseif r < 60 then
			o = game.zone:makeEntity(game.level, "object", {tome={uniques=1}}, nil, true)
		else
			o = game.zone:makeEntity(game.level, "object", {tome={double_greater=1}}, nil, true)
		end
		self.chest_item = o
	end,
}

newEntity{ base = "GENERIC_LEVER", define_as = "GENERIC_LEVER", image = "terrain/mechwall/mech_floor_1_01.png" }