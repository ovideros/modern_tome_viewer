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

load("/data/general/grids/basic.lua", function(e) if e.define_as and e.define_as:find("^GLASS") then
	e.image = "terrain/solidwall/solid_floor1.png"
	e.dig = nil
end end)
load("/data/general/grids/fortress.lua")
load("/data/general/grids/void.lua")

newEntity{
	define_as = "BOOK_OUT",
	type = "floor", subtype = "underground",
	name = "exit to reality", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image="terrain/book_of_transition.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_level_shift_back = true,
}

newEntity{
	define_as = "BOOK_CHAPTER",
	type = "floor", subtype = "underground",
	name = "shortcut to chapter", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image="terrain/book_of_transition.png"}},
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_level_auto_stairs = true,
	force_clone = true,
}

newEntity{
	define_as = "BOOK_OF_BINDING",
	type = "book", subtype = "underground",
	name = "book of binding", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image="terrain/book_of_binding_lower.png", display_y=-1, display_h=2}, class.new{is_base_d=true, image="terrain/book_of_binding_upper.png", is_top_d=true, z=18, display_y=-1, display_h=2}},
	display = '&', color=colors.CRIMSON,
	notice = true, force_clone = true,
	special = true,
	on_move = function(self, x, y, who)
		if not who or not who.player then return end
		self.on_move = false
		for i, ad in ipairs(self.add_displays) do if ad.is_top_d then
			ad.image = "terrain/book_of_binding_upper_closed.png"
		end end
		self:removeAllMOs()
		game.level.map:updateMap(x, y)

		game.zone.disabled_sidebranch = game.zone.disabled_sidebranch + 1

		if game.zone.disabled_sidebranch < 2 then game.bignews:say(120, "#YELLOW#As you close the book you feel the castle shaking.")
		else game.bignews:say(120, "#CRIMSON#As you close the book the castle shakes again and this time feels more ... 'solid'.")
		end
		game:shakeScreen(30, 5)

		if who:isQuestStatus("cults+illusory-castle", engine.Quest.COMPLETED, "binding1") then
			who:setQuestStatus("cults+illusory-castle", engine.Quest.COMPLETED, "binding2")
		else
			who:setQuestStatus("cults+illusory-castle", engine.Quest.COMPLETED, "binding1")
		end
	end,
}

newEntity{ define_as = "BASE_CHEST",
	type = "floor", subtype = "floor",
	name = "locked chest",
	display='~', color_r=255, color_g=215, color_b=0, notice = true,
	always_remember = true, special_minimap = {b=150, g=50, r=90},
	image = "terrain/solidwall/solid_floor1.png",
	add_mos = { {image=resolvers.rngtable{"object/chest1.png","object/chest2.png","object/chest3.png","object/chest4.png"}}, },
	special = true, force_clone = true,
	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return false end
		if self.chest_opened then return false end
		if not who:hasQuest("cults+illusory-castle") or not who:isQuestStatus("cults+illusory-castle", engine.Quest.DONE) then return false end

		require("engine.ui.Dialog"):yesnoPopup(_t"Locked Chest", _t"Open the chest now that the guardian golem is no more?", function(ret) if ret then
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

for i = 1, 3 do
newEntity{ base= "BASE_CHEST", define_as = "SUPER_CHEST"..i,
	on_added = function(self)
		local o
		local r = rng.range(0, 99)
		if r < 50 then
			o = game.state:generateRandart{lev=resolvers.current_level+10}
		else
			o = game.zone:makeEntity(game.level, "object", {tome={uniques=1}}, nil, true)
		end
		self.chest_item = o
	end,
}
end

newEntity{
	define_as = "GLASS_THRONE",
	type = "throne", subtype = "glass",
	name = "glass throne", image = "terrain/solidwall/solid_floor1.png",
	display = '#', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	always_remember = true,
	add_mos = {{image="terrain/glass_throne_1.png"}},
	add_displays = {class.new{z=17, display_y=-1, image="terrain/glass_throne_0.png"}},
}
