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
	name = "Void Stars",
	type = {"demented/void", 1},
	require = dementedreq1,	
	points = 5,
	mode = "sustained", no_sustain_autoreset = true,
	cooldown = 10,
	tactical = { DEFEND = 4 },
	direct_hit = true,
	getReduction = function(self, t) return self:combatTalentLimit(t, 0.75, 0.15, 0.45) end,
	getRegen = function(self, t) return math.max(self:combatTalentScale(t, 14, 9), 5) end,
	on_pre_use = function(self, t, silent) if not self:hasLightArmor() then if not silent then game.logPlayer(self, "You must be wearing light armor for this talent.") end return false end return true end,
	iconOverlay = function(self, t, p)
		local p = self.sustain_talents[t.id]
		if not p or not p.nb then return "" end
		return p.nb.."/"..4, "buff_font_smaller"
	end,
	callbackOnRest = function(self, t)
		local nb = 4
		local p = self.sustain_talents[t.id]
		if not p or p.nb < nb then return true end
	end,
	callbackOnActBase = function(self, t)
		if not self:hasLightArmor() then return end
		local p = self.sustain_talents[t.id]
		p.next_regen = (p.next_regen or 1) - 1
		if p.next_regen <= 0 then
			p.next_regen = p.between_regens or 10

			if p.nb < 4 then
				p.nb = p.nb + 1
				if p.nb == 4 and self.nullmail_recharge then self.nullmail_recharge = nil end
				if p.adv_gfx then
					if p.particles[1] and p.particles[1].shader and p.particles[1]._shader and p.particles[1]._shader.shad then
						p.particles[1]._shader.shad:resetClean()
						p.particles[1]._shader:setResetUniform("chargesCount", util.bound(p.nb, 0, 10))
						p.particles[1].shader.chargesCount = util.bound(p.nb, 0, 10)
					end
				else
					p.particles[#p.particles+1] = self:addParticles(Particles.new("bone_shield", 1))
				end
				game.logSeen(self, "A void star appears around %s.", self:getName())
			end
		end
	end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		local p = self.sustain_talents[t.id]
		if not p.nb or p.nb <= 0 then return end
		
		if dam > 0 and state and not self:attr("invulnerable") then
			if dam > self.max_life*0.1 then

				local reduce = t.getReduction(self, t)*dam
				if src.logCombat then src:logCombat(self, "#FIREBRICK##Target#'s void star absorbs the damage from #Source#, converting it into entropy!#LAST#") end
				dam = dam - reduce
--				print("[PROJECTOR] dam after callbackOnTakeDamage", t.id, dam)
				local d_color = DamageType:get(type).text_color or "#FIREBRICK#"
				game:delayedLogDamage(src, self, 0, ("%s(%d to entropy)"):tformat(d_color, reduce, stam_txt, d_color), false)
				self:setEffect(self.EFF_ENTROPIC_WASTING, 8, {src=self, power=math.floor(reduce/20)})
				p = self:getTalentFromId(self.T_VOID_STARS)
				p.consume_star(self, t, p)
				return {dam = dam}
			end
		end
	end,
	consume_star = function(self, t, p)
		local p = self.sustain_talents[self.T_VOID_STARS]

		p.nb = p.nb - 1
		if p.adv_gfx then
			-- .shader is stripped on clone, not sure if this sanity check is the right way to handle this
			if p.particles[1] and p.particles[1].shader and p.particles[1]._shader and p.particles[1]._shader.shad and p.particles[1].shader then
				p.particles[1]._shader.shad:resetClean()
				p.particles[1]._shader:setResetUniform("chargesCount", util.bound(p.nb, 0, 10))
				p.particles[1].shader.chargesCount = util.bound(p.nb, 0, 10)
			end
		else
			local pid = table.remove(p.particles)
			self:removeParticles(pid)
		end
		
		if self:knowTalent(self.T_NULLMAIL) and p.nb == 0 and not self.nullmail_recharge then
			self:setEffect(self.EFF_DAMAGE_SHIELD, 4, {color={0xe1/255, 0xcb/255, 0x3f/255}, image="nullmail", power=self:spellCrit(self:callTalent(self.T_NULLMAIL, "getAbsorb"))})
			self.nullmail_recharge = 1
		end

		return true
	end,
	activate = function(self, t)
		local nb = 1

		local adv_gfx = core.shader.allow("adv") and true or false
		local ps = {}
		if adv_gfx then
			ps[1] = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.5, rotation=0, radius=1.5, img="void_stars"}, {type="boneshield"}))
			ps[1]._shader.shad:resetClean()
			ps[1]._shader:setResetUniform("chargesCount", util.bound(nb, 0, 10))
			ps[1].shader.chargesCount = util.bound(nb, 0, 10)
		else
			for i = 1, nb do ps[#ps+1] = self:addParticles(Particles.new("bone_shield", 1)) end
		end

		game:playSoundNear(self, "talents/spell_generic2")
		return {
			adv_gfx = adv_gfx,
			particles = ps,
			nb = nb,
			next_regen = t.getRegen(self, t),
			between_regens = t.getRegen(self, t),
		}
	end,
	deactivate = function(self, t, p)
		for i, particle in ipairs(p.particles) do self:removeParticles(particle) end
		return true
	end,
	info = function(self, t)
		local power = t.getReduction(self,t)*100
		local regen = t.getRegen(self,t)
		return ([[Conjure void stars that orbit you, defending you from incoming attacks. Each time an attack deals more than 10%% of your maximum life, a star will be consumed to reduce the damage taken by %d%%, of which 40%% will be dealt to you as entropic backlash.
		You regenerate 1 star every %d turns, stacking up to 4 times.
		This talent will only function in light armor.]]):
		tformat(power, regen)
	end,
}

