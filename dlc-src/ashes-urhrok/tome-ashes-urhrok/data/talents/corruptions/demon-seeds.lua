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
local Object = require "mod.class.Object"

newTalent{
	name = "Flame Bolts", short_name = "DEMON_SEED_FIRE_BOLTS",
	type = {"corruption/demon-seeds",1},
	points = 5,
	range = 5,
	radius = 5,
	proj_speed = 7,
	mode = "passive",
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 18, 120) end,
	callbackOnMeleeAttack = function(self, t, _, hitted)
		if not hitted or not rng.percent(self:getTalentLevel(t) * 5 + 20) then return end

		local tg = self:getTalentTarget(t)
		local tgts = {}
		local grids = self:project(tg, self.x, self.y, function(px, py)
			local actor = game.level.map(px, py, Map.ACTOR)
			if actor and self:reactionToward(actor) < 0 then
				tgts[#tgts+1] = actor
			end
		end)

		local nb = 1+math.ceil(self:getTalentLevel(t)/2)
		while nb > 0 and #tgts > 0 do
			local actor = rng.tableRemove(tgts)
			local tg2 = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire", trail="firetrail"}}
			self:projectile(tg2, actor.x, actor.y, DamageType.FIRE, self:spellCrit(t.getDamage(self, t)), {type="flame"})
		end

		game:playSoundNear(self, "talents/fire")
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Randomly (%d%% chance) hurls up to %d flame bolts dealing %0.2f fire damage to foes in sight when you hit in melee.
		The damage will increase with your Spellpower.]]):
		tformat(self:getTalentLevel(t) * 5 + 20, 1+math.ceil(self:getTalentLevel(t) / 2), damDesc(self, DamageType.FIRE, damage))
	end,
}

local what = {physical=true, mental=true, magical=true}
newTalent{
	name = "Fiery Cleansing", short_name = "DEMON_SEED_FIERY_CLEANSING",
	type = {"corruption/demon-seeds",1},
	points = 5,
	cooldown = function(self, t) return self:combatTalentLimit(t, 10, 30, 15) end,
	vim = 15,
	no_energy = true,
	tactical = {
		DEFEND = 3,
		CURE = function(self, t, target)
			local nb = 0
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if what[e.type] and e.status == "detrimental" then
					nb = nb + 1
				end
			end
			return nb
		end
	},
	getNb = function(self, t) return self:combatTalentScale(t, 1, 5) end,
	on_pre_use = function(self, t) return self.life > self.max_life * 0.2 end,
	action = function(self, t)
		self:takeHit(self.max_life * 0.2, self)

		local target = self
		local effs = {}
		local force = {}
		local known = false

		-- Go through all temporary effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if what[e.type] and e.status == "detrimental" and e.subtype["cross tier"] then
				force[#force+1] = {"effect", eff_id}
			elseif what[e.type] and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		-- Cross tier effects are always removed and not part of the random game, otherwise it is a huge nerf to wild infusion
		for i = 1, #force do
			local eff = force[i]
			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end

		for i = 1, t.getNb(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end
		if known then
			game.logSeen(self, "%s is cured!", self:getName():capitalize())
		end

		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healred", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1=colors.hex1alpha"c52505FF", beamColor2=colors.hex1alpha"f69566FF"}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healred", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1=colors.hex1alpha"c52505FF", beamColor2=colors.hex1alpha"f69566FF"}))
			game.level.map:particleEmitter(self.x, self.y, 1, "shader_ring_rotating", {rotation=0, radius=1.2, life=30, y=0.2, img="flamesshockwave"}, {type="firearcs"})
		end

		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[Deals 20%% of your total life to cleanse your afflictions, removing up to %d physical, mental or magical detrimental effects.]]):
		tformat(t.getNb(self, t))
	end,
}

newTalent{
	name = "Farstrike", short_name = "DEMON_SEED_FARSTRIKE",
	type = {"corruption/demon-seeds",1},
	points = 5,
	cooldown = 3,
	vim = 6,
	tactical = { ATTACK = 2 },
	requires_target = true,
	range = function(self, t) return 2 + math.floor(self:combatTalentLimit(t, 8, 1, 6)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 2) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)

		if not target then return end
		
		self:attackTarget(target, nil, t.getDamage(self, t), true)
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[You send your weapon flying to the target, dealing %d%% weapon damage.]]):
		tformat(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Corrosive Slashes", short_name = "DEMON_SEED_CORROSIVE_SLASHES",
	type = {"corruption/demon-seeds",1},
	points = 5,
	cooldown = 10,
	sustain_vim = 5,
	tactical = { BUFF = 2 },
	mode = "sustained",
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 2) end,
	getArmorPen = function(self, t) return self:combatTalentScale(t, 15, 65) end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if hitted then game.level.map:particleEmitter(target.x, target.y, 1, "corrosive_slashes") end
	end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "combat_apr", t.getArmorPen(self, t))
		self:talentTemporaryValue(ret, "force_melee_damtype", DamageType.ACID)
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[You cover your weapon in acid, turning all melee damage into acid.
		All melee attacks also gain %d armor penetration.]]):
		tformat(t.getArmorPen(self, t))
	end,
}

newTalent{
	name = "Acidic Bath", short_name = "DEMON_SEED_ACIDIC_BATH",
	type = {"corruption/demon-seeds",1},
	points = 5,
	cooldown = 15,
	vim = 12,
	tactical = { ATTACKAREA = 1, HEAL = 1 },
	requires_target = true,
	range = 4,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 777) / 10 end,
	getDuration = function(self, t) return self:combatTalentScale(t, 4, 10, 0.5) end,
	getAffinity = function(self, t) return self:combatTalentScale(t, 50, 120, 0.5) end,
	action = function(self, t)
		local duration = t.getDuration(self, t)
		local dam = t.getDamage(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.ACID, dam,
			self:getTalentRange(t),
			5, nil,
			{type="vapour"},
			function(e)
				-- We dont like cheese!
				if not e.src:knowTalent(e.src.T_DEMON_SEED_ACIDIC_BATH) then e.duration = 0 end
			end, nil
		)
		self:setEffect(self.EFF_ACIDIC_BATH, duration, {res=40, aff=t.getAffinity(self, t)})
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		return ([[You spawn a pool of acid in radius 4 around you for %d turns, dealing %0.2f acid damage to all creatures, including you.
		You also gain 40%% acid resistance and %d%% acid affinity.
		The damage scales with your Spellpower.]]):
		tformat(t.getDuration(self, t), damDesc(self, DamageType.ACID, t.getDamage(self, t)), t.getAffinity(self, t))
	end,
}

