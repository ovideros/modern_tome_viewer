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

newTalent{
	name = "Electron Incantation",
	type = {"spell/other-technomancy",1},
	require = technomancy_req_high1, is_technomancy = true, is_steam = true,
	points = 1,
	steam = 5,
	mana = 5,
	cooldown = 5,
	use_only_arcane = 5,
	tactical = { ATTACKAREA = { TEMPORAL = 2, ARCANE = 2 }, },
	radius = 3,
	target = function(self, t) return {type="ball", radius=3, selffire=false, talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 250) end,
	callbackOnTalentPost = function(self, t, ab)
		if ab.is_technomancy and ab.id ~= t.id then 
			self.can_use_electron_incantation = ab.id
		else
			self.can_use_electron_incantation = nil
		end
	end,
	on_pre_use = function(self, t, silent)
		if not self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then if not silent then game.logPlayer(self, "You need an arcane dynamo to cast this spell.") end return false end
		if not self.can_use_electron_incantation then if not silent then game.logPlayer(self, "You can only cast this spell after casting an other technomancy spell.") end return false end
		return true
	end,
	action = function(self, t)
		if not self.can_use_electron_incantation then return end
		local damtype = DamageType.OCCULT

		local s_ab = self:getTalentFromId(self.can_use_electron_incantation)
		if s_ab.type[1] == "spell/galvanic-technomancy" then damtype = DamageType.GALVANIC
		elseif s_ab.type[1] == "spell/terrene-technomancy" then damtype = DamageType.TERRENE
		end

		self:setEffect(self.EFF_ELECTRON_INCANTATION, 4, {power=4})

		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, damtype, self:spellCrit(t.getDamage(self, t)))

		game.level.map:particleEmitter(self.x, self.y, 3, "electron_incantation", {radius=3, type=damtype})

		game:playSoundNear(self, "talents/reality_breach")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[After casting a technomancy spell you store some of its energies that you can then use to overload your arcane dynamo, increasing the steam it generates per 10 mana spent by 4 for 4 turns.
		In addition the energies spills outward in radius 3, dealing %0.2f damage (damage type based on the type of technomancy spell used).
		This spell is only usable after casting a technomancy spell and until you use any other spell or talent.
		The damage will increase with your Spellpower.]]):tformat(damage)
	end,
}

class:bindHook("Spell:Phantasm:MirrorImage", function(self, data)
	if self:knowTalent(self.T_TINKER_ARCANE_DYNAMO) then
		data.image.is_technomancy_image = true
		data.image:learnTalent(self.T_TINKER_ARCANE_DYNAMO, true, self:getTalentLevelRaw(self.T_TINKER_ARCANE_DYNAMO))
	end
end)
