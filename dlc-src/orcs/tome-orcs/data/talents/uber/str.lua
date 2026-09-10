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
	name = "Pain Enhancement System",
	mode = "passive",
	require = { special={desc=_t"Earned the achievement 'Size Matters' on this character.", fct=function(self)
		local id = world:getCurrentAchievementDifficultyId(game, "SIZE_MATTERS")
		return self.achievements and self.achievements[id]
	end} },
	cooldown = 18,
	callbackOnCrit = function(self, t)
		if self:isTalentCoolingDown(t.id) then return end
		if self:hasEffect(self.EFF_PAIN_ENHANCEMENT_SYSTEM) then return end
		
		self:setEffect(self.EFF_PAIN_ENHANCEMENT_SYSTEM, 6, {power=math.floor(self:getStr() * 0.5)})
		self:startTalentCooldown(t)
	end,
	info = function(self, t)
		return ([[When you deal a critical hit your embedded system activates, increasing all your primary stats except Strength by 50%% of your Strength for 6 turns.]])
		:tformat()
	end,
}