newTalent{
	name = "Blighted Path", short_name = "DEMON_SEED_BLIGHTED_PATH",
	type = {"corruption/demon-seeds",1},
	points = 5, no_sustain_autoreset = true,
	mode = "sustained",
	cooldown = 10,
	range = 5,
	no_energy = true,
	no_npc_use = true,
	getShield = function(self, t) return self:combatTalentSpellDamage(t, 50, 500) / 9 end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 50, 400) / 9 end,
	getVim = function(self, t) return self:combatTalentScale(t, 3, 10, 0.5) end,
	getMaxCharges = function(self, t) return 4 + math.floor(self:getTalentLevel(t)) * 2 end,
	iconOverlay = function(self, t, p)
		local val = p.charges or 0
		if val <= 0 then return "" end
		return tostring(math.ceil(val)), "buff_font_small"
	end,
	callbackOnMove = function(self, t, moved, force, ox, oy)
		if not moved or force or (self.x == ox and self.y == oy) then return end
		local p = self:isTalentActive(t.id)
		if not p then return end
		p.charges = util.bound(p.charges + 1, 0, t.getMaxCharges(self, t))
	end,
	activate = function(self, t)
		return {
			charges = 0,
		}
	end,
	deactivate = function(self, t, p)
		if self:attr("save_cleanup") then return true end
		if not p.charges or p.charges < 1 then return true end

		local d = Dialog:listPopup(_t"Blighted Path", ("Select a use for the %s charge(s):"):tformat(p.charges), {
			{kind="shield", name=("Shield for %d damage (50%% reflect)."):tformat(t.getShield(self, t) * p.charges)},
			{kind="attack", name=("Attack for #DARK_GREEN#%0.2f blight damage"):tformat(damDesc(self, DamageType.BLIGHT, t.getDamage(self, t) * p.charges))},
			{kind="vim", name=("Restore #904010#%0.2f vim"):tformat(t.getVim(self, t) * p.charges)},
		}, 300, 150, function(sel)
			if not sel then self:talentDialogReturn(false) return end
			self:talentDialogReturn(sel.kind)
		end)
		d.key:removeBind("EXIT")
		local kind = self:talentDialog(d)
		if not kind then return nil end

		if kind == "attack" then
			local tg = {type="hit", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime"}}
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end
			self:project(tg, x, y, DamageType.BLIGHT, self:spellCrit(t.getDamage(self, t) * p.charges), {type="slime"})
			game:playSoundNear(self, "talents/slime")
		elseif kind == "shield" then
			self:setEffect(self.EFF_DAMAGE_SHIELD, 4, {color={0.9, 0.5, 0.1}, power=self:spellCrit(t.getShield(self, t) * p.charges), reflect=50, })
		elseif kind == "vim" then
			self:incVim(t.getVim(self, t) * p.charges)
		end

		return true
	end,
	info = function(self, t)
		return ([[Each time you walk or move you gain a blight charge. You can store up to %d charges.
		When you de-activate the talent you can use the charges to either:
		- restore %0.2f vim per charge
		- deal %0.2f blight damage per charge to a target in range %d.
		- create a shield absorbing %d per chage damage and refelcting half of it back to attackers.
		The damage scales with your Spellpower.]]):
		tformat(t.getMaxCharges(self, t), t.getVim(self, t), damDesc(self, DamageType.BLIGHT, t.getDamage(self, t)), self:getTalentRange(t), t:_getShield(self))
	end,
}

newTalent{
	name = "Corrupt Light", short_name = "DEMON_SEED_CORRUPT_LIGHT",
	type = {"corruption/demon-seeds",1},
	points = 5,
	vim = 5,
	cooldown = 15,
	range = 7,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.7, 5.3)) end,
	direct_hit = true,
	tactical = { DISABLE = 2, BUFF = 2, },
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	getDuration = function(self, t) return self:combatTalentScale(t, 4, 10, 0.5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			if game.level.map.lites(px, py) then
				game.level.map.remembers(px, py, false)
				game.level.map.lites(px, py, false)
			end
		end, nil, {type="dark"})

		local nb = 0
		self:project(tg, x, y, function(px, py) if not game.level.map.lites(px, py) then nb = nb + 1 end end)
		if nb > 0 then
			local power = math.sqrt(nb) * 6
			self:setEffect(self.EFF_DEMON_SEED_CORRUPT_LIGHT, 5, {power=power})
		end
		self:move(self.x, self.y, true)
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[Weave darkness in a radius of %d. All unlit grids contribute to your power by increasing all your damage done for %d turns.
		Damage increase depends on the number of grids extinguished.]]):
		tformat(self:getTalentRadius(t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Shadowmeld", short_name = "DEMON_SEED_SHADOWMELD",
	type = {"corruption/demon-seeds",1},
	points = 5,
	mode = "sustained",
	sustain_vim = 15,
	cooldown = 10,
	tactical = { BUFF = 10, },
	no_energy = true,
	on_pre_use = function(self, t) return self.x and game.level and not game.level.map.lites(self.x, self.y) end,
	getStealth = function(self, t) return 25 + self:combatTalentSpellDamage(t, 3, 150) end,
	getChance = function(self, t) return self:combatTalentLimit(t, 50, 10, 30) end,
	callbackOnMove = function(self, t, moved, force, ox, oy)
		if not moved or force then return end
		self:forceUseTalent(t.id, {ignore_energy=true})
	end,
	callbackOnEffectSave = function(self, t, hd)
		if hd.saved then return end
		if hd.e.type ~= "magical" and hd.e.type ~= "physical" then return end
		if rng.percent(t:_getChance(self)) then hd.saved = true end
	end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "stealth", t.getStealth(self, t))
		self:talentTemporaryValue(ret, "lite", -1000)
		if self.updateMainShader then self:updateMainShader() end
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Whenever you are on an unlit grid you can meld with the shadows, gaining %d stealth power.
		While stealthed you wrap shadows around you in a defensive cloak, giving you a %d%% chance to ignore physical or magical detrimental effects.
		Your equiped lite does not count and will be turned off when activating.
		Moving will cancel the effect.
		Stealth power depends on Spellpower.]]):
		tformat(t.getStealth(self, t), t:_getChance(self))
	end,
}

