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

local _M = loadPrevious(...)

--- Gets the tile under the mouse
local getMouseTile = _M.getMouseTile
function _M:getMouseTile(mx, my)
	if game:useCultsBookLook() then
		local shader_resize, shader_margin = 0.9, 0.05
		local outer_resize, outer_margin = 1, 0

		-- Compensate for shader reduction
		mx = mx / shader_resize - self.viewport.width / shader_resize * shader_margin
		my = my / shader_resize - self.viewport.height / shader_resize * shader_margin

		-- Compensate for viewport reduction
		mx = mx / outer_resize - self.viewport.width / outer_resize * outer_margin
		my = my / outer_resize - self.viewport.height / outer_resize * outer_margin

		return getMouseTile(self, mx, my)
	else
		return  getMouseTile(self, mx, my)
	end
end

return _M
