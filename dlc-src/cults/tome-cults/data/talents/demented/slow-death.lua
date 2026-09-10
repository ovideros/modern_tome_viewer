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

newTalent{
	name = "Digest",
	type = {"demented/slow-death", 1},
	points = 5,
	require = dementedreq1,
	cooldown = 12,
	insanity = 20,
	range = 1,
	requires_target = true,
	no_npc_use = true,
	target = function(self, t) return {type="bolt", range=1, selffire=false, friendlyfire=false} end,
	getMax = function(self, t) return 20 end,
	getInsanity = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 2) end,
	action = function(self, t)
		local x, y, target = self:getTargetLimited(self:getTalentTarget(t))
		if not target then return end
		if self:reactionToward(target) >= 0 then return end
		
		local hit = self:attackTarget(target, nil, t.getDamage(self,t), true)

		if hit and (target.life / target.max_life <= t.getMax(self, t) / 100) and target:canBe("instakill") then
			local params = {victim=target, insanity=t.getInsanity(self, t)}
			if self:knowTalent(self.T_PAINFUL_AGONY) then
				local possibles = {}
				for tid, lev in pairs(target.talents) do
					local t = self:getTalentFromId(tid)
					if self:callTalent(self.T_PAINFUL_AGONY, "isUsableTalent", t, "activated") and not self:knowTalent(tid) then
						possibles[#possibles+1] = {tid=tid, name=t.name.. "("..lev..")"}
					end
				end
				if #possibles == 0 then game.logPlayer(self, "%s has no usable talents.", target:getName():capitalize())
				else
					local tid = nil
					if self:getTalentLevel(self.T_PAINFUL_AGONY) >= 5 and #possibles > 1 then
						tid = self:talentDialog(Dialog:listPopup(_t"Painful Agony", _t"Choose a talent to use:", possibles, 400, 400, function(item) self:talentDialogReturn(item) end))
						if tid then tid = tid.tid
						else return nil end
					else
						tid = rng.table(possibles).tid
					end
					params.tid, params.lev = tid, self:callTalent(self.T_PAINFUL_AGONY, "getTalentLevel")
				end
			end
			self:removeEffect(self.EFF_DIGEST)
			self:setEffect(self.EFF_DIGEST, target.rank == 3 and 49 or 24, params)
			target:die(self)
		end

		return true
	end,

	info = function(self, t)
		return ([[Make a melee attack dealing %d%% weapon damage and attempt to snatch a foe that has %d%% life or less left and swallow it whole.
		While you digest it you gain %d insanity per turn.
		The digestion lasts for 50 turns for an elite and 25 turns for others.
		This effect's remaining duration only goes down while in combat, and its bonuses are only applied while in combat.]]):
		tformat(100 * t.getDamage(self, t), t.getMax(self, t), t.getInsanity(self, t))
	end,
}

newTalent{
	name = "Painful Agony",
	type = {"demented/slow-death", 2},
	require = dementedreq2,
	mode = "passive",
	points = 5,
	getTalentLevel = function(self, t) return self:combatTalentScale(t, 1, 10) end,
	isUsableTalent = function(self, _, checkt, mode)
		if checkt.no_player_use or checkt.cant_steal or checkt.is_inscription or checkt.hide == "always" or checkt.no_unlearn_last then return false end
		if checkt.type and checkt.type[1] == "misc/objects" then return false end
		if mode == nil then return true end
		if mode == "passive" and checkt.mode ~= "passive" then return false end
		if mode == "activated" and checkt.mode ~= "activated" then return false end
		if mode == "sustained" and checkt.mode ~= "sustained" then return false end
		if mode == false and checkt.mode ~= "passive" then return false end
		if mode == true and checkt.mode ~= "activated" and checkt.mode ~= "sustained" then return false end
		return true
	end,
	info = function(self, t)
		return ([[The pain you inflict to the victim you are digesting is so intense something breaks inside it, giving you a way into its mind.
		When you digest you can steal a random talent from your victim and can use it for yourself at talent level %d.
		At talent level 5 you can choose which talent to use.
		You may not steal a talent which you already know.
		The stolen talent will not use any resources to activate.
		]]):tformat(t.getTalentLevel(self, t))
	end,
}

newTalent{
	name = "Inner Tentacles",
	type = {"demented/slow-death", 3},
	require = dementedreq3,
	points = 5,
	mode = "passive",
	getLeechValue = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 5, 30), 100, 0, 0, 18.65, 18.65) end, -- Limit chance and life leach to <100% each
	callbackOnCrit = function(self, t)
		if not self:hasEffect(self.EFF_DIGEST) then return false end
		
		self:setEffect(self.EFF_INNER_TENTACLES, 3, {chance=20, power=t.getLeechValue(self, t)})
	end,
	info = function(self, t)
		return ([[Your stomatch grows small tentacles inside which probe and torment your digested victim even more.
		Whenever you deal a critical strike the tentacles probe harder, feeding your more energy from the pain of your victim making you able to feed on the pain your cause to others for 3 turns.
		This effect gives you 20%% chances to leech of your attacks, healing you for %d%% of the damage done.]]):
		tformat(t.getLeechValue(self, t))
	end,
}

newTalent{
	name = "Consume Whole",
	type = {"demented/slow-death", 4},
	require = dementedreq4,
	points = 5,
	cooldown = 14,
	getInsanity = function(self, t) return self:combatTalentScale(t, 8, 20)+20 end,
	getHeal = function(self, t) return 40 + self:combatTalentSpellDamage(t, 10, 520) end,
	is_heal = true,
	on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_DIGEST) then if not silent then game.logPlayer(self, "You are not digesting a creature.") end return false end return true end,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		self:incInsanity(t.getInsanity(self, t))
		self:alterTalentCoolingdown(self.T_DIGEST, -1000)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
		end
		self:removeEffect(self.EFF_DIGEST)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[Instantly consume what remains of your victim, healing yourself for %d life and generating %d insanity.
			Activating this will reset the cooldown of your Digest talent.
		The life healed will increase with your Spellpower.]]):
		tformat(t.getHeal(self, t), t.getInsanity(self, t))
	end,
}