newTalent{
	name = "Blood Shield", short_name = "DEMON_SEED_BLOOD_SHIELD",
	type = {"corruption/demon-seeds",1},
	points = 5,
	mode = "sustained",
	drain_vim = 2,
	cooldown = 10,
	tactical = { BUFF = 10, },
	no_energy = true,
	getPercent = function(self, t) return self:combatTalentScale(t, 100, 220) end,
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	deactivate_on = {no_combat=true, run=true, rest=true},
	callbackOnMeleeHit = function(self, t, src, dam)
		if not src.x then return end
		local block = self:combatShieldBlock()
		if not block then return end

		DamageType:get(DamageType.SHADOWFLAME).projector(src, src.x, src.y, DamageType.SHADOWFLAME, block * 0.35 * t.getPercent(self, t) / 100)
	end,
	activate = function(self, t)
		local block = self:combatShieldBlock()
		if not block then return end

		local ret = {}
		self:talentTemporaryValue(ret, "flat_damage_armor", {all=block * 0.15})
		local h2x, h2y = self:attachementSpot("hand2", true) if h2x then ret.particle = self:addParticles(Particles.new("blood_shield", 1, {x=h2x, y=h2y-0.1})) end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[By channeling doom forces in your shield you constantly apply 15%% of its block value as a flat damage reduction against all damage.
		Whenever you are hit in melee your shield retaliates automatically for %d%% of its block value as fire and darkness damage.]]):
		tformat(0.35 * t.getPercent(self, t))
	end,
}

newTalent{
	name = "Silence", short_name = "DEMON_SEED_SILENCE",
	type = {"corruption/demon-seeds",1},
	points = 5,
	cooldown = 20,
	vim = 10,
	range = 7,
	direct_hit = true,
	requires_target = true,
	tactical = { DISABLE = { silence = 3 } },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SILENCE, {power_check = self:combatSpellpower(), dur=t.getDuration(self, t)}, {type="mind"})
		return true
	end,
	info = function(self, t)
		return ([[Corrupt the target, silencing it for %d turns.]]):
		tformat(t.getDuration(self, t))
	end,
}

