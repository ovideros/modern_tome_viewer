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

load("/data/general/objects/objects.lua")

newEntity{
	define_as = "BASE_FOOD",
	type = "food", subtype="food", not_in_stores=true, no_unique_lore=true,
	unided_name = _t"food", identified=true,
	display = "*", color=colors.RED,
	encumber = 0,
	desc = _t[[Food for Grung!]],
	level_range = {1, 1000},
	material_level = 1,
	material_level_min_only = true,
	cost = 0,

	--- Called when player moves over
	on_move = function(self, x, y, who)
		if who and who.player then
			local idx = game.level.map:findObject(x, y, self)
			if not idx then return end
			game.level.map:removeObject(who.x, who.y, idx)
			game.zone.food_collected = game.zone.food_collected + 1
			game.zone.grung_emote(who, "food")
			if game.zone.food_collected >= 30 and not game.player:isQuestStatus("cults+grung", engine.Quest.COMPLETED, "food") then
				game.player:setQuestStatus("cults+grung", engine.Quest.COMPLETED, "food")
			end
		end
	end
}

for name, img in pairs{
	[_t"disgusting heart"] = "object/bloated_horror_heart.png",
	[_t"lump of flesh"] = "object/ghoul_flesh.png",
	[_t"flesh piece"] = "object/mindstar_living.png",
	[_t"heart"] = "object/orc_heart.png",
	[_t"kidney"] = "object/snow_giant_kidney.png",
	[_t"intestine"] = "object/troll_intestine.png",
	[_t"eye"] = "object/wretchling_eyeball.png",
} do
	newEntity{ base="BASE_FOOD", name=name, image=img, grung_food=1 }
end
