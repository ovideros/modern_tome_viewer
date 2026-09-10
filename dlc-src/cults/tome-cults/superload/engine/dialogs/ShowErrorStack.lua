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

local Dialog = require "engine.ui.Dialog"
local _M = loadPrevious(...)

local init = _M.init
function _M:init(errs, ...)
	if game._chronoworlds and game._chronoworlds.multiverse_fight then
		self.__refuse_dialog = true
		require("mod.class.CultsDLC").backFromSMACK("S.M.A.C.K", [[The entropic wormhole experienced a rapid unplanned cascading failure but Yiilkgur's safety protocols managed to pull you out in time.

#{italic}##GREY#The character you tried to download produced errors, this is not unlikely if you used one with different addons than yours.#{normal}#]])
		return
	end
	return init(self, errs, ...)
end

return _M