newTalent{
	name = "Fiery Portal", short_name = "DEMON_SEED_FIERY_PORTAL",
	type = {"corruption/demon-seeds",1},
	points = 5,
	cooldown = function(self, t) return math.floor(self:combatTalentLimit(t, 15, 30, 20)) end,
	vim = 20,
	range = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { ESCAPE = 1, CLOSEIN = 1 },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local tg = {type="hit", nolock=true, range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		if not self:canMove(x, y) then return nil end

		local oe = game.level.map(x, y, Map.TERRAIN)
		if not oe or oe.special then return end
		if not oe or oe:attr("temporary") or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return end

		local oo = game.level.map(self.x, self.y, Map.TERRAIN)
		if not oo or oo.special then return end
		if not oo or oo:attr("temporary") or game.level.map:checkEntity(self.x, self.y, Map.TERRAIN, "block_move") then return end

		local function make_portal(oe, x, y, tx, ty)
			local o = Object.new{
				type = "portal", subtype = "demonic",
				name = _t"fiery portal",
				on_added = function(self, level, x, y)
					local ps = self.add_displays[#self.add_displays-1]:addParticles(require("engine.Particles").new("farportal_vortex", 1, {rot=3, size=42, vortex="shockbolt/terrain/planar_demon_vortex"})) ps.dy = -0.05
					-- Why the hell do I need to divide by 2 ??????
					local ps = self.add_displays[#self.add_displays-1]:addParticles(require("engine.Particles").new("fiery_portal_link", 1, {tx=(self.tx-self.x)/2, ty=(self.ty-self.y)/2})) ps.dy = -0.05
				end,
				display = '>', color_r=255, color_g=255, color_b=0,
				notice = true,
				always_remember = true,
				temporary = 4 + self:getTalentLevel(t),
				x = x, y = y, old_feat = oe,
				tx = tx, ty = ty,
				act = function(self)
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
						game.level:removeEntity(self)
						game.level.map:updateMap(self.x, self.y)
						game.nicer_tiles:updateAround(game.level, self.x, self.y)
					end
				end,
				summoner_gain_exp = true,
				summoner = self,
				on_move = function(self, x, y, who)
					if who ~= self.summoner then return end
					if who.__fiery_portaling then return end
					who.__fiery_portaling = true
					local tgt = game.level.map(self.tx, self.ty, engine.Map.ACTOR)
					if tgt then tgt:forceMoveAnim(x, y) end
					who:forceMoveAnim(self.tx, self.ty)
					who.__fiery_portaling = nil
				end,
			}
			o.image = oe.image
			if oe.add_mos then o.add_mos = table.clone(oe.add_mos, true) end
			if oe.add_displays then o.add_displays = table.clone(oe.add_displays) else o.add_displays = {} end
			o.add_displays[#o.add_displays+1] = Object.new{z=4, image="terrain/planar_demon_portal_ground_down.png", display_x=0, display_y=0, display_w=1, display_h=1}
			o.add_displays[#o.add_displays+1] = Object.new{z=16, image="terrain/planar_demon_portal_ground_up.png", display_x=-0, display_y=0, display_w=1, display_h=1}

			if core.shader.active(4) then
				game.level.map:particleEmitter(x, y, 1, "shader_ring_rotating", {rotation=0, radius=1, life=30, img="flamesgeneric"}, {type="firesurge"})
			else
				game.level.map:particleEmitter(x, y, 1, "demon_teleport")
			end

			return o
		end

		local pe = make_portal(oe, x, y, self.x, self.y)
		game.level:addEntity(pe)
		game.level.map(x, y, Map.TERRAIN, pe)
		pe:on_added(game.level, x, y)

		local po = make_portal(oo, self.x, self.y, x, y)
		game.level:addEntity(po)
		game.level.map(self.x, self.y, Map.TERRAIN, po)
		po:on_added(game.level, self.x, self.y)
		po:on_move(self.x, self.y, self)

		return true
	end,
	info = function(self, t)
		return ([[Create two interlinked portals for %d turns.
		Only you can use the portal willingly.
		If a creature stands on the other end of the portal when you enter, you will switch places with it.]]):
		tformat(t.getDuration(self, t))
	end,
}

newTalent{
	name = "Doom Tendrils", short_name = "DEMON_SEED_DOOM_TENDRILS",
	type = {"corruption/demon-seeds",1},
	points = 5,
	mode = "sustained",
	sustain_vim = 20,
	cooldown = 10,
	tactical = { BUFF = 10, },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 210) / 2 end,
	callbackOnActBase = function(self, t)
		if not game.zone or game.zone.wilderness then return end
		self:project({type="ball", radius=2, selffire=false}, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or self:reactionToward(target) >= 0 then return end
			
			local dam = DamageType:get(DamageType.FIRE).projector(self, px, py, DamageType.FIRE, self:spellCrit(t.getDamage(self, t)))
			if dam and dam > 0 and target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, 2, {apply_power=self:combatSpellpower()})
			end
		end)
	end,
	activate = function(self, t)
		local ret = {}
		ret.particle = self:addParticles(Particles.new("doom_tendrils", 1))
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[You turn into a pillar of doom, sprouting flame tendrils in radius 2 around you.
		All foes hit by the tendrils take %0.2f fire damage per turn.
		If the creature suffers damage from the fire it is pinned to the ground.]]):
		tformat(damDesc(self, DamageType.FIRE, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Doomed Nature", short_name = "DEMON_SEED_DOOMED_NATURE",
	type = {"corruption/demon-seeds",1},
	points = 5,
	vim = 10,
	cooldown = 15,
	tactical = { DISABLE = 2, },
	range = 7,
	direct_hit = true,
	requires_target = true,
	tactical = { DISABLE = 2 },
	getChance = function(self, t) return math.floor(self:combatTalentScale(t, 20, 50)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_DEMON_SEED_DOOMED_NATURE, 5, {apply_power=self:combatSpellpower(), chance=t.getChance(self, t), dam=t:_getDamage(self), src=self})
			game.level.map:particleEmitter(px, py, 1, "circle", {shader=true, oversize=1, a=150, appear=8, limit_life=14, speed=0, base_rot=180, img="doomed_nature", radius=0})
		end)
		return true
	end,
	info = function(self, t)
		return ([[You curse a target for 5 turns to sever its connection to Nature.
		Each time it tries to use a natural or psionic power it has %d%% chances to fail and instead trigger a fireball of radius 1 doing %0.2f fire damage.
		The damage increases with you Spellpower stat.]]):
		tformat(t.getChance(self, t), damDesc(self, DamageType.FIRE, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Acid Burst", short_name = "DEMON_SEED_ACID_BURST",
	type = {"corruption/demon-seeds",1},
	points = 5,
	mode = "passive",
	target = function(self, t)
		return {type="ball", range=0, radius=3}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	callbackOnBlock = function(self, t)
		if self.turn_procs.demon_acid_burst then return end
		self.turn_procs.demon_acid_burst = true
		local tg = self:getTalentTarget(t)
		local _ _, _, _, x, y = self:canProject(tg, self.x, self.y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.ACID, t.getDamage(self, t),
			3,
			5, nil,
			{type="vapour"},
			function(e)
				-- We dont like cheese!
				if not e.src:knowTalent(e.src.T_DEMON_SEED_ACID_BURST) then e.duration = 0 end
			end, false
		)
		game:playSoundNear(self, "talents/cloud")
	end,
	info = function(self, t)
		return ([[Whenever you block an attack with your shield, you release a cloud of acidic vapour, dealing %d damage in an area of radius 3 over %d turns.
		The damage will increase with your spellpower.]]):
		tformat(damDesc(self, DamageType.ACID, t.getDamage(self,t)), t.getDuration(self,t))
	end,
}

newTalent{
	name = "Corrosive Cone", short_name = "DEMON_SEED_ACID_CONE",
	type = {"corruption/demon-seeds",1},
	points = 5,
	radius = 5,
	mode = "passive",
	target = function(self, t) return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, cone_angle = 45, force_target=target} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 160) end,
	callbackOnMeleeAttack = function(self, t, target, hitted, critted)
		if not hitted or not critted then return end
		if not target.x or not target.y then return end

		local tg = self:getTalentTarget(t)

		self:project(tg, target.x, target.y, DamageType.DIG, 100)
		self:project(tg, target.x, target.y, DamageType.ACID, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_acid", {radius=tg.radius, tx=target.x-self.x, ty=target.y-self.y, cone_angle = 45})

		game:playSoundNear(self, "talents/breath")
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[When you deal a critical strike in melee, you send out a cone of acid, dealing %d damage to all enemies and melting walls you hit.
		The damage will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.ACID, damage))
	end,
}

newTalent{
	name = "Armoured Leviathan", short_name = "DEMON_SEED_ARMOURED_LEVIATHAN",
	type = {"corruption/demon-seeds",1},
	points = 5,
	vim = 10,
	cooldown = 21,
	range = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { BUFF = 2 },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	action = function(self, t)
		local block = self:combatShieldBlock()
		if not block then return end

		self:setEffect(self.EFF_DEMON_SEED_ARMOURED_LEVIATHAN, t.getDuration(self, t), {power=block*0.1})
		return true
	end,
	info = function(self, t)
		return ([[You enchant your shield to grant you power for %d turns.
		While the effect last your Strength and Magic stats are increased by 10%% of your shield block value.]]):
		tformat(t.getDuration(self, t))
	end,
}

newTalent{
	name = "Flash Block", short_name = "DEMON_SEED_FLASH_BLOCK",
	type = {"corruption/demon-seeds",1},
	points = 5,
	vim = 5,
	cooldown = function(self, t) return math.floor(self:combatTalentLimit(t, 5, 12, 7)) end,
	range = 1,
	requires_target = true,
	no_energy = true,
	tactical = { ATTACK = 3, DEFEND = 3 },
	on_pre_use = function(self, t, silent)
		if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end
		if self:isTalentCoolingDown(self.T_BLOCK) then return false end
		return true
	end,
	action = function(self, t)
		self:forceUseTalent(self.T_BLOCK, {ignore_energy=true})
		local h2x, h2y = self:attachementSpot("hand2", true)
		if not h2x then h2x, h2y = 0, 0 end
		self:addParticles(Particles.new("circle", 1, {zdepth=6, shader=true, oversize=1.6, speed=0, base_rot=180, a=190, appear=8, limit_life=8, img="flash_block", radius=0, x=-h2x, y=h2y}))
		return true
	end,
	info = function(self, t)
		return ([[In a fiery display of speed you raise your shield to block instantly.]]):
		tformat()
	end,
}

newTalent{
	name = "Blackice", short_name = "DEMON_SEED_BLACKICE",
	type = {"corruption/demon-seeds",1},
	points = 5,
	vim = 6,
	range = 5,
	requires_target = true,
	no_energy = true,
	tactical = { ATTACK = 3, DEFEND = 3 },
	getStack = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	getRes = function(self, t) return 10 + self:combatTalentSpellDamage(t, 2, 500) / 10 end,
	callbackOnKill = function(self, t, target, death_note)
		if not target.x or not self.x or not death_note or not death_note.damtype or death_note.damtype == DamageType.FIRE then return end
		self:setEffect(self.EFF_BLACKICE, 20, {max_stacks=t.getStack(self, t)})
	end,
	on_pre_use = function(self, t, silent)
		if not self:hasEffect(self.EFF_BLACKICE) then return false end
		return true
	end,
	action = function(self, t)
		local eff = self:hasEffect(self.EFF_BLACKICE)
		if not eff then return end

		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)

		if not target then return end

		eff.stacks = eff.stacks - 1
		if eff.stacks <= 0 then self:removeEffect(self.EFF_BLACKICE) end

		target:setEffect(target.EFF_BLACKICE_DET, 7, {apply_power=self:combatSpellpower(), power=t.getRes(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Each time your kill a creature with non-fire damage you gain a blackice charge for 20 turns (stacking to %d).
		At any moment you can use a charge to infect a creature with blackice, reducing its fire and physical resistance by %d%% for 7 turns.]]):
		tformat(t.getStack(self, t), t.getRes(self, t))
	end,
}

newTalent{
	name = "Doomfire", short_name = "DEMON_SEED_DOOMFIRE", image = "talents/inferno.png",
	type = {"corruption/demon-seeds",1},
	points = 5,
	vim = 15,
	cooldown = 20,
	tactical = { ATTACKAREA = { FIRE = 3 } },
	range = 10,
	radius = 5,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.DEMONFIRE, t.getDamage(self, t),
			self:getTalentRadius(t),
			5, nil,
			{type="inferno"},
			function(e)
				-- We dont like cheese!
				if not e.src:knowTalent(e.src.T_DEMON_SEED_DOOMFIRE) then e.duration = 0 end
			end, self:spellFriendlyFire()
		)

		game:playSoundNear(self, "talents/devouringflame")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Raging flames burn foes and allies alike, doing %0.2f fire damage in a radius of %d each turn for %d turns.
		Demons standing in the doomfire will instead be healed.
		The damage will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.FIRE, damage), radius, duration)
	end,
}

