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
	name = "Rain of Fire",
	type = {"corruption/spellblaze", 1},
	require = corrs_req_high1,
	mode = "sustained",
	points = 5,
	remove_on_zero = true,
	sustain_vim = 8,
	drain_vim = 4,
	cooldown = 15,
	tactical = { ATTACKAREA = 3 },
	range = function(self, t) return 4 end,
	radius = function(self, t) return 2 end,
	requires_target = true,
	getDam = function(self, t) return self:combatTalentSpellDamage(t, 5, 1000) / 10 end,
	deactivate_on = {no_combat=true, run=true, rest=true},
	callbackOnActBase = function(self, t)
		if self.resting or self.running then return end
		local rad = self:getTalentRadius(t)
		local meteor = function(src, x, y, dam)
			game.level.map:particleEmitter(x, y, 10, "meteor", {x=x, y=y})
			game.level.map:particleEmitter(x, y, 10, "fireflash", {radius=rad})
			src:project({type="ball", radius=rad, selffire=false}, x, y, engine.DamageType.METEOR, dam)
			game:getPlayer(true):attr("meteoric_crash", 1)
		end

		local list = {}
		self:project({type="ball", radius=self:getTalentRange(t)}, self.x, self.y, function(px, py)
			local actor = game.level.map(px, py, Map.ACTOR)
			if actor and self:reactionToward(actor) < 0 then list[#list+1] = actor end
		end)

		local dam = 0
		if #list > 0 then dam = self:spellCrit(t.getDam(self, t)) end

		local nb = 0
		while #list > 0 and nb < 2 do
			local a = rng.tableRemove(list)			
			meteor(self, util.bound(a.x + rng.range(-1,1), 0, game.level.map.w-1), util.bound(a.y + rng.range(-1,1), 0, game.level.map.h-1), dam)
			nb = nb + 1
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[You unleash the fury of the Spellblaze, constantly draining your vim.
		While this spell is active at most two meteors will fall near your per turn, dealing %0.2f physical and %0.2f fire damage in radius 2.
		This spell disabled automatically on rest or run.
		The effects increase with spellpower.]])
		:tformat(damDesc(self, DamageType.PHYSICAL, t.getDam(self, t)), damDesc(self, DamageType.FIRE, t.getDam(self, t)))
	end,
}

newTalent{
	name = "Only Ashes Left",
	type = {"corruption/spellblaze", 2},
	require = corrs_req_high2,
	points = 5,
	mode = "passive",
	radius = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 4, 7)) end,
	getDam = function(self, t) return 10 + (self:combatTalentSpellDamage(t, 10, 350) / 10) end,
	doTimeout = function(self, t, tgt, dam)
		DamageType:get(DamageType.DARKNESS).projector(self, tgt.x, tgt.y, DamageType.DARKNESS, dam)
	end,
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if dead or target == self or not target.life or target.life > target.max_life * 0.33 then return end
		if target:hasEffect(target.EFF_ONLY_ASHES_LEFT) then return end
		if not target.x or not self.x or not game.level or core.fov.distance(target.x, target.y, self.x, self.y) > 4 then return end
		target:setEffect(target.EFF_ONLY_ASHES_LEFT, 1, {src=self, power=t.getDam(self, t), max_dist=self:getTalentRadius(t)})
	end,
	info = function(self, t)
		return ([[Bringing about the darkest days of the Spellblaze you hasten the death of your foes.
		When you deal damage to a creature in radius %d or less around you and it dips below 33%% life you automatically unleash the fury of the Spellblaze.
		Affected foes will start taking %0.2f darkness damage each turn until it dies as long as it remains in radius %d of you.
		The damage increases with spellpower.]]):
		tformat(self:getTalentRadius(t), damDesc(self, DamageType.DARKNESS, t.getDam(self, t)), self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Shattered Mind",
	type = {"corruption/spellblaze", 3},
	require = corrs_req_high3,
	points = 5,
	mode = "sustained",
	sustain_vim = 25,
	cooldown = 12,
	getSaves = function(self, t) return self:combatTalentScale(t, 10, 70) end,
	getFail = function(self, t) return self:combatTalentLimit(t, 35, 10, 25) end, -- Limit < 100%
	tactical = { BUFF = 3 },
	callbackOnBlock = function(self, t, eff, dam, type, src)
		if src.dead or not src.setEffect then return end
		src:setEffect(src.EFF_SHATTERED_MIND, 5, {fail=t.getFail(self, t), save=t.getSaves(self, t)})
	end,
	activate = function(self, t)
		local ret = {}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[When you block an attack the shock ripples through your attacker, spreading the force of the Spellblaze in its mind for 5 turns.
		While affected the creature will suffer %d%% chances to fail using talents and %d reduced physical, mental and spell saves.]]):
		tformat(t.getFail(self, t), t.getSaves(self, t))
	end,
}

newTalent{
	name = "Tale of Destruction",
	type = {"corruption/spellblaze", 4},
	require = corrs_req_high4,
	points = 5,
	mode = "sustained",
	sustain_vim = 30,
	cooldown = 20,
	tactical = { DISABLE = 3, BUFF = 3 },
	radius = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 2, 5)) end,
	getDur = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 3, 6)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 40) end,
	callbackOnKill = function(self, t, target, death_note)
		local tg = {type="ball", radius=self:getTalentRadius(t), friendlyfire=false}
		self:project(tg, self.x, self.y, function(px, py)
			local tgt = game.level.map(px, py, Map.ACTOR)
			if not tgt then return end
			if rng.percent(50) and tgt:canBe("confusion") then
				tgt:setEffect(tgt.EFF_BANE_CONFUSED, t.getDur(self, t), {apply_power=self:combatSpellpower(), src=self, power=50, dam=self:spellCrit(t.getDamage(self, t))})
			elseif tgt:canBe("blind") then
				tgt:setEffect(tgt.EFF_BANE_BLINDED, t.getDur(self, t), {apply_power=self:combatSpellpower(), src=self, dam=self:spellCrit(t.getDamage(self, t))})
			end
		end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "tale_of_destruction", {radius=tg.radius})
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[You chant the destruction of Mal'Rok, the demon's homeworld.
		Each time you kill a creature you send out a magical ripple in radius %d that applies a bane of blindness or confusion for %d turns.
		Baned creatures also suffer %0.2f darkness damage per turn.
		Damage increases with your spellpower.]]):
		tformat(self:getTalentRadius(t), t.getDur(self, t), damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)))
	end,
}
