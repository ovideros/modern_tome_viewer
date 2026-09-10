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

local combatArmor = _M.combatArmor
function _M:combatArmor()
	local v = combatArmor(self)

	if self:isTalentActive(self.T_HARDENED_CORE) then
		local t = self:getTalentFromId(self.T_HARDENED_CORE)
		v = t.armor(self, t, v)
	end

	return v
end

local combatSpellpower = _M.combatSpellpower
function _M:combatSpellpower(mod, add)
	mod = mod or 1
	add = add or 0

	if self:isTalentActive(self.T_HARDENED_CORE) then
		local t = self:getTalentFromId(self.T_HARDENED_CORE)
		add = add + t.spellpower(self, t)
	end

	return combatSpellpower(self, mod, add)
end

return _M