newTalent{
	name = "Pain Affinity", short_name = "DEMON_SEED_PAIN_AFFINITY",
	type = {"corruption/demon-seeds",1},
	points = 5,
	mode = "passive",
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 3, 15, 5)) end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		if type ~= DamageType.BLIGHT or dam <= 0 then return end
		if self:isTalentCoolingDown(t.id) then return end
		self:setEffect(self.EFF_DEMON_SEED_PAIN_AFFINITY, 2, {power=15})
		self:startTalentCooldown(t)
	end,
	info = function(self, t)
		return ([[Whenever you take blight damage you bask in the sweet pain for 2 turns, increasing all damage affinity by 15%%.
		This can only happen every %d turns.]]):
		tformat(self:getTalentCooldown(t))
	end,
}

newTalent{
	name = "Hexed Shield", short_name = "DEMON_SEED_HEXED_SHIELD",
	type = {"corruption/demon-seeds",1},
	points = 5,
	mode = "passive",
	callbackOnBlock = function(self, t, eff, dam, type, src)
		if not src.setEffect then return end
		if self.turn_procs.demon_seed_hexed_shield then return end
		self.turn_procs.demon_seed_hexed_shield = true
		-- Domination is less likely
		local tid = rng.table{self.T_PACIFICATION_HEX, self.T_EMPATHIC_HEX, self.T_BURNING_HEX, self.T_PACIFICATION_HEX, self.T_EMPATHIC_HEX, self.T_BURNING_HEX, self.T_DOMINATION_HEX}
		self:forceUseTalent(tid, {ignore_energy=true, ignore_ressources=true, force_level=self:getTalentLevelRaw(t), force_target=src, ignore_cd=true})
	end,
	info = function(self, t)
		return ([[Whenever you block an attack with your shield, you randomly hex the attacker with one of the hexes: Pacification, Domination, Burning or Empathic as if cast at talent level %d.
		This may only happen once per turn.]]):
		tformat(self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Cursed Arm", short_name = "DEMON_SEED_CURSED_ARM",
	type = {"corruption/demon-seeds",1},
	points = 5,
	mode = "passive",
	getChance = function(self, t) return self:combatTalentLimit(t, 50, 10, 30) end,
	callbackOnMeleeAttack = function(self, t, target, hitted)
		if not rng.percent(t:_getChance(self)) then return end
		if self.turn_procs.demon_seed_cursed_arm then return end
		self.turn_procs.demon_seed_cursed_arm = true
		local tid = rng.table{self.T_CURSE_OF_DEFENSELESSNESS, self.T_CURSE_OF_IMPOTENCE, self.T_CURSE_OF_DEATH, self.T_CURSE_OF_VULNERABILITY}
		self:forceUseTalent(tid, {ignore_energy=true, ignore_ressources=true, force_level=self:getTalentLevelRaw(t), force_target=target, ignore_cd=true})
	end,
	info = function(self, t)
		return ([[Whenever make a melee attack, you have a %d%% chance to randomly curse the target with one of the curses: Defenselessness, Impotence, Death or Vulnerability as if cast at talent level %d.
		This may only happen once per turn.]]):
		tformat(t:_getChance(self), self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Doom Storm", short_name = "DEMON_SEED_DOOM_STORM", image = "talents/fire_storm.png",
	type = {"corruption/demon-seeds",1},
	points = 5,
	vim = 15,
	cooldown = 20,
	range = 0,
	radius = 3,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, friendlyfire=false} end,
	tactical = { ATTACKAREA = { FIRE = 2 } },
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.05) + self:getTalentLevel(t), 5, 0, 12.67, 7.66)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 120) end,
	action = function(self, t)
		-- Add a lasting map effect
		local ef = game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.FIRE_FRIENDS, t.getDamage(self, t),
			3,
			5, nil,
			{type="firestorm", only_one=true},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				-- We dont like cheese!
				if not e.src:knowTalent(e.src.T_DEMON_SEED_DOOM_STORM) then e.duration = 0 end
				return true
			end,
			0, 0
		)
		ef.name = _t"firestorm"
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[A furious fire storm rages around the caster, doing %0.2f fire damage in a radius of 3 each turn for %d turns.
		You closely control the firestorm, preventing it from harming your party members.
		The damage and duration will increase with your Spellpower.]]):
		tformat(damDesc(self, DamageType.FIRE, damage), duration)
	end,
}

