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

local Object = require "engine.Object"

newTalent{
	name = "Automated Cloak Tessellation",
	type = {"steamtech/avoidance", 1},
	points = 5,
	cooldown = 10,
	mode = "sustained",
	drain_steam = 3,
	require = steamreq1,
	tactical = { BUFF=3 },
	message = _t"@Source@ tessellates @hisher@ cloak!",
	getArmor = function(self, t) return self:combatTalentSteamDamage(t, 2, 40) end,
	getEvasion = function(self, t) return self:combatLimit(self:combatTalentSteamDamage(t, 5, 40), 65, 25, 10, 45, 60) end, --limit 65% avoidance
	on_pre_use = function(self, t, silent) if not self:hasCloak() then if not silent then game.logPlayer(self, "You require a cloak to use this talent.") end return false end return true end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "projectile_evasion", t.getEvasion(self, t))
		self:talentTemporaryValue(ret, "projectile_evasion_spread", 1)
		self:talentTemporaryValue(ret, "flat_damage_armor", {all=t.getArmor(self, t)})
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[You tessellate your cloak with small pieces of metal, providing %d damage reduction against all attacks.
		The myriad metal scraps also help against incoming projectiles, providing a %d%% chance of deflecting them to a nearby spot.]])
		:tformat(t.getArmor(self, t), t.getEvasion(self, t))
	end,
}

