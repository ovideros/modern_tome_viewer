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

uberTalent{
	name = "Master of Disasters",
	mode = "passive",
	getPower = function(self, t) return math.floor(20 + self:getCun(60)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_generic_power", t:_getPower(self))
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_CUN then self:updateTalentPassives(t) end
	end,
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if val <= 0 or dead or target:hasEffect(target.EFF_INCOMING_DISASTERS) then return end
		target:setEffect(target.EFF_INCOMING_DISASTERS, 20, {})
	end,
	info = function(self, t)
		return ([[You are adept at wreaking havoc onto your foes!
		Any time you deal damage to a creature you apply the Incoming Disasters effect for 20 turns.
		Each time you (or any others) would try to apply a cross-tier effect to this creature, you also try to apply the other two.
		In addition your physical, steam, spell and mind powers are increased by %d.
		The powers increase scales of your Cunning.]])
		:tformat(t:_getPower(self))
	end,
}

uberTalent{
	name = "Rak'Shor's Cunning", short_name = "RAKSHOR_CUNNING",
	mode = "passive",
	no_npc_use = true,
	cant_steal = true,
	require = { special={desc=_t"Quaffed the Blood of Undeath, not already undead and not antimagic.", fct=function(self)
		if self:attr("necromancy_immune") then return false end
		return not self:attr("true_undead") and not self:attr("forbid_arcane")
	end} },
	is_race_evolution = function(self, t)
		if self:attr("necromancy_immune") then return false end
		if not self:attr("blood_undeath") then return false end
		return true
	end,
	callbackOnDeathbox = function(self, t, dialog, list)
		if self.rakshor_resurrected then return end

		local function make_undead(choice)
			self.rakshor_resurrected = true
			dialog:cleanActor(self)
			dialog:resurrectBasic(self, "rakshor_cunning")
			dialog:restoreResources(self)

			self:attr("undead", 1)
			self:attr("true_undead", 1)
			self.inscription_forbids = self.inscription_forbids or {}
			self.inscription_forbids["inscriptions/infusions"] = true

			self.descriptor.race = "Undead"
			if choice == "skeleton" then
				self.descriptor.subrace = "Skeleton"
				if not self.has_custom_tile then
					self.moddable_tile = "skeleton"
					self.moddable_tile_nude = 1
					self.moddable_tile_base = "base_01.png"
					self.moddable_tile_ornament = nil
					self.attachement_spots = "race_skeleton"
				end
				self.blood_color = colors.GREY
				self.life_rating = 12
				self:attr("poison_immune", 1)
				self:attr("cut_immune", 1)
				self:attr("fear_immune", 1)
				self:attr("no_breath", 1)

				self:learnTalentType("undead/skeleton", true)
				self:setTalentTypeMastery("undead/skeleton", 1)
				self:learnTalent(self.T_SKELETON, true, 2)
				self:learnTalent(self.T_BONE_ARMOUR, true, 2)
				self:learnTalent(self.T_RESILIENT_BONES, true, 2)
				self:learnTalent(self.T_SKELETON_REASSEMBLE, true, 2)
				self:attr("re-assembled", 1)
			else
				self.descriptor.subrace = "Ghoul"
				if not self.has_custom_tile then
					self.moddable_tile = "ghoul"
					self.moddable_tile_nude = 1
					self.moddable_tile_base = "base_01.png"
					self.moddable_tile_ornament = nil
					self.attachement_spots = "race_ghoul"
				end
				self.life_rating = 14

				self:attr("poison_immune", 0.8)
				self:attr("cut_immune", 1)
				self:attr("stun_immune", 0.5)
				self:attr("fear_immune", 1)
				self:attr("global_speed_base", -0.2)
				self:recomputeGlobalSpeed()

				self:learnTalentType("undead/ghoul", true)
				self:setTalentTypeMastery("undead/ghoul", 1)
				self:learnTalent(self.T_GHOUL, true, 2)
				self:learnTalent(self.T_GHOULISH_LEAP, true, 2)
				self:learnTalent(self.T_RETCH, true, 2)
				self:learnTalent(self.T_GNAW, true, 2)
			end

			game.level.map:particleEmitter(self.x, self.y, 1, "demon_teleport")

			self:updateModdableTile()
			self:check("on_resurrect", "rakshor_cunning")
			self:triggerHook{"Actor:resurrect", reason="rakshor_cunning"}
			-- game:saveGame()

			Dialog:yesnoLongPopup(_t"Rak'Shor's Cunning", _t"#GREY#Applying you cunning plans, you escape death by turning to undeath in an instant!\n\n#{italic}#You may now choose to customize your undead appearance, this can not be changed afterwards.", 600, function(ret) if ret then
				require("mod.dialogs.Birther"):showCosmeticCustomizer(self, _t"Cosmetic Options")
			end end, _t"Customize Appearance", _t"Use Default", true)
		end

		list[#list+1] = {name=_t"Rak'Shor's Cunning (Skeleton)", action=function() make_undead("skeleton") end, force_choice=true}
		list[#list+1] = {name=_t"Rak'Shor's Cunning (Ghoul)", action=function() make_undead("ghoul") end, force_choice=true}
	end,
	info = function(self, t)
		return ([[Set up some cunning contingency plans in case of death.
		If you die you will have the option to raise back from the dead once, by becoming a ghoul or a skeleton (you can choose which).
		When rising this way you will keep access to your racial tree and gain access to the ghoul or skeleton racial tree with 2 levels of each talents already learnt.
		As undead will not able to use infusions anymore.
		If you choose to become a skeleton, the Re-assemble talent will consider that you already used your resurrection.]])
		:tformat()
	end,
}

Talents.main_env.eye_of_the_tiger_data.steam = {
	desc = _t"All steamtech criticals reduce the remaining cooldown of a random steamtech talent by 1.",
	types = { "^steamtech/" },
	reduce = 1,
}