newTalent{
	name = "Frostfire Nova", short_name = "DEMON_SEED_FROSTFIRE_NOVA",
	type = {"corruption/demon-seeds",1},
	points = 5,
	vim = 12,
	cooldown = 15,
	tactical = { ATTACKAREA = { FIRE = 2 }, DISABLE = { stun = 1 } },
	range = 0,
	radius = 6,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 220) end,
	getVim = function(self, t) return 9 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local dam = self:spellCrit(t.getDamage(self, t))
		self:projectApply(tg, self.x, self.y, Map.ACTOR, function(target)
			local rdam = DamageType:get(DamageType.FIRE).projector(self, target.x, target.y, DamageType.FIRE, dam)
			if rdam > 0 and target:canBe("stun") then
				target:setEffect(target.EFF_FROZEN, 4, {hp=dam * 0.5, apply_power=self:combatSpellpower(), min_dur=1})
				if target:hasEffect(target.EFF_FROZEN) then
					self:incVim(t:_getVim(self))
				end
			end
		end, "hostile")
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_frostfire", {radius=tg.radius})

		game:playSoundNear(self, "talents/flame")
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Fire a blast of frostfire in radius %d, doing %0.2f fire damage and freezing creatures in ice blocks for 4 turns.
		For each frozen creature you regenerate %d vim.
		The damage will increase with your Spellpower.]]):tformat(radius,
		damDesc(self, DamageType.FIRE, damage),
		t:_getVim(self))
	end,
}

