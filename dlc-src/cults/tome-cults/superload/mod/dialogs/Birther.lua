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
		[{"_RETURN", "ctrl", "shift"}] = function()
			self:makeDefaultDemented()
		end
	}

	if not config.settings.tome.forbidden_cults_started then game:onTickEnd(function()
		game:saveSettings("tome_forbidden_cults_started", ("tome.forbidden_cults_started = true\n"):format())	

		local races = {"human", "elf", "dwarf", "halfling"}
		if profile.mod.allow_build.yeek then races[#races+1] = "yeek" end

		self:simpleLongPopup(_t"Welcome to #CRIMSON#Forbidden Cults", (_t[[Thank you for purchasing #CRIMSON#Forbidden Cults#WHITE#, the third expansion pack of Tales of Maj'Eyal.

To begin your adventures as a half horror simply create a character with the class #LIGHT_GREEN#Writhing One#WHITE# (in the Demented category).

Have fun lashing your tentacle at your foes!
]]):format(table.concatNice(table.ts(races), ', ', _t' or ')), 500)
	end) end
end

function _M:makeDefaultDemented()
	self:setDescriptor("sex", "Female")
	self:setDescriptor("world", "Maj'Eyal")
	self:setDescriptor("difficulty", "Normal")
	self:setDescriptor("permadeath", "Adventure")
	-- self:setDescriptor("race", "Giant")
	-- self:setDescriptor("subrace", "Krog")
	self:setDescriptor("race", "Dwarf")
	self:setDescriptor("subrace", "Drem")
	self:setDescriptor("class", "Demented")
	self:setDescriptor("subclass", "Writhing One")
	-- self:setDescriptor("subclass", "Cultist of Entropy")
	__module_extra_info.no_birth_popup = true
	self:atEnd("created")
end

return _M
