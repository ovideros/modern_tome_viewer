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

uberTalent{
	name = "Range Amplification Device",
	mode = "sustained",
	cooldown = 10,
	require = { special={desc=_t"Have a light radius of 10 or more", fct=function(self) return self.lite and self.lite >= 10 end} },
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "spell_psionic_range_increase", 3)
		self:talentTemporaryValue(ret, "fatigue", 20)
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Activate a special focusing device that extends all your ranged spells and psionic powers range by 3 (only works on those with range 2 or more and up to 10 max).
		The use of this device is very strenuous, increasing fatigue by 20%% while active.]])
		:tformat()
	end,
}
