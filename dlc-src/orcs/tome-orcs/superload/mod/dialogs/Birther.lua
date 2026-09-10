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

local init = _M.init
function _M:init(...)
	init(self, ...)
	self.c_name.key:addCommands{
		[{"_RETURN", "ctrl"}] = function()
			self:makeDefaultOrc()
		end
	}

	if not config.settings.tome.embers_of_rage_started then game:onTickEnd(function()
		game:saveSettings("tome_embers_of_rage_started", ("tome.embers_of_rage_started = true\n"):format())	

		self:simpleLongPopup(_t"Welcome to #CRIMSON#Embers of Rage", ([[Thank you for purchasing #CRIMSON#Embers of Rage#WHITE#, the second expansion pack of Tales of Maj'Eyal.

To begin your steamy adventures of hot metal mayhem simply select the #LIGHT_GREEN#Embers of Rage Campaign#WHITE# and be on your way to glory!

Have fun crushing the foes of the Pride!
]]):tformat(), 500)
	end) end
end

function _M:makeDefaultOrc()
	self:setDescriptor("sex", "Male")
	self:setDescriptor("world", "Orcs")
	self:setDescriptor("difficulty", "Normal")
	self:setDescriptor("permadeath", "Adventure")
	self:setDescriptor("race", "Orc")
	self:setDescriptor("subrace", "Orc")
	self:setDescriptor("class", "Tinker")
	self:setDescriptor("subclass", "Psyshot")
	__module_extra_info.no_birth_popup = true
	self:atEnd("created")
end

return _M
