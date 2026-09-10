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

-- AI for the civil war fighters, they dont care about grung unless he attacks
newAI("grung_civil_war_target", function(self)
	if not self.grung_disturbed then
		if self.prime_target:attr("dead") then self:setTarget(self) return true 
		else self:setTarget(self.prime_target) return true end
	else
		-- You shouldnt have done that grung ...
		if self:runAI("target_simple") then return true end
	end
end)