newTalent{
	name = "Fetid Breath", short_name = "DEMON_SEED_FETID_BREATH",
	type = {"corruption/demon-seeds",1},
	points = 5,
	vim = 18,
	cooldown = 10,
	message = _t"@Source@ breathes fetid matter!",
	tactical = { ATTACKAREA = { DARKNESS = 1, BLIGHT = 1 }},
	range = 0,
	radius = function(self, t) return math.min(13, math.floor(self:combatTalentScale(t, 5, 9))) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 390) end,
	callbackOnMeleeAttack = function(self, t, target, hitted)
		if not hitted or not target.x then return end
		if not rng.percent(10) then return end
		local tg = self:getTalentTarget(t)
		self:project(tg, target.x, target.y, DamageType.FETID, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_dark", {radius=tg.radius, tx=target.x-self.x, ty=target.y-self.y})
		game:playSoundNear(self, "talents/breath")
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FETID, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_dark", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[You breathe a mix of darkness and flight in a frontal cone of radius %d. Any target caught in the area will take %0.2f darkness/blight damage.
		In addition each time you do a melee attack there is a 10%% chance to trigger the breath at no cost.
		The damage will increase with your Spellpower.
		]]):tformat(self:getTalentRadius(t), damDesc(self, DamageType.FETID, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Blood Drinker", short_name = "DEMON_SEED_BLOOD_DRINKER",
	type = {"corruption/demon-seeds",1},
	points = 5,
	cooldown = 10,
	vim = 10,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	getDam = function(self, t) return self:combatTalentWeaponDamage(t, 0.9, 2) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 8)) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	range = 1,
	deathTrigger = function(self, t, target)
		self:setEffect(self.EFF_DEMON_SEED_BLOOD_DRINKER_BUFF, t:_getDuration(self), {vim=7, evade=40})
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		local hit = self:attackTarget(target, DamageType.BLIGHT, t:_getDam(self), true)
		if hit then
			if target:attr("dead") then
				t:_deathTrigger(self, target)
			else
				target:setEffect(target.EFF_DEMON_SEED_BLOOD_DRINKER_DEBUFF, 2, {apply_power=self:combatPhysicalpower(), src=self})
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Deal a blight-enhanced melee blow, dealing %d%% blight damage.
		If the attack hits and the creature dies in the next 2 turns you drink its essence which makes you regenerate 7 vim per turn and gain 40%% chance to evade attacks for the next %d turns.
		]])
		:tformat(100 * t:_getDam(self), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Meteor Slam", short_name = "DEMON_SEED_METEOR_SLAM",
	type = {"corruption/demon-seeds",1},
	points = 5,
	cooldown = 20,
	vim = 25,
	tactical = { ATTACKAREA = { FIRE=2, PHYSICAL=2 } },
	getDam = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 2.2) end,
	radius = 2,
	range = 7,
	target = function(self, t) return {type="ball", nolock=true, range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t} end,
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	action = function(self, t)
		local shield, shield_combat = self:hasShield()
		if not shield then
			game.logPlayer(self, "You cannot use Meteor Slam without a shield!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTargetLimited(tg)
		if not x or not y then return nil end
		x, y = util.findFreeGrid(x, y, self:getTalentRadius(t), true, {[Map.ACTOR]=true})
		if not x then return end

		local terrains = t.terrains or mod.class.Grid:loadList("/data/general/grids/lava.lua")
		t.terrains = terrains -- cache

		local meteor = function(x, y)
			game.level.map:particleEmitter(x, y, 10, "meteor", {tx=x-self.x, ty=y-self.y})
			game.level.map:particleEmitter(x, y, 10, "fireflash", {radius=self:getTalentRadius(t)})
			game:playSoundNear(game.player, "talents/fireflash")

			local grids = {}
			for i = x-1, x+1 do for j = y-1, y+1 do
				local oe = game.level.map(i, j, Map.TERRAIN)
				if oe and not oe:attr("temporary") and
				(core.fov.distance(x, y, i, j) < 1 or rng.percent(40)) and (game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "dig") or game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "grow")) then
					local g = terrains.LAVA_FLOOR:clone()
					g:resolve() g:resolve(nil, true)
					game.zone:addEntity(game.level, g, "terrain", i, j)
					grids[#grids+1] = {x=i,y=j,oe=oe}
				end
			end end
			for i = x-1, x+1 do for j = y-1, y+1 do
				game.nicer_tiles:updateAround(game.level, i, j)
			end end
			for _, spot in ipairs(grids) do
				local i, j = spot.x, spot.y
				local g = game.level.map(i, j, Map.TERRAIN)
				g.temporary = 8
				g.x = i g.y = j
				g.canAct = false
				g.energy = { value = 0, mod = 1 }
				g.old_feat = spot.oe
				g.useEnergy = mod.class.Trap.useEnergy
				g.act = function(self)
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
						game.level:removeEntity(self)
						game.nicer_tiles:updateAround(game.level, self.x, self.y)
					end
				end
				game.level:addEntity(g)
			end

			self:projectApply({type="ball", radius=self:getTalentRadius(t), selffire=false}, x, y, Map.ACTOR, function(target)
				self:attackTargetWith(target, shield_combat, DamageType.METEOR, t:_getDam(self))
			end)
			if core.shader.allow("distort") then game.level.map:particleEmitter(x, y, 2, "shockwave", {radius=2}) end
			game:getPlayer(true):attr("meteoric_crash", 1)
			self:move(x, y, true)
		end

		meteor(x, y)
		game.log("") -- forces update of combat log
		return true
	end,
	info = function(self, t)
		return ([[Using demonic forces you jump high in the sky and fall down on your target as a meteor, slamming the ground with your shield.
		The impact is so powerful it shakes the ground in radius %d, dealing a %d%% fire and physical shield attack to all foes and turning the ground into lava.]]):
		tformat(self:getTalentRadius(t), 100 * t:_getDam(self))
	end,
}

newTalent{
	name = "Blazing Phase", short_name = "DEMON_SEED_BLAZING_PHASE",
	type = {"corruption/demon-seeds",1},
	points = 5,
	cooldown = 10,
	vim = 5,
	tactical = { ATTACKAREA = { FIRE=2 }, VIM = 1 },
	getVim = function(self, t) return 12 end,
	getDam = function(self, t) return self:combatTalentSpellDamage(t, 15, 200) end,
	range = 10,
	target = function(self, t) return {type="beam", range=self:getTalentRange(t), selffire=false, talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTargetLimited(tg)
		if not x or not y then return nil end
		x, y = util.findFreeGrid(x, y, self:getTalentRadius(t), true, {[Map.ACTOR]=true})
		if not x then return end

		self:projectApply(tg, x, y, Map.ACTOR, function() self:incVim(12) end)
		self:project(tg, x, y, DamageType.FIRE, self:spellCrit(t:_getDam(self)))

		if core.renderer then game.level.map:particleComposeEmitter(self.x, self.y, tg.range, "flame_beam", {tx=(x-self.x)*Map.tile_w, ty=(y-self.y)*Map.tile_h})
		else game.level.map:particleEmitter(self.x, self.y, tg.range, "flamebeam", {tx=x-self.x, ty=y-self.y}) end
		self:forceMoveAnim(x, y)

		return true
	end,
	info = function(self, t)
		return ([[By seathing yourself in flames you phase to a distant location.
		Any creature caught in the way is burnt for %0.2f fire damage which you use to regain %d vim.
		The damage will increase with your Spellpower.
		]]):tformat(damDesc(self, DamageType.FIRE, t.getDam(self, t)), t:_getVim(self))
	end,
}

newTalent{
	name = "Frost Grab", short_name = "DEMON_SEED_FROST_GRAB", image = "talents/frost_grab.png",
	type = {"corruption/demon-seeds",1},
	points = 5,
	vim = 8,
	cooldown = 8,
	range = 10,
	tactical = { ATTACK = {COLD = 1}, DISABLE = {slow = 1}, CLOSEIN = 2 },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(self:combatTalentSpellDamage(t, 5, 140))

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			target:pull(self.x, self.y, tg.range)

			DamageType:get(DamageType.COLD).projector(self, target.x, target.y, DamageType.COLD, dam)
			target:setEffect(target.EFF_SLOW_MOVE, t.getDuration(self, t), {apply_power=self:combatSpellpower(), power=0.5})
		end)
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = function(self, t)
		return ([[Grab a target and pull it next to you, covering it with frost while reducing its movement speed by 50%% for %d turns.
		The ice will also deal %0.2f cold damage.
		The damage and chance to slow will increase with your Spellpower.]]):
		tformat(t.getDuration(self, t), damDesc(self, DamageType.COLD, self:combatTalentSpellDamage(t, 5, 140)))
	end,
}

