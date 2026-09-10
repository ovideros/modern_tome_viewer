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

-- Hook to show artifices on the doll
class:bindHook("Actor:updateModdableTile:front", function(self, data)
	if not self:knowTalent(self.T_MUTATED_HAND) or not self:callTalent(self.T_MUTATED_HAND, "canTentacleCombat") then return end
	data.add[#data.add+1] = {image = data.base.."cults/left_tentacle.png", auto_tall=1}
end)

-- Note:  This still needs to be displayed in the CS tooltip
newTalent{
	name = "Mutated Hand",
	type = {"demented/tentacles", 1},
	no_unlearn_last = true,
	points = 5,
	require = { stat = { mag=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.5 end,
	getInsanityBonus = function(self, t) return 10 end,
	canTentacleCombat = function(self, t)
		if self.override_tentacle_combat_oneshot then return true end
		if self:attr("force_tentacle_hand") then return true end
		local offhand = self:getInven(self.INVEN_OFFHAND)
		if not offhand or offhand[1] then return false end -- No lefthand or lefthand used, nope
		if self:hasTwoHandedWeapon() and not self:attr("allow_mainhand_2h_in_1h") then return false end
		-- No check for disarmed, you cant disarm a tentacle!
		return true
	end,
	getTentacleCombat = function(self, t, force)
		if self.override_tentacle_combat_oneshot then
			local combat = self.override_tentacle_combat_oneshot
			self.override_tentacle_combat_oneshot = nil
			return combat
		end
		if not t.canTentacleCombat(self, t) and not force then return nil end
		return {
			talented = "tentacles",
			damtype = engine.DamageType.DARKNESS,
			dam = self:combatTalentScale(t, 10, 40),
			dammod = {mag=1},
			damrange = 1.4,
			physcrit = self:combatTalentLimit(t, 25, 2, 12),
			physspeed = 1,
			sound = {"actions/tentacle_attack"}, sound_miss = {"actions/tentacle_attack", pitch=0.6},
		}
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		local allow_tcombat = t.canTentacleCombat(self, t)
		local tcombat = {combat=t.getTentacleCombat(self, t, true)}
		local tcombatdesc = Object:descCombat(self, tcombat, {}, "combat")
		return ([[Your left hand mutates into a disgusting mass of tentacles.
		When you have your offhand empty you automatically hit your target and those on the side whenever you hit with a basic attack.
		Also increases Physical Power by %d, and increases weapon damage by %d%% for your tentacles attacks.
		Each time you make an attack with your tentacle you gain %d insanity.
		You generate a low power psionic field around you when around #{italic}#'civilized people'#{normal}# that prevents them from seeing you for the horror you are.

		Your tentacle hand currently has these stats%s:
		%s]]):
		tformat(damage, 100*inc, t.getInsanityBonus(self, t), allow_tcombat and "" or _t", #CRIMSON# but is currently disabled due to non-empty offhand#WHITE#", tostring(tcombatdesc))
	end,
}

newTalent{
	name = "Lash Out",
	type = {"demented/tentacles", 2},
	require = dementedreq2,
	points = 5,
	cooldown = 8,
	tactical = { ATTACKAREA = {weapon=2} },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:callTalent(self.T_MUTATED_HAND, "canTentacleCombat") then if not silent then game.logPlayer(self, "You require an empty offhand to use your tentacle hand.") end return false end return true end,
	radius = 3,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.4, 2.1) end,
	getDamageTentacle = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 1.9) end,
	getMHInsanity = function(self, t) return 15 end,
	getTentacleInsanity = function(self, t) return 5 end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t} end,
	action = function(self, t)
		local weapon = self:hasWeaponType(nil)
		local tentacle = self:callTalent(self.T_MUTATED_HAND, "getTentacleCombat")
		if not weapon or not tentacle then
			game.logPlayer(self, "You require a weapon and an empty offhand!")
			return nil
		end

		local mh_hit = false
		local t_hit = false
		self:attr("tentacle_hand_prevent", 1)
		local tg = self:getTalentTarget(t)
		if self:isTalentActive(self.T_TENTACLE_CONSTRICT) then
			local tc = self:isTalentActive(self.T_TENTACLE_CONSTRICT)
			tg.x = tc.target.x
			tg.y = tc.target.y
			self:project(tg, tg.x, tg.y, function(px, py, tg, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					if self:attackTargetWith(target, tentacle, nil, t.getDamageTentacle(self, t)) then t_hit = true end
					if target:canBe("stun") then
						target:setEffect(target.EFF_DAZED, 5, {apply_power=self:combatSpellpower()})
					end
				end
			end)
			for i = 0, 360, 35 do
				tc.target:addParticles(Particles.new("tentacle_lash", 1, {dir=i, dist=3}))
			end
		else
			self:project(tg, self.x, self.y, function(px, py, tg, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					if self:attackTargetWith(target, tentacle, nil, t.getDamageTentacle(self, t)) then t_hit = true end
				end
			end)
			local hx, hy = self:attachementSpot(self._flipx and "hand1" or "hand2", true)
			for i = 0, 360, 35 do
				local ps = Particles.new("tentacle_lash", 1, {dir=i, dist=3})
				ps.dx = hx ps.dy = hy self:addParticles(ps)
			end
		end
		tg.radius = 1
		tg.x = self.x
		tg.y = self.y
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and self:reactionToward(target) < 0 then
				if self:attackTargetWith(target, weapon.combat, nil, t.getDamage(self, t)) then mh_hit = true end
			end
		end)
		self:attr("tentacle_hand_prevent", -1)
		self:addParticles(Particles.new("meleestorm", 1, {}))
		if mh_hit then self:incInsanity(t.getMHInsanity(self, t)) end
		if t_hit then self:incInsanity(t.getTentacleInsanity(self, t)) end
		game:playSoundNear(self, "talents/slime")

		game:playSoundNear(self, "actions/tentacle_attack")

		return true
	end,
	info = function(self, t)
		return ([[Spin around, extending your weapon and damaging all targets around you for %d%% weapon damage while your tentacle hand extends and hits all targets in radius 3 for %d%% tentacle damage.
				
				If the mainhand attack hits at least one enemy you gain %d insanity.
				If the tentacle attack hits at least one enemy you gain %d insanity.
		
		#YELLOW_GREEN#When constricting:#WHITE# Your tentacle attack is centered around your constricted target (but not your weapon attack) and only in radius 1 but it also dazes anything hit for 5 turns.]]):
		tformat(100 * t.getDamage(self, t), 100 * t.getDamageTentacle(self, t), t.getMHInsanity(self, t), t.getTentacleInsanity(self, t))
	end,
}

newTalent{
	name = "Tendrils Eruption",
	type = {"demented/tentacles", 3},
	require = dementedreq3,
	points = 5,
	cooldown = function(self, t)
		if self:isTalentActive(self.T_TENTACLE_CONSTRICT) then return 10 end
		return 18
	end,
	range = 7,
	radius = 3,
	tactical = { ATTACKAREA = {weapon = 2}, DISABLE = 3 },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:callTalent(self.T_MUTATED_HAND, "canTentacleCombat") then if not silent then game.logPlayer(self, "You require an empty offhand to use your tentacle hand.") end return false end return true end,
	getNumb = function(self,t) return self:combatTalentLimit(t, 50, 25, 40) end,
	getDamageTentacle = function(self, t) return self:combatTalentWeaponDamage(t, 1.8, 3) end,
	getInsanity = function(self, t) return 20 end,
	action = function(self, t)
		local tentacle = self:callTalent(self.T_MUTATED_HAND, "getTentacleCombat")
		if not tentacle then
			game.logPlayer(self, "You require a weapon and an empty offhand!")
			return nil
		end

		local x, y = nil, nil
		local dam = t.getDamageTentacle(self, t)
		local radius = self:getTalentRadius(t)
		local hit = false
		if self:isTalentActive(self.T_TENTACLE_CONSTRICT) then
			local tc = self:isTalentActive(self.T_TENTACLE_CONSTRICT)
			radius = 0
			dam = dam * 1.5
			x, y = tc.target.x, tc.target.y
			local target = game.level.map(x, y, Map.ACTOR)
			local weapon = self:hasWeaponType(nil)
			if target and weapon and core.fov.distance(self.x, self.y, x, y) <= 1 then self:attackTargetWith(target, weapon.combat, nil, 1) end
		end
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius, friendlyfire=false}
		if not x then x, y = self:getTargetLimited(tg) end
		if not x or not y then return nil end

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target or (self:reactionToward(target) >= 0) then return end
			if self:attackTargetWith(target, tentacle, nil, dam) then hit = true end
			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
				target:setEffect(self.EFF_SLIMY_TENDRIL, 5, {power=t.getNumb(self, t)})
			else
				game.logSeen(target, "%s resists the slimy tendril!", target:getName():capitalize())
			end
		end)
		game.level.map:particleEmitter(x, y, tg.radius, "tentacle_field", {img="tentacle_black", radius=tg.radius})
		game:playSoundNear(self, "talents/slime")
		if hit then self:incInsanity(t.getInsanity(self, t)) end

		return true
	end,
	info = function(self, t)
		return ([[You plant your tentacle hand in the ground where it splits up and extends to a target zone of radius %d.
		The zone will erupt with many black tendrils to hit all foes caught inside dealing %d%% tentacle damage.
		Any creature hit by the tentacle must save against spell or be numbed by the attack, reducing its damage by %d%% for 5 turns.

		If at least one enemy is hit you gain %d insanity.

		#YELLOW_GREEN#When constricting:#WHITE#The tendrils pummel your constricted target for %d%% tentacle damage and if adjacent you make an additional mainhand weapon attack.  Talent cooldown reduced to 10.]]):
		tformat(self:getTalentRadius(t), t.getDamageTentacle(self, t) * 100, t.getNumb(self, t), t.getInsanity(self, t), t.getDamageTentacle(self, t) * 1.5 * 100)
	end,
}

newTalent{
	name = "Constrict", short_name = "TENTACLE_CONSTRICT",
	type = {"demented/tentacles", 4},
	require = dementedreq4,
	points = 5,
	mode = "sustained",
	insanity = -10,
	sustain_insanity = 0, remove_on_zero = true,
	drain_insanity = -3,
	cooldown = 7,
	range = 10,
	tactical = { ATTACK = {weapon = 2}, CLOSE_IN = 3 },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:callTalent(self.T_MUTATED_HAND, "canTentacleCombat") then if not silent then game.logPlayer(self, "You require an empty offhand to use your tentacle hand.") end return false end return true end,
	getDamageTentacle = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.6) end,
	do_attack = function(self, t, target)
		if not target then return end
		local tentacle = self:callTalent(self.T_MUTATED_HAND, "getTentacleCombat")
		if not tentacle then game.logPlayer(self, "You require a mutated hand!") end

		if target:canBe("knockback") then
			target:pull(self.x, self.y, 1)
		else
			game.logPlayer(self, ("%s's tentacle fails to move %s!"):tformat(self.name:capitalize(), target:getName():capitalize()))
		end

		self:attackTargetWith(target, tentacle, nil, t.getDamageTentacle(self, t))
	end,
	callbackOnAct = function(self, t)
		local p = self:isTalentActive(t.id)
		if not p then return end
		
		local tentacle = self:callTalent(self.T_MUTATED_HAND, "getTentacleCombat")
		local release = false

		if not tentacle then game.logPlayer(self, "You require a mutated hand!") release = true end
		if p.target:attr("dead") or not game.level:hasEntity(p.target) or not self:hasLOS(p.target.x, p.target.y) then
			game.logPlayer(self, "Your constrict target has disappeared!")
			release = true
		end
		if release then
			game:onTickEnd(function() self:forceUseTalent(t.id, {ignore_energy=true}) end)
			return
		end
	end,
	activate = function(self, t)
		local tentacle = self:callTalent(self.T_MUTATED_HAND, "getTentacleCombat")
		if not tentacle then
			game.logPlayer(self, "You require a mutated hand!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTargetLimited(tg)
		if not x or not y or not target or target == self then return nil end

		if target:canBe("knockback") then 
			target:pull(self.x, self.y, tg.range)
		else
			game.logPlayer(self, "This target can not be moved!") 
		end

		local hx, hy = self:attachementSpot(self._flipx and "hand1" or "hand2", true)
		local ps = Particles.new("tentacle_pull", 1, {range=core.fov.distance(self.x, self.y, x, y), dir=math.deg(math.atan2(y-self.y, x-self.x)+math.pi/2)})
		ps.dx = hx ps.dy = hy self:addParticles(ps)

		target:setEffect(target.EFF_TENTACLE_CONSTRICT, 20, {src = self, dam = t.getDamageTentacle(self, t)})
		return {target = target}
	end,
	deactivate = function(self, t, p)
		p.target:removeEffect(p.target.EFF_TENTACLE_CONSTRICT)
		return true
	end,
	info = function(self, t)
		return ([[You extend your tentacle to grab a distant target, pulling it to you.
		As long as Constrict stays active the target is bound by your tentacle, it can try to move away but each turn you pull it back in 1 tile.
		While constricting you cannot use your tentacle to enhance your normal attacks but you deal %d%% tentacle damage each turn to your target.
		Enemies can resist the attempt to pull them but Constrict will always work for purposes of modifying your talents.
		Your other tentacle talents may act differently when used while constricting (check their descriptions).]]):
		tformat(t.getDamageTentacle(self, t) * 100)
	end,
}
