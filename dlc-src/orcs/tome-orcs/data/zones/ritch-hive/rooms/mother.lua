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

local def = { numbers = '.',
[[#######]],
[[##2122#]],
[[#2232##]],
[[#######]],
}

return function(gen, id)
	local room = gen:roomParse(def)
	return { name="mothers"..room.w.."x"..room.h, w=room.w, h=room.h, generator = function(self, x, y, is_lit)
		gen:roomFrom(id, x, y, is_lit, room)

		for _, spot in ipairs(room.spots[1]) do
			local e = gen.zone:makeEntity(gen.level, "actor", {name="larvae bloated ritch mother"}, nil, true)
			if e then
				gen:roomMapAddEntity(x + spot.x, y + spot.y, "actor", e)
				e.on_added_to_level = nil
			end
		end
		for _, spot in ipairs(room.spots[2]) do
			local e = gen.zone:makeEntity(gen.level, "actor", {name="ritch hive mother"}, nil, true)
			if e then
				gen:roomMapAddEntity(x + spot.x, y + spot.y, "actor", e)
				e.on_added_to_level = nil
			end
		end
		for _, spot in ipairs(room.spots[3]) do
			local e = gen.zone:makeEntity(gen.level, "actor", {name="ritch larva"}, nil, true)
			if e then
				gen:roomMapAddEntity(x + spot.x, y + spot.y, "actor", e)
				e.on_added_to_level = nil
			end
		end
	end}
end