newTalent{
	name = "Nullmail",
	type = {"demented/void", 2},
	require = dementedreq2,
	points = 5,
	mode = "passive",	
	getArmor = function(self, t) return self:combatTalentStatDamage(t, "mag", 10, 50) * t.ArmorEffect(self,t) end,
	getAbsorb = function(self, t) return (50 + self:combatTalentSpellDamage(t, 30, 200)) * t.ArmorEffect(self,t) end,
	getDuration = function(self, t) return 4 end,
	ArmorEffect = function(self, t)  -- Becomes more effective with lighter armors
		if not self:getInven("BODY") then return 0 end
		local am = self:getInven("BODY")[1]
		if not am or am.subtype == "cloth" then return 1
		elseif am.subtype == "mummy" then return 1
		elseif am.subtype == "light" then return 1
		end
		return 0
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_armor", t.getArmor(self, t))
	end,
	callbackOnWear = function(self, t, o, bypass_set)
		self:updateTalentPassives(t)
	end,
	callbackOnTakeoff = function(self, t, o, bypass_set)
		self:updateTalentPassives(t)
	end,
	info = function(self, t)
		local armor = t.getArmor(self, t)
		local power = self:getShieldAmount(t.getAbsorb(self, t))
		return ([[Reinforce your armor with countless tiny void stars, increasing armor by %d.
Each time your void stars are fully depleted, you gain a shield absorbing the next %d damage taken within %d turns. This shield cannot trigger again until your void stars are fully restored.]]):
		tformat(armor, power, self:getShieldDuration(4))
	end,
}

