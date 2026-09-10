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

local Map = require "engine.Map"

-- Pop the item's vault on the side!
function _M:generate(lev, old_lev)
	local ux, uy, dx, dy, spots = baseGenerator.generate(self, lev, old_lev)
	if not game:isAddonActive("items-vault") or lev ~= 1 then return ux, uy, dx, dy, spots end

	local mw = math.floor(self.map.w / 2)
	mw = rng.range(mw - 15, mw +15)
	local sy = {}
	for j = 0, self.map.h - 1 do
		if not self.map:checkEntity(mw, j, Map.TERRAIN, "block_move") then
			sy[#sy+1] = j
		end
	end
	if #sy == 0 then self.level.force_recreate = true return ux, uy, dx, dy, spots end
	sy = rng.table(sy)

	local ex = rng.range(mw - 15, mw + 15)
	self:tunnel(mw, sy, ex, 0, 1, false)
	self.map(ex, 0, Map.TERRAIN, self:resolve('items_vault'))

	return ux, uy, dx, dy, spots
end