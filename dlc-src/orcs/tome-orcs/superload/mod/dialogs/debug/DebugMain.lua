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

_M:bindHook("DebugMain:use", function(self, data)
	if data.act == "all-tinkers" then
		for tid in pairs(game.party.__tinkers_ings) do
			game.party:learnTinker(tid)
		end
	end
end)

_M:bindHook("DebugMain:generate", function(self, data)
	data.menu[#data.menu+1] = {name=_t"Learn all schematics", action="all-tinkers"}
end)

return _M
