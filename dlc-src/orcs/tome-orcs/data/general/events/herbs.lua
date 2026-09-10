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

-- Find a random spot
local x, y = game.state:findEventGrid(level)
if not x then return false end

local ml_min = math.max(util.getval(game.zone.min_material_level) or 1, 1)
local ml_max = math.min(util.getval(game.zone.max_material_level) or 5, 5)
local ml = rng.range(ml_min, ml_max)

local o = require("mod.class.Object").new{
	type = "herbs", subtype = "herbs",
	name = _t"pile of herbs", image="object/a_pile_of_herbs.png",
	desc = _t"A little stockpile of herbs, whomever left them there should be thanked.",
	display = '*', color=colors.OLIVE_DRAB,
	special_minimap = {b=50, g=255, r=50},
	material_level = ml,
	on_prepickup = function(self, who, id)
		game.log("#OLIVE_DRAB#You carefully pickup the stack of herbs.")
		game.party:collectIngredient("HERBS"..self.material_level, rng.range(3, 6))

		-- Remove from the map
		game.level.map:removeObject(who.x, who.y, id)
		return true
	end,
	auto_pickup = true,
}
game.zone:addEntity(game.level, o, "object", x, y)

return true