newTalent{
	name = "Diseased Body", short_name = "DEMON_SEED_DISEASED_BODY",
	type = {"corruption/demon-seeds",1},
	points = 5,
	mode = "passive",
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 20, 70) end,
	getDur = function(self, t) return self:combatTalentScale(t, 5, 10) end,
	getDamage = function(self, t) return 5 + self:combatTalentSpellDamage(t, 5, 30) end,
	getDiseasePower = function(self, t) return self:combatTalentSpellDamage(t, 5, 28) end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		if not rng.percent(t:_getChance(self)) then return end
		if self.turn_procs.demon_seed_diseased_body then return end

		if src.canBe and src:canBe("disease") then
			self.turn_procs.demon_seed_diseased_body = true
			local diseases = {{self.EFF_WEAKNESS_DISEASE, "str"}, {self.EFF_ROTTING_DISEASE, "con"}, {self.EFF_DECREPITUDE_DISEASE, "dex"}}
			local disease = rng.table(diseases)
			src:setEffect(disease[1], t:_getDur(self), {src=self, dam=t:_getDamage(self), [disease[2]]=t.getDiseasePower(self, t), apply_power=self:combatSpellpower()})
		end
	end,
	info = function(self, t)
		return ([[Whenever you take direct damage, there is a %d%% chance that your your diseased body erupts in blight, diseasing your attacker with a random disease for %d turns.
		Each turn the disease deals %0.2f blight damage and reduce one random attribute (strength, dexterity, constitution) by %d.
		This may only happen once per turn.
		The damage increases with your spellpower.]]):
		tformat(t:_getChance(self), t:_getDur(self), t:_getDamage(self), t:_getDiseasePower(self))
	end,
}

newTalent{
	name = "Volcanic Skin", short_name = "DEMON_SEED_VOLCANIC_SKIN",
	type = {"corruption/demon-seeds",1},
	points = 5,
	cooldown = 6,
	tactical = { ATTACK = {FIRE = 1, PHYSICAL = 1} },
	requires_target = true,
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 20, 70) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	makeVolcano = function(self, t, x, y, dur)
		local oe = game.level.map(x, y, Map.TERRAIN)
		if not oe or oe:attr("temporary") then return false end

		local e = Object.new{
			old_feat = oe,
			type = oe.type, subtype = oe.subtype,
			name = _t"raging volcano", image = oe.image, add_mos = {{image = "terrain/lava/volcano_01.png"}},
			display = '&', color=colors.LIGHT_RED, back_color=colors.RED,
			always_remember = true,
			temporary = dur,
			x = x, y = y,
			canAct = false,
			nb_projs = 2,
			dam = t.getDamage(self, t),
			act = function(self)
				local tgts = {}
				local grids = core.fov.circle_grids(self.x, self.y, 5, true)
				for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
					local a = game.level.map(x, y, engine.Map.ACTOR)
					if a and self.summoner:reactionToward(a) < 0 then tgts[#tgts+1] = a end
				end end

				-- Randomly take targets
				local tg = {type="bolt", friendlyfire=false, selffire=false, range=5, x=self.x, y=self.y, talent=self.summoner:getTalentFromId(self.summoner.T_VOLCANO), display={image="object/lava_boulder.png"}}
				for i = 1, self.nb_projs do
					if #tgts <= 0 then break end
					local a, id = rng.table(tgts)
					table.remove(tgts, id)

					self.summoner:projectile(tg, a.x, a.y, engine.DamageType.MOLTENROCK, self.dam, {type="flame"})
					game:playSoundNear(self, "talents/fire")
				end

				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					game.level.map:updateMap(self.x, self.y)
					game.nicer_tiles:updateAround(game.level, self.x, self.y)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN, e)
		game.nicer_tiles:updateAround(game.level, x, y)
		game.level.map:updateMap(x, y)

		if core.shader.active(4) then
			game.level.map:particleEmitter(x, y, 1, "shader_ring_rotating", {rotation=0, radius=2, life=30, y=0, img="flamesshockwave"}, {type="firearcs"})
		end
		return true
	end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		if not rng.percent(t:_getChance(self)) then return end
		if self.turn_procs.demon_seed_volcanic_skin then return end
		self.turn_procs.demon_seed_volcanic_skin = true
		self:setEffect(self.EFF_DEMON_SEED_VOLCANIC_SKIN, 1, {})
	end,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_DEMON_SEED_VOLCANIC_SKIN) end,
	action = function(self, t)
		local eff = self:hasEffect(self.EFF_DEMON_SEED_VOLCANIC_SKIN)
		if not eff then return end

		if t:_makeVolcano(self, self.x, self.y, eff.stacks * 2) then
			self:removeEffect(self.EFF_DEMON_SEED_VOLCANIC_SKIN)
		else
			return nil
		end
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[For every turn where you take damage you have a %d%% chance to store a seismic charge.
		You can activate this spell to consume the charges, spawning a raging volcano that lasts for 2 turns per charges.
		Each turn the volcano spews 2 flaming boulders that deal %0.2f fire and %0.2f physical damage.
		The charges quickly fade when outside of combat.
		The damage increases with your spellpower.]]):
		tformat(t:_getChance(self), damDesc(self, DamageType.FIRE, dam/2), damDesc(self, DamageType.PHYSICAL, dam/2))
	end,
}
