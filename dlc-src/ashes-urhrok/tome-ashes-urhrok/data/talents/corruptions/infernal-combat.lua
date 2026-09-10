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
	name = "Flame Leash",
	type = {"corruption/infernal-combat", 1},
	require = corrs_req1,
	points = 5,
	vim = 5,
	stamina = 8,
	cooldown = 8,
	tactical = { ATTACKAREA = 2, CLOSEIN = 2 },
	range = 6,
	requires_target = true,
	getDam = function(self, t) return self:combatTalentSpellDamage(t, 5, 700) / 10 end,
	getSlow = function(self, t) return self:combatTalentLimit(t, 0.5, 0.2, 0.4) end,
	target = function(self, t)
		return {type="cone", cone_angle=25, range=0, radius=self:getTalentRange(t), friendlyfire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local burns = {}
		local list = {}
		local tgts = table.values(self:projectCollect(tg, x, y, Map.ACTOR, "hostile"))
		table.sort(tgts, "dist")
		for i, info in ipairs(tgts) do
			local actor, x, y = info.target, info.x, info.y
			if core.shader.active() then game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "flame_leash", {tx=x-self.x, ty=y-self.y}, {type="lightning", color1=colors.hex1"fdb406", color2=colors.hex1"fd2906"})
			else game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "flame_leash", {tx=x-self.x, ty=y-self.y})
			end
			list[#list+1] = {x=x, y=y}
			actor:pull(self.x, self.y, tg.radius)
			actor:setEffect(actor.EFF_SLOW_MOVE, 4, {power=t.getSlow(self, t)})
		end
		for _, c in ipairs(list) do
			local grids = self:project({type="beam", range=tg.radius}, c.x, c.y, function()end)
			for px, ys in pairs(grids) do burns[px] = burns[px] or {} for py, _ in pairs(ys) do burns[px][py] = true end end
		end
		local dam = self:spellCrit(t.getDam(self, t))
		for px, ys in pairs(burns) do
			for py, _ in pairs(ys) do
				game.level.map:addEffect(self, px, py, 4, engine.DamageType.FIRE, dam, 0, 5, nil, {type="inferno"}, nil, true)
			end
		end

		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[Tendrils of flame fire from your hands in a narrow cone. Any foes caught inside will be pulled in towards you and have its movement speed reduced by %d%% for 4 turns.
		Each tendril will leave a trail of fire in its path dealing %0.2f fire damage for 4 turns.
		The damage increases with spellpower.]])
		:tformat(t.getSlow(self, t) * 100, damDesc(self, DamageType.FIRE, t.getDam(self, t)))
	end,
}

newTalent{
	name = "Demon Blade",
	type = {"corruption/infernal-combat", 2},
	require = corrs_req2,
	points = 5,
	vim = 20,
	stamina = 15,
	cooldown = 10,
	no_energy = true,
	getDam = function(self, t) return 5 + (self:combatTalentSpellDamage(t, 10, 100)) end,
	action = function(self, t)
		self:setEffect(self.EFF_DEMON_BLADE, 5, {dam=self:spellCrit(t.getDam(self, t))})
		return true
	end,
	info = function(self, t)
		return ([[Imbue your weapon with fire for 5 turns. During this time all your melee hits will trigger a ball of fire of radius 1 dealing %0.2f fire damage.
		This effect can only happen once per turn.
		The damage increases with spellpower.]]):
		tformat(damDesc(self, DamageType.FIRE, t.getDam(self, t)))
	end,
}

newTalent{
	name = "Link of Pain",
	type = {"corruption/infernal-combat", 3},
	require = corrs_req3,
	points = 5,
	vim = 15,
	stamina = 10,
	cooldown = 5,
	range = 7,
	no_npc_use = true,
	no_energy = true,
	getPower = function(self, t) return math.floor(self:combatTalentLimit(t, 100, 40, 80)) end,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	action = function(self, t)
		game.logPlayer(self, "Select the source:")
		local tg = {type="hit", default_target=self, nowarning=true, range=self:getTalentRange(t), talent=t, first_target="friend"}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end

		game.logPlayer(self, "Select the victim:")
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local victim = game.level.map(x, y, Map.ACTOR)
		if not victim or victim == target then return end

		target:setEffect(target.EFF_LINK_OF_PAIN, t.getDur(self, t), {power=t.getPower(self, t), victim=victim, src=self})

		return true
	end,
	info = function(self, t)
		return ([[Using demonic forces you create a link of pain from a source creature to a victim for %d turns.
		Each time the source creature takes damage the victim takes %d%% of the damage.
		If the victim dies from the effect you gain a burst of energy, reducing all remaining cooldowns by 1.]]):
		tformat(t.getDur(self, t), t.getPower(self, t))
	end,
}

newTalent{
	name = "Demon Horns",
	type = {"corruption/infernal-combat", 4},
	require = corrs_req4,
	points = 5,
	cooldown = 14,
	vim = 12,
	stamina = 15,
	requires_target = true,
	tactical = { ATTACK = 2, HEAL = 1 },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	getHeal = function(self, t) return (40 + self:combatTalentSpellDamage(t, 10, 520)) / 4 end,
	doTimeout = function(self, t, tgt, dam)
		DamageType:get(DamageType.DARKNESS).projector(self, tgt.x, tgt.y, DamageType.DARKNESS, dam)
	end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then return nil end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local speed, hit, dam = self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 1, 2, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))

		if hit and dam then
			if target:canBe("cut") then
				target:setEffect(target.EFF_DEMONIC_CUT, 5, {apply_power=self:combatSpellpower(), src=self, heal=t.getHeal(self, t), dam=dam * 0.5 / 5})
			else
				game.logSeen(target, "%s resists the shield bash!", target:getName():capitalize())
			end
			if target.dead then
				game:setAllowedBuild("cosmetic_doomhorns", true)
			end
		end

		game.level.map:particleEmitter(x, y, 1, "circle", {shader=true, oversize=1, a=150, appear=8, limit_life=14, base_rot=0, speed=0, img="doomhorns", radius=0})
		return true
	end,
	info = function(self, t)
		return ([[Demon horns temporarily grow on your shield as you bash a foe with it for %d%% damage.
		If the attack hits the creature is impaled by the horns, causing it to bleed black blood for 50%% of the damage done as darkness over 5 turns.
		Any time you damage this foe in melee while it bleeds you get healed for %d (this can only happen once per turn).
		The healing power increases with your spellpower.]])
		:tformat(100 * self:combatTalentWeaponDamage(t, 1, 2, self:getTalentLevel(self.T_SHIELD_EXPERTISE)), t.getHeal(self, t))
	end,
}
