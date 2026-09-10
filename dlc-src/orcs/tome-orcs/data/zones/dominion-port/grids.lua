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
load("/data/general/grids/water.lua")
load("/data/general/grids/sand.lua")

local sand_editer = { method="borders_def", def="sand"}

newEntity{
	define_as = "SEWER_WATER", base = "POISON_DEEP_WATER",
	name = "stale sewer water",
	faction = "kar-haib-dominion",
	mindam = resolvers.mbonus(5, 10),
	maxdam = resolvers.mbonus(15, 30),
	on_stand = function(self, x, y, who) -- this needs to be fixed in the main game also
		if self.faction and who:reactionToward(self) >= 0 then return end
		local DT = engine.DamageType
		local dam = DT:get(DT.POISON).projector(self, x, y, DT.POISON, rng.range(self.mindam, self.maxdam))
		self.x, self.y = x, y
		if dam > 0 and who.player then self:logCombat(who, "#Source# poisons #Target#!") end
	end,
	nice_tiler = false,
}

newEntity{
	define_as = "UP", image = "terrain/sandfloor.png", add_mos = {{image="terrain/stair_up.png"}},
	type = "floor", subtype = "sand",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = sand_editer,
}

newEntity{
	define_as = "DOWN", image = "terrain/sandfloor.png", add_mos = {{image="terrain/stair_down.png"}},
	type = "floor", subtype = "sand",
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = sand_editer,
}

newEntity{
	define_as = "UP_WILDERNESS",
	type = "floor", subtype = "sand",
	name = "exit to the worldmap", image = "terrain/sandfloor.png", add_mos = {{image="terrain/stair_up_wild.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
	nice_editer = sand_editer,
}

newEntity{
	define_as = "UP_TOWN",
	type = "floor", subtype = "sand",
	name = "exit to the port", image = "terrain/sandfloor.png", add_mos = {{image="terrain/stair_up.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
}

newEntity{
	define_as = "UP_TOWER",
	type = "floor", subtype = "sand",
	name = "way into the tower", image = "terrain/marble_floor.png", add_mos = {{image="terrain/stair_up.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
}

newEntity{
	define_as = "DOWN_SEWER",
	type = "floor", subtype = "sand",
	name = "way into the sewers", image = "terrain/marble_floor.png", add_mos = {{image="terrain/stair_down.png"}},
	display = '>', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = -1,
}

newEntity{
	define_as = "TO_TOWN",
	type = "floor", subtype = "floor",
	name = "exit to the port", image = "terrain/marble_floor.png", add_mos = {{image="terrain/stair_down.png"}},
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = -1,
}

newEntity{
	define_as = "WEAKNESS",
	type = "floor", subtype = "floor",
	name = "structural weakness", image = "terrain/marble_floor.png", add_mos = {{image = "terrain/floor_tower_structural_weakness.png"}},
	display = '&', color_r=255, color_g=0, color_b=0,
	always_remember = true,
	notice = true,
	tower_structural_weakness = 1,
	embed_particles = {
		{name="structural_tower_weakness", rad=1, args={}},
	},
}

newEntity{ define_as = "BASE_CHEST",
	type = "floor", subtype = "floor",
	name = "booty chest",
	display='~', color_r=255, color_g=215, color_b=0, notice = true,
	always_remember = true, special_minimap = {b=150, g=50, r=90},
	image = "terrain/marble_floor.png",
	add_mos = { {image=resolvers.rngtable{"object/chest1.png","object/chest2.png","object/chest3.png","object/chest4.png"}}, },
	special = true, force_clone = true,
	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return false end
		if self.chest_opened then return false end

		self.special = nil
		self.autoexplore_ignore = true
		self.chest_opened = true
		if self.chest_items then
			local list = { ("- #GOLD#%0.2f gold#LAST# worth of money"):tformat(self.chest_gold) }

			who:incMoney(self.chest_gold)
			for _, o in ipairs(self.chest_items) do
				o.__transmo = true
				o:identify(true)
				who:addObject(who.INVEN_INVEN, o)
				list[#list+1] = "- "..o:getName{do_color=true}
			end
			who:sortInven()

			require("engine.ui.Dialog"):simpleLongPopup(_t"Booty chest", _t"You plunder the chest and gain:\n"..table.concat(list, "\n"), 500)
		end
		self.chest_items = nil
		self.block_move = nil
		self.special = nil
		self.autoexplore_ignore = true
		self.name = _t"chest (plundered)"

		if self.add_mos and self.add_mos[1] then 
			self.add_mos[1].image = self.add_mos[1].image:gsub("chest", "chestopen")
			self:removeAllMOs()
			game.level.map:updateMap(x, y)
		end

		return false
	end,
}

newEntity{ base= "BASE_CHEST", define_as = "CHEST",
	on_added = function(self)
		self.chest_gold = rng.range(50, 80)
		self.chest_items = {}
		for i = 1, rng.range(2, 5) do
			local o
			local r = rng.range(0, 99)
			if r < 5 then
				o = game.state:generateRandart{lev=resolvers.current_level+10}
			elseif r < 15 then
				o = game.zone:makeEntity(game.level, "object", {tome={uniques=1}}, nil, true)
			elseif r < 50 then
				o = game.zone:makeEntity(game.level, "object", {tome={double_greater=1}}, nil, true)
			else
				o = game.zone:makeEntity(game.level, "object", {tome={greater_normal=1}}, nil, true)
			end
			if o.type ~= "money" then
				game.zone:addEntity(game.level, o, "object")
				self.chest_items[#self.chest_items+1] = o
			end
		end
	end,
}