newTalent{
	name = "Black Monolith",
	type = {"demented/void", 3},
	require = dementedreq3,
	points = 5,
	insanity = 20,
	cooldown = 18,
	tactical = { ATTACKAREA = 3, DISABLE = 3 },
	requires_target = true,
	range = 10,
	direct_hit = true,
	on_pre_use = function(self, t, silent)
		local p = self:isTalentActive(self.T_VOID_STARS)
		if not p or not p.nb or p.nb <= 0 then 
			if not silent then 
				game.logPlayer(self, "You must have at least 1 void star to summon a monolith.") 
			end 
			return false 
		end 
		return true 
	end,
	getStats = function(self, t) return self:getMag() end,
	getResist = function(self, t) return self:combatStatLimit("mag", 70, 15, 40) end,
	getLifeRating = function(self, t) return math.floor(self:combatStatScale("mag", 1, 4)) end,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 4, 7.5)) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), nolock=true} end,
	radius = function(self, t) return 1 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTargetLimited(tg)
		if not x or not y then return nil end
		x, y = util.findFreeGrid(x, y, 3, true, {[Map.ACTOR]=true})
		if not x then game.logPlayer(self, "Not enough space to summon your monolith!") return end
		local rad = self:getTalentRadius(t)

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "horror", subtype = "eldritch",
			display = "h", blood_color = colors.BLUE,
			faction = "horrors",
			stats = { str=t.getStats(self, t), dex=t.getStats(self, t), wil=t.getStats(self, t), mag=t.getStats(self, t), con=t.getStats(self, t), cun=t.getStats(self, t) },
			infravision = 10,
			no_breath = 1,
			never_move = 1,
			cant_be_moved = 1,
			name = _t"void monolith", color=colors.GREY,
			desc = _t"This bizarre oblong shape floats in the air, defying gravity. Its form seems to subtly shift, and you feel an intense desire to move towards it.",
			resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/black_monolith.png", display_h=2, display_y=-1}}},
			level_range = {self.level, self.level}, exp_worth = 0,
			rank = 2,
			levitate=1,
			size_category = 3,
			autolevel = "wildcaster",
			life_rating = 10 + t.getLifeRating(self, t),
			negative_status_effect_immune = 1,
			combat_armor = math.floor(3*self.level^.75),
			combat_armor_hardiness = 100,
			resists = {all = t.getResist(self, t)},
			negative_status_immune = 1,
			rad = rad,

			on_act = function(self)
				local tg = {type="ball", range=0, friendlyfire=false, radius=self.rad}	
				self:project(tg, self.x, self.y, engine.DamageType.MESMERIZE, {apply_power = self:combatSpellpower()} )
				self.energy.value = 0
			end,

			ai = "summoned", ai_real = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },
			no_drops = true, keep_inven_on_death = false,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDur(self, t),
		}

		-- Snapshot the casters effective (not base) spellpower
		m.summoner_spellpower = self:combatSpellpower()
		m.combatSpellpower = function(self) return self.summoner_spellpower end

		m:resolve()
		m:resolve(nil, true)		
		game.zone:addEntity(game.level, m, "actor", x, y)
		if target then m:setTarget(target) end
		if game.party:hasMember(self) then
			m.remove_from_party_on_death = true
			game.party:addMember(m, {
				control=false,
				temporary_level = true,
				type="summon",
				title=_t"Summon",
			})
		end
		local p = self:getTalentFromId(self.T_VOID_STARS)
		p.consume_star(self, t, p)

		game:playSoundNear(self, "talents/black_monolith")
		return true
	end,
	info = function(self, t)
		return ([[Consuming a void star, you use it to summon a void monolith at the targeted location for %d turns. The monolith is very durable, and while immobile it will attempt to daze enemies within radius %d for 2 turns every half a turn using your spellpower.
			The monolith will gain %d life rating and %d%% all resist based on your Magic stat.]]):
		tformat(t.getDur(self, t), self:getTalentRadius(t), t.getLifeRating(self, t), t.getResist(self, t))
	end,
}

newTalent{
	name = "Essence Reave",
	type = {"demented/void", 4},
	require = dementedreq4,
	points = 5,
	insanity = -25,
	cooldown = 6,
	tactical = { ATTACK= { DARKNESS = 2, TEMPORAL = 2 }, DEFEND = 2 },
	requires_target = true,
	range = 10,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 320) end,
	getNb = function(self, t) return math.min(2, math.floor(self:combatTalentScale(t, 1, 2))) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end
		
		local dam = self:spellCrit(t.getDamage(self, t))
		local nb = t.getNb(self,t)
		
		DamageType:get(DamageType.VOID).projector(self, target.x, target.y, DamageType.VOID, dam)

		local p = self:isTalentActive(self.T_VOID_STARS)
		if p then
			nb = math.min(nb, 4 - p.nb)
			p.nb = nb + p.nb
			game.logSeen(self, "%s rends the essence of %s, restoring %d void shards!", self:getName(), target:getName(), nb)			
		end

		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)/2
		local nb = t.getNb(self,t)
		return ([[You rend the very essence of the target, drawing on their life and converting it to void stars. The target takes %0.2f darkness and %0.2f temporal damage, and you gain %d void star(s).
		The damage will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.DARKNESS, (damage)), damDesc(self, DamageType.TEMPORAL, (damage)), nb)
	end,
}