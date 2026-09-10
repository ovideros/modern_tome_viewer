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
	if lev == 1 then return ux, uy, dx, dy, spots end

	local spots = {}
	for i = 1, 7 do
		local x = rng.range(6, self.map.w - 7)
		local y = rng.range(6, self.map.w - 7)
		self.zone:doQuake(rng.range(4, 6), x, y, function(tx, ty)
			return not self.map.attrs(tx, ty, "no_teleport") and not self.map:checkAllEntities(tx, ty, "change_level") and self.map(tx, ty, engine.Map.TERRAIN)
		end)

		spots[#spots+1] = {x=x,y=y}
	end
	for _, spot in ipairs(spots) do
		local x, y = spot.x, spot.y
		local gc = self:resolve('crack_center')
		local gf = self:resolve('crack_border')
		self.map(x, y, self.map.TERRAIN, gc)
		self.map(x-1, y-1, self.map.TERRAIN, gf)
		self.map(x-1, y, self.map.TERRAIN, gf)
		self.map(x-1, y+1, self.map.TERRAIN, gf)
		self.map(x+1, y-1, self.map.TERRAIN, gf)
		self.map(x+1, y, self.map.TERRAIN, gf)
		self.map(x+1, y+1, self.map.TERRAIN, gf)
		self.map(x, y-1, self.map.TERRAIN, gf)
		self.map(x, y+1, self.map.TERRAIN, gf)

		for i = 1, 2 do
			local mx, my = util.findFreeGrid(x, y, 3, true, {[Map.ACTOR]=true})
			local m = self.zone:makeEntity(self.level, "actor", {type="horror"}, nil, true)
			if m and mx then
				self.zone:addEntity(self.level, m, "actor", mx, my)
			end
		end
	end

	return ux, uy, dx, dy, spots
end
