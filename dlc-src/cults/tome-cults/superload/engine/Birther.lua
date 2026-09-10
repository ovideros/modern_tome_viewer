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

local newBirthDescriptor = _M.newBirthDescriptor
function _M:newBirthDescriptor(t)
	newBirthDescriptor(self, t)

	-- Hack, sadly, we forcefeed demented to embers of rage
	-- Note for later: make embers able to be extended more easily
	if t.type == "world" and t.name == "Orcs" then
		t.descriptor_choices.class.Demented = "allow"
	end
end

return _M
