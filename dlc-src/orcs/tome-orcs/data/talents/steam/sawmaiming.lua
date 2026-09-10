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
	name = "To The Arms",
	type = {"steamtech/sawmaiming",1},
	require = str_steamreq1,
	points = 5,
	steam = 15,
	cooldown = 9,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 1 }, DISABLE = { disarm = 2 } },
	getMaim = function(self, t) return math.floor(self:combatTalentLimit(t, 50, 20, 40)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 6, 2, 4)) end,
	on_pre_use = function(self, t, silent) if not self:hasWeaponType("steamsaw") then if not silent then game.logPlayer(self, "You require a steamsaw for this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasWeaponType("steamsaw")
		if not weapon then return nil end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.6))

		if hit then
			target:setEffect(target.EFF_TO_THE_ARMS, t.getDuration(self, t), {apply_power=self:combatPhysicalpower(), power = t.getMaim(self, t)})
		end

		return true
	end,
	info = function(self, t)
		return ([[Hits the target on the arms with one rotating saw doing %d%% damage and trying to maim it for %d turns.
		Maimed foes deal %d%% less damage.
		The chance improves with your Physical power.
		#{italic}#Cutting your foes has never been so simple!#{normal}#]]):
		tformat(100 * self:combatTalentWeaponDamage(t, 1, 1.6), t.getDuration(self, t), t.getMaim(self, t))
	end,
}

newTalent{
	name = "Bloodstream",
	type = {"steamtech/sawmaiming",2},
	require = str_steamreq2,
	points = 5,
	steam = 10,
	cooldown = 8,
	tactical = { ATTACK = 2 },
	getDamageInc = function(self, t) return self:combatTalentSteamDamage(t, 50, 250) end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 4, 1, 2)) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 50, 230) end,
	on_pre_use = function(self, t, silent) if not self:hasWeaponType("steamsaw") then if not silent then game.logPlayer(self, "You require a steamsaw for this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasWeaponType("steamsaw")
		if not weapon then return nil end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local was_cut = target:hasEffect(target.EFF_CUT)

		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.3, 1.1), true)

		local cut = target:hasEffect(target.EFF_CUT)
		if hit and was_cut and cut and not cut.bloodstreamed then
			cut.bloodstreamed = true
			cut.dur = cut.dur + t.getDuration(self, t)
			cut.power = cut.power * t.getDamage(self, t) / 100

			local tg = {type="cone", range=0, talent=t, radius=4, cone_angle = 25}
			self:project(tg, target.x, target.y, DamageType.PHYSICAL, self:steamCrit(t.getDamage(self, t)))
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_blood", {radius=tg.radius, tx=target.x-self.x, ty=target.y-self.y, spread=20})
		end

		return true
	end,
	info = function(self, t)
		return ([[You "gently" slam your saws into the wounds of a creature, dealing %d%% weapon damage and deepening the wounds.
		All bleeding wounds durations are increased by %d turns and the damage by %d%% (this may be done only once per bleeding effect).
		When this happens a gush of blood is projected in a narrow cone of radius 4, dealing %0.2f physical damage to all creatures.
		The power and damage improves with your Steampower.
		#{italic}#The marvels of technology, now at the service of true butchery!#{normal}#]]):
		tformat(self:combatTalentWeaponDamage(t, 0.3, 1.1) * 100, t.getDuration(self, t), t.getDamageInc(self, t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Spinal Break",
	type = {"steamtech/sawmaiming",3},
	require = str_steamreq3,
	points = 5,
	steam = 20,
	cooldown = 10,
	requires_target = true,
	getSlow = function(self, t) return self:combatTalentLimit(t, 0.6, 0.2, 0.5) end,
	getRemoveCount = function(self, t) return math.floor(self:combatTalentLimit(t, 4, 1, 1.5)) end,
	range = 1,
	tactical = { ATTACK = { PHYSICAL = 1 }, DISABLE = { slow = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasWeaponType("steamsaw") then if not silent then game.logPlayer(self, "You require a steamsaw for this talent.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasWeaponType("steamsaw")
		if not weapon then return nil end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.6, 1.5), true)

		if hit then
			target:setEffect(target.EFF_SLOW, 5, {power=t.getSlow(self, t)})

			local effs = {}

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "physical" and e.status == "beneficial" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained spells
			local sustains = {}
			for tid, act in pairs(target.sustain_talents) do
				if act then
					local talent = target:getTalentFromId(tid)
					if not talent.is_mind then
						sustains[#sustains+1] = {"talent", tid}
					end
				end
			end

			for i = 1, t.getRemoveCount(self, t) do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:dispel(eff[2], self)
				end
			end
			if self:getTalentLevel(t) >= 3 then
				for i = 1, t.getRemoveCount(self, t) do
					local sustain = rng.table(sustains)
					if sustain then
						target:dispel(sustain[2], self)
					end
				end
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[You try to sever the spine of your foe, reducing its global speed by %d%% for 4 turns and dealing %d%% weapon damage.
		The power of the blow also removes up to %d physical effects.
		If your talent level is at least 3 %d physical or magical sustains are also removed.
		#{italic}#Break them, grind them, mow them down!#{normal}#]]):
		tformat(t.getSlow(self, t) * 100, self:combatTalentWeaponDamage(t, 0.6, 1.5) * 100, t.getRemoveCount(self, t), t.getRemoveCount(self, t))
	end,
}


newTalent{
	name = "Goresplosion",
	type = {"steamtech/sawmaiming",4},
	require = str_steamreq4,
	points = 5,
	drain_steam = 10,
	mode = "sustained",
	range = 5,
	no_energy = true,
	cooldown = 15,
	getDuration = function(self, t) return self:combatTalentLimit(t, 6, 1, 4) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 150) end,
	on_pre_use = function(self, t, silent) if not self:hasWeaponType("steamsaw") then if not silent then game.logPlayer(self, "You require a steamsaw for this talent.") end return false end return true end,
	callbackOnKill = function(self, t, who, death_note)
		if not self.turn_procs or not self.turn_procs.weapon_type or not self.turn_procs.weapon_type.kind then return end

		local dam = self:steamCrit(t.getDamage(self, t))

		local tg = {type="ball", selffire=false, radius=self:getTalentRange(t), x=who.x, y=who.y}
		self:project(tg, who.x, who.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if target:canBe("cut") then
				target:setEffect(target.EFF_CUT, 6, {src=self, power=dam / 6, no_ct_effect = true})
			end
			if target:canBe("silence") then
				target:setEffect(target.EFF_SILENCED, t.getDuration(self, t), {apply_power=self:combatSteampower()})
			end
		end)
		game.level.map:particleEmitter(who.x, who.y, tg.radius, "ball_blood", {radius=tg.radius})
	end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[When you kill a foe you place small explosives with shrapnels inside its body, making it explode in radius %d.
		Any foes hit will bleed for %0.2f damage per turn for 6 turns. The shrapnels also damage the vocal cords (or related organ), silencing them for %d turns.
		#{italic}#Use the finest of wartech now: shrapnels. For blood and mayhem!#{normal}#]]):
		tformat(self:getTalentRange(t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t) / 6), t.getDuration(self, t))
	end,
}

