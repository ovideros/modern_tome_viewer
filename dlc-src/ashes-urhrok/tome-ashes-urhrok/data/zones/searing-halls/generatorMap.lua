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

function _M:generate(lev, old_lev)
	local ux, uy, dx, dy, spots = baseGenerator.generate(self, lev, old_lev)

	self:makePod(math.floor(self.map.w / 2), math.floor(self.map.h / 2), 6, "voidhole", {
		noise = "fbm_perlin",
		base_breakpoint = 0.4,
		zoom = 5,
		hurst = nil,
		lacunarity = nil,
		octave = 4,
	}, "void", "floor")

	-- Remove bad doors & walls
	for i = 1, self.map.w - 2 do for j = 1, self.map.h - 2 do
		local g = self.map(i, j, Map.TERRAIN)
		if g and (g.is_door or g.type == "wall") then
			local g4 = self.map(i-1, j, Map.TERRAIN)
			local g6 = self.map(i+1, j, Map.TERRAIN)
			local g8 = self.map(i, j-1, Map.TERRAIN)
			local g2 = self.map(i, j+1, Map.TERRAIN)
			local nb = 0
			if g4 and (g4.is_door or g4.type == "wall") then nb = nb + 1 end
			if g6 and (g6.is_door or g6.type == "wall") then nb = nb + 1 end
			if g8 and (g8.is_door or g8.type == "wall") then nb = nb + 1 end
			if g2 and (g2.is_door or g2.type == "wall") then nb = nb + 1 end
			
			if (nb <= 1 and g.is_door) or (nb <= 0 and g.type == "wall") then self.map(i, j, Map.TERRAIN, self:resolve("floor")) end
		end
	end end

	local g = self.map(ux, uy, Map.TERRAIN)
	if not g or g.change_level ~= -1 then self.level.force_recreate = true end
	local g = self.map(dx, dy, Map.TERRAIN)
	if not g or g.change_level ~= 1 then self.level.force_recreate = true end

	return ux, uy, dx, dy, spots
end
