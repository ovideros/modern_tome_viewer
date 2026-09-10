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
[[ ##### ]],
[[##.1.##]],
[[##...##]],
[[ ##+## ]],
[[  #9#  ]],
}

return function(gen, id)
	local room = gen:roomParse(def)
	return { name="phonograph"..room.w.."x"..room.h, w=room.w, h=room.h, generator = function(self, x, y, is_lit)
		gen:roomFrom(id, x, y, is_lit, room)

		-- Everything but the entrance is special: cant have the player spawn here
		util.squareApply(x, y, room.w, room.h-2, function(i, j) gen.map.room_map[i][j].special = true end)

		local spot = room.spots[1][1]
		local e = gen.zone:makeEntityByName(gen.level, "terrain", "VINYL_PLAYER")
		if e then
			gen.map(x + spot.x, y + spot.y, Map.TERRAIN, e)
			e.on_added_to_level = nil
			gen.spots[#gen.spots+1] = {x=x+spot.x, y=y+spot.y, guardian=true, check_connectivity="entrance"}
		end

		local spot = room.spots[9][1]
		gen.spots[#gen.spots+1] = {x=x+spot.x, y=y+spot.y, make_tunnel=true, tunnel_dir=2}
	end}
end