newTalent{
	name = "Cloak Gesture",
	type = {"steamtech/avoidance", 2},
	points = 5,
	require = steamreq2,
	cooldown = 12,
	steam = 20,
	getLength = function(self, t) return math.floor(self:getTalentLevel(t) / 2) * 2 + 1 + 2 end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 2, 240) end,
	message = _t"@Source@ weaves @hisher@ cloak!",
	requires_target = true,
	tactical = { ATTACK = { FIRE=1 }, ESCAPE=2 },
	on_pre_use = function(self, t, silent) if not self:hasCloak() then if not silent then game.logPlayer(self, "You require a cloak to use this talent.") end return false end return true end,
	action = function(self, t)
		local halflength = 1 + math.floor(self:getTalentLevel(t) / 2)
		local block = function(_, lx, ly)
			return game.level.map:checkAllEntities(lx, ly, "block_move")
		end
		local tg = {type="wall", range=1, halflength=halflength, talent=t, halfmax_spots=halflength+1, simple_dir_request=true, block_radius=block}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end

		local dam = self:steamCrit(t.getDamage(self, t))

		self:project(tg, x, y, function(px, py, tg, self)
			local e = Object.new{
				block_sight=true,
				temporary = 5,
				x = px, y = py,
				canAct = false,
				act = function(self)
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map:remove(self.x, self.y, engine.Map.TERRAIN+2)
						game.level:removeEntity(self)
						game.level.map:redisplay()
					end
				end,
				summoner_gain_exp = true,
				summoner = self,
			}
			game.level:addEntity(e)
			game.level.map(px, py, Map.TERRAIN+2, e)
			game.level.map:addEffect(self, px, py, 5, engine.DamageType.FIRE, dam, 0, 5, nil, {type="burning-steam"}, nil, nil)
		end)

		if self:getTalentLevel(t) >= 5 then
			local tg = {type="ball", range=self:getTalentRange(t), radius=10, friendlyfire=false, talent=t}
			self:project(tg, self.x, self.y, function(tx, ty)
				local a = game.level.map(tx, ty, Map.ACTOR)
				if a and a:reactionToward(self) < 0 then
					a:setTarget(nil)
				end
			end)
		end

		return true
	end,
	info = function(self, t)
		return ([[With a gesture of your cloak, you drop a small incendiary device in front of you, creating a wall of thick steam of %d length that burns creatures passing it for %0.2f fire damage and blocks sight for 5 turns.
		At level 5 the action is so perfect that your foes even lose track of you entirely.
		Damage increases with your steampower.]])
		:tformat(t.getLength(self, t), damDesc(self, DamageType.FIRE, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Embedded Restoration Systems",
	type = {"steamtech/avoidance", 3},
	points = 5,
	mode = "sustained",
	cooldown = 30,
	drain_steam = 2,
	require = steamreq3,
	tactical = { BUFF=2 },
	getCD = function(self, t) return math.ceil(self:combatTalentLimit(t, 2, 9, 5)) end, --limit > 2
	getHeal = function(self, t) return self:combatTalentSteamDamage(t, 20, 250) end,
	on_pre_use = function(self, t, silent) if not self:hasCloak() then if not silent then game.logPlayer(self, "You require a cloak to use this talent.") end return false end return true end,
	on_pre_use_ai = function(self, t, silent) -- don't turn this on unnecessarily
		if self.steam_regen <= t.drain_steam then
			if self.steam < t.drain_steam then return false end
			local nb_foes = t.countfoes(self, t)
			if nb_foes <= 0 then return false end
		end
		return true
	end,
	countfoes = function(self, t)
		local nb_foes = 0
		local act
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			if act and self:reactionToward(act) < 0 and self:canSee(act) then nb_foes = nb_foes + 1 end
		end
		return nb_foes
	end,
	doRestoration = function(self, t)
		local do_cure = false
		if self:getTalentLevel(t) >= 5 then if #self:effectsFilter({status="detrimental", type="physical"}, 1) > 0 then do_cure = true end end
		if self.life >= self.max_life and not do_cure then return end

		game.logSeen(self, "#LIGHT_BLUE#%s's embedded restoration system activate.", self:getName():capitalize())
		self:attr("allow_on_heal", 1)
		self:heal(self:steamCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
		end

		if self:getTalentLevel(t) >= 3 then
			self:removeEffectsFilter(self, {status="detrimental", type="physical"}, 1)
		end

		game:playSoundNear(self, "talents/heal")
		return true
	end,
	callbackOnAct = function(self, t)
		local p = self.sustain_talents[t.id]
		if p.resto_cd then
			p.resto_cd = p.resto_cd - 1
			if p.resto_cd > 0 then return end
			p.resto_cd = nil
		end

		game:onTickEnd(function()
			local nb_foes = t.countfoes(self, t)
			if p.nb_foes > 0 and nb_foes == 0 and not self:attr("no_healing") then
				if t.doRestoration(self, t) then
					p.resto_cd = t.getCD(self, t)
				end
			end
			p.nb_foes = nb_foes
		end)
	end,
	activate = function(self, t)
		game.logSeen(self, "%s activates %s cloak's restoration systems!", self:getName():capitalize(), self:his_her())
		return {nb_foes = 0}
	end,
	deactivate = function(self, t, p)
		game.logSeen(self, "%s deactivates %s cloak's restoration systems.", self:getName():capitalize(), self:his_her())
		return true
	end,
	info = function(self, t)
		return ([[Your cloak is lined with an automated health system that activate when no enemies are visible.
		When it triggers, you will be healed for %d life.
		At talent level 3, it will also remove one detrimental physical effect.
		The system can only trigger once every %d turns.]])
		:tformat(t.getHeal(self, t), t.getCD(self, t))
	end,
}

newTalent{
	name = "Cloaking Device", short_name="CLOAK",
	type = {"steamtech/avoidance", 4},
	points = 5,
	cooldown = 25,
	steam = 45,
	require = steamreq4,
	requires_target = true,
	tactical = { ESCAPE = 2, BUFF=1 },
	getStealth = function(self, t) return self:combatTalentSteamDamage(t, 3, 150) end,
	on_pre_use = function(self, t, silent) if not self:hasCloak() then if not silent then game.logPlayer(self, "You require a cloak to use this talent.") end return false end return true end,
	action = function(self, t)
		self:setEffect(self.EFF_CLOAK, 10, {power=t.getStealth(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Trigger an array of small mirrors to appear all over your cloak.
		The mirrors are positioned to reflect all light shining on you, granting %d stealth power for 10 turns.
		Stealth power increases with your steampower.]]):
		tformat(t.getStealth(self, t))
	end,
}
