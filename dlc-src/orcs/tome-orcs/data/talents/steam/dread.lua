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

local Object = require "mod.class.Object"

newTalent{
	name = "Mechanical Arms",
	type = {"steamtech/dread", 1},
	points = 5, 
	require = dex_steamreq_high1,
	mode = "sustained",
	sustain_psi = 15,
	drain_steam = 5,
	cooldown = 20,
	getDam = function(self, t) return self:combatTalentWeaponDamage(t, 0.6, 1.3) end,
	getReduction = function(self, t) return self:combatTalentLimit(t, 50, 10, 33) end,
	callbackOnActBase = function(self, t)
		local mindstar = self:getInven(self.INVEN_OFFHAND) and self:getInven(self.INVEN_OFFHAND)[1]
		if not mindstar or mindstar.subtype ~= "mindstar" then return end
		if game.zone.wilderness then return end

		local tgts = {}
		self:project({type="ball", radius=3}, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and self:reactionToward(target) < 0 then tgts[#tgts+1] = target end
		end)

		local nb = 2
		while nb > 0 and #tgts > 0 do
			local target = rng.tableRemove(tgts)
			nb = nb - 1

			local speed, hit = self:attackTargetWith(target, mindstar.combat, nil, self:getOffHandMult(mindstar.combat, t.getDam(self, t)))
			if hit and target:canBe("fear") then
				target:setEffect(target.EFF_HARASSED, 5, {apply_power=self:combatSteampower(), src=self, damageChange= -t.getReduction(self, t), no_ct_effect = true})
			elseif hit then
				game.logSeen("%s resists the growing panic!", target:getName():capitalize())
			end
		end
	end,
	activate = function(self, t)
		local ret = {}

		local bx, by = self:attachementSpot("back", true)
		self:talentParticles(ret, {type="mechanical_arms", args={x=bx, y=by}})

		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Using psionic forces you maintain in place on your back two giant horrific mechanical arms.
		Each basic turn (as if you had 100%% speed) they can automatically attack up to 2 foes within range 3 with a mindstar attack doing %d%% weapon damage.
		Creatures harassed by the mechanical arms have their damage reduced by %d%% for 5 turns.]]):
		tformat(t.getDam(self, t) * 100, t.getReduction(self, t))
	end,
}

newTalent{
	name = "Lucid Shot",
	type = {"steamtech/dread", 2},
	points = 5,
	require = dex_steamreq_high2,
	psi = 10,
	steam = 10,
	cooldown = 8,
	is_psyshot = true,
	no_energy = "fake",
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getDur = function(self, t) return self:combatTalentLimit(t, 10, 3, 7) end,
	getDam = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 2.5) end,
	archery_onhit = function(self, t, target, x, y)
		game.level.map:particleEmitter(x, y, 3, "shout", {additive=true, life=10, size=3, distorion_factor=0.5, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0, gM=0, bm=0.1, bM=0.2, am=0.4, aM=0.6})
		self:project({type="ball", radius=3}, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			local cleansed = target:removeEffectsFilter(self, function(eff)
				if eff.status == "detrimental" and eff.type ~= "other" and (eff.subtype.fear or eff.subtype.nightmare) then
					return true
				else
					return false
				end
			end, 1, false, false, nil, false) 
			if cleansed > 0 and target:canBe("confusion") then
				target:setEffect(target.EFF_LUCID_SHOT, t.getDur(self, t), {})
			end
		end)
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=t.getDam(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Fire a powerful shot at a foe doing %d%% weapon damage.
		If the creature, or any creatures in radius 3, was affected by a fear or nightmare effect it violently wakes up, shaking it off only to find itself disoriented, unable to discern friends from foes for %d turns.]])
		:tformat(100 * t.getDam(self, t), t.getDur(self, t))
	end,
}

newTalent{
	name = "Psy Worm",
	type = {"steamtech/dread", 3},
	points = 5,
	require = dex_steamreq_high3,
	psi = 15,
	steam = 10,
	cooldown = 12,
	no_energy = "fake",
	range = steamgun_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("steamgun") then if not silent then game.logPlayer(self, "You require a steamgun for this talent.") end return false end return true end,
	getWorm = function(self, t) return self:combatTalentMindDamage(t, 30, 350) / 8 end,
	getDam = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 1.1) end,
	getPsi = function(self, t) return 1 end,
	archery_onhit = function(self, t, target, x, y)
		target:setEffect(target.EFF_PSY_WORM, 8, {apply_power=self:combatMindpower(), power=t.getWorm(self, t), psi=t.getPsi(self, t), src=self})
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=t.getDam(self, t), damtype=DamageType.MIND})
		return true
	end,
	info = function(self, t)
		return ([[Fire a psionic-enhanced shot at a foe doing %d%% mind weapon damage and infecting it with a psy worm for 8 turns.
		Each turn the worm will do %0.2f mind damage and restore %d psi to you, double if stunned or feared.
		Also each turn the worm has 25%% chances to spread to a nearby foe in radius 3.
		When a creature infected by Psy Worm dies it spreads to all enemies in a radius of 3.]])
		:tformat(100 * t.getDam(self, t), damDesc(self, DamageType.MIND, t.getWorm(self, t)), t.getPsi(self, t))
	end,
}

newTalent{
	name = "No Hope",
	type = {"steamtech/dread", 4},
	points = 5,
	psi = 50,
	cooldown = 15,
	require = dex_steamreq_high4,
	tactical = { ANNOY = 2, DEFEND = 1 },
	range = 10,
	no_energy = true,
	requires_target = true,
	target = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t, friendlyfire=false}
		return tg
	end,
	getDur = function(self, t) return math.ceil(self:combatTalentLimit(t, 15, 3, 8)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_NO_HOPE, t.getDur(self, t), {apply_power=self:combatMindpower()})
		end)
		return true
	end,
	info = function(self, t)
		return ([[Entering the mind of your foe you manipulate it to make it lose hope of defeating you, reducing all its damage by 40%% for %d turns.]]):
		tformat(t.getDur(self, t))
	end,
}
