-- ToME - Tales of Maj'Eyal:
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

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Dialog = require "engine.ui.Dialog"
local Emote = require "engine.Emote"
local Cults = require("mod.class.CultsDLC")

local function floorEffect(t)
	t.name = t.name or t.desc
	t.name = t.name:upper():gsub("[ ']", "_")
	local d = t.long_desc
	if type(t.long_desc) == "string" then t.long_desc = function() return d end end
	t.type = "other"
	t.subtype = { floor=true }
	t.status = "neutral"
	t.parameters = {}
	t.on_gain = function(self, err) return nil, "+"..t.desc end
	t.on_lose = function(self, err) return nil, "-"..t.desc end

	newEffect(t)
end

newEffect{
	name = "SMACK_ENTROPIC_WORMHOLE", image = "shockbolt/terrain/wormhole.png",
	desc = _t"S.M.A.C.K.",
	long_desc = function(self, eff) return _t"Fight your foe! If anything wrong happens, the Fortress will pull you out." end,
	type = "other",
	subtype = { other=true },
	status = "neutral",
	parameters = { },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		game:onTickEnd(function()
			if game._chronoworlds and game._chronoworlds.multiverse_fight then
				require("mod.class.CultsDLC").backFromSMACK("S.M.A.C.K", [[Yiilkgur's safety protocols activate and pull yourself out of the arena.
You have taken too long to win.]])
				return
			end
		end)
	end,
}

newEffect{
	name = "DREM_FRENZY", image = "talents/drem_frenzy.png",
	desc = _t"Frenzy",
	long_desc = function(self, eff) return _t"Class talents have no cooldown the first time they are used." end,
	type = "mental",
	subtype = { frenzy=true },
	status = "neutral",
	parameters = { },
	activate = function(self, eff)		
		eff.used_talents = {}

		local hx, hy = self:attachementSpot("head", true) hx, hy = hx or 0, hy or 0
		self:effectParticles(eff, {type="circle", args={x=hx, y=hy, oversize=0.9, base_rot=0, a=220, shader=true, appear=6, img="drem_frenzy_aura", speed=0, radius=0}})
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "SPIKESKIN_BLACK_BLOOD", image = "talents/spikeskin.png",
	desc = _t"Black Blood Bleeding",
	long_desc = function(self, eff) return ("Black blood sips from every pore, dealing %0.2f darkness damage per turn."):tformat(eff.power) end,
	type = "magical",
	subtype = { bleed=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# starts to bleed black blood.", true end,
	on_lose = function(self, err) return _t"#Target# stops bleeding black blood.", true end,
	parameters = { power=10 },
	on_timeout = function(self, eff)
		DamageType:get(DamageType.DARKNESS).projector(eff.src or self, self.x, self.y, DamageType.DARKNESS, eff.power)
	end,
}

newEffect{
	name = "SPIKESKIN", image = "talents/spikeskin.png",
	desc = _t"Spikeskin",
	long_desc = function(self, eff) return ("Empowered by the sight of black blood, granting %d%% all resistances."):tformat(eff.power) end,
	type = "magical",
	subtype = { blood=true },
	status = "beneficial",
	charges = function(self, eff) return math.floor(eff.power).."%" end,
	parameters = { power=5 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {all=eff.power})
	end,
}

newEffect{
	name = "SLIMY_TENDRIL", image = "talents/tendrils_eruption.png",
	desc = _t"Slimy Tendril",
	long_desc = function(self, eff) return ("Caught in a slimy tendril, reducing all damage by %d%%."):tformat(eff.power) end,
	type = "magical",
	subtype = { slime=true, corrupted=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is caught by a slimy tendril.", true end,
	on_lose = function(self, err) return _t"#Target# is free from the tendril.", true end,
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "numbed", eff.power)
	end
}

newEffect{
	name = "TENTACLE_CONSTRICT", image = "talents/constrict.png",
	desc = _t"Tentacle Constriction",
	long_desc = function(self, eff) return ("Caught by a tentacle from %s that deals %d%% tentacle damage and pulls you 1 space towards them each turn.")
		:tformat(eff.src:getName():capitalize(), eff.dam * 100) end,
	type = "other",
	subtype = { },
	cancel_on_level_change = true,
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is constricted by a tentacle.", true end,
	on_lose = function(self, err) return _t"#Target# is free from the tentacle constriction.", true end,
	parameters = { dam=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "tentacle_hand_prevent", 1)
		if core.shader.active() then
			local hx, hy = self:attachementSpot("head", true) hx, hy = hx or 0, hy or 0
			self:effectParticles(eff, {type="shader_shield", args={x=hx, y=hy, size_factor=1, img="constrict_tentacle_shader"}, shader={type="tentacles", appearTime=0.6, time_factor=500, noup=0.0}})
		end
	end,
	on_timeout = function(self, eff)
		if eff.src:attr("dead") or not eff.src:isTalentActive(eff.src.T_TENTACLE_CONSTRICT) then eff.dur = 0 return end
		eff.src:callTalent(eff.src.T_TENTACLE_CONSTRICT, "do_attack", self)
	end,
}

newEffect{
	name = "CARRION_FEET", image = "talents/carrion_feet.png",
	desc = _t"Carrion Feet",
	long_desc = function(self, eff) return ("Caught disgusting worms, reducing all damage by %d%%."):tformat(eff.power) end,
	type = "magical",
	subtype = { slime=true, corrupted=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is caught in gore.", true end,
	on_lose = function(self, err) return _t"#Target# is free from the gore.", true end,
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "numbed", eff.power)
	end,
}

newEffect{
	name = "CULTS_OVERGROWTH", image = "talents/cults_overgrowth.png",
	desc = _t"Overgrowth",
	long_desc = function(self, eff) return ("Can walk through walls and quake every turn, %d%% more damage and %d%% more resistances."):tformat(eff.dam, eff.resist) end,
	type = "magical",
	subtype = { growth=true, corrupted=true, massive=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# suddently grows.", true end,
	on_lose = function(self, err) return _t"#Target# shrinks back.", true end,
	parameters = { dam=10, resists=10, grids = {} },
	callbackOnMove = function(self, eff, moved, force, ox, oy)
		if not moved or force or (self.x == ox and self.y == oy) then return end
		table.insert(eff.grids, {x=ox, y=oy})

		-- Should we check .special here?
		game.zone:doQuake(4, self.x, self.y, function(tx, ty)
			return (tx ~= self.x or ty ~= self.y) and not game.level.map.attrs(tx, ty, "no_teleport") and not game.level.map:checkAllEntities(tx, ty, "change_level") and game.level.map(tx, ty, Map.TERRAIN) and (game.level.map(tx, ty, Map.TERRAIN).dig or game.level.map(tx, ty, Map.TERRAIN).grow)
		end)

		self:project({type="ball", radius = 1}, self.x, self.y, function(x, y)
			DamageType:get(DamageType.DIG).projector(self, x, y, DamageType.DIG)
		end)

		for k,v in ipairs(eff.grids) do
			DamageType:get(DamageType.DIG).projector(self, v.x, v.y, DamageType.DIG)
		end
	end,
	activate = function(self, eff)
		eff.start = {self.x, self.y}
		self:effectTemporaryValue(eff, "can_pass", {pass_wall=20, pass_tree=1})
		self:effectTemporaryValue(eff, "size_category", 2)
		self:effectTemporaryValue(eff, "inc_damage", {all=eff.dam})
		self:effectTemporaryValue(eff, "resists", {all=eff.resist})
		if core.shader.active() then
			self:effectParticles(eff, {type="shader_shield", args={toback=true, size_factor=1.5, img="overgrowth_tentacle_shader"}, shader={type="tentacles", appearTime=0.6, wobblingType=0, time_factor=500, noup=0.0}})
		end
	end,
}

newEffect{
	name = "DECAYING_GUTS", image = "talents/decaying_guts.png",
	desc = _t"Decaying Guts",
	long_desc = function(self, eff) return ("Reduces global action speed by %d%%."):tformat(eff.power * 100) end,
	type = "magical",
	subtype = { corruption=true, slow=true },
	status = "detrimental",
	parameters = { slow=0.1 },
	on_gain = function(self, err) return _t"#Target# is covered in decaying guts.", true end,
	on_lose = function(self, err) return _t"#Target# is free from the decaying guts.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "global_speed_add", -eff.power)
	end,
}

newEffect{
	name = "WTW_OFS", image = "talents/worm_that_walks.png",
	desc = _t"Worm that Walks out of sight",
	long_desc = function(self, eff) return _t"The Worm that Walks is out of sight of the alchemist; direct control will be lost!" end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return _t"#LIGHT_RED##Target# is out of sight of its master; direct control will break!", _t"+Out of sight" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		if game.player ~= self then return true end

		if eff.dur <= 1 then
			game:onTickEnd(function()
				game.logPlayer(self, "#LIGHT_RED#You lost sight of your worm that wakls for too long; direct control is broken!")
				game.player:runStop(_t"worm that walks out of sight")
				game.player:restStop(_t"worm that walks out of sight")
				game.party:setPlayer(self.summoner)
			end)
		end
	end,
}

newEffect{
	name = "WTW_SHARED_INSANITY", image = "talents/worm_that_walks.png",
	desc = _t"Shared Insanity",
	long_desc = function(self, eff) return ("Linked to their horror ally gaining %d%% all damage resistance."):tformat(eff.resist) end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = { resist=10, save=0 },
	on_gain = function(self, err) return _t"#Target# links closer to his ally!", true end,
	on_lose = function(self, err) return _t"#Target# no longer seems to be in sync with his ally.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {all = eff.resist})
	end,
	on_timeout = function(self, eff)
		if not eff.save or eff.save <= 0 then return end
		self:project({type="ball", radius=3}, self.x, self.y, function(px, py)
			local act = game.level.map(px, py, Map.ACTOR)
			if not act or self:reactionToward(act) >= 0 then return end
			act:setEffect(act.EFF_WTW_TERRIBLE_SIGHT, 2, {save = eff.save})
		end)
	end,
}

-- Probably fine to re-use this icon since one is detrimental, one beneficial
newEffect{
	name = "WTW_TERRIBLE_SIGHT", image = "talents/worm_that_walks.png",
	desc = _t"Terrible Sight",
	long_desc = function(self, eff) return ("Terrified of the horror duo attacking them reducing defense and spell save by %d."):tformat(eff.save) end,
	type = "other",
	subtype = { },
	status = "detrimental",
	parameters = { save=0 },
	on_gain = function(self, err) return _t"#Target# is terrified of the horrors attacking him!", true end,
	on_lose = function(self, err) return _t"#Target# is no longer afraid of the horrors attacking him.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_spellresist", -eff.save)
		self:effectTemporaryValue(eff, "combat_def", -eff.save)
	end,
}

newEffect{
	name = "CHAOS_ORBS", image = "talents/chaos_orbs.png",
	desc = _t"Chaos Orbs",
	long_desc = function(self, eff) return ("%d stacks, +%d%% to all damage dealt."):tformat(eff.stacks, eff.stacks*3) end,
	type = "magical",
	subtype = { chaos=true, damage=true, insanity=true },
	status = "beneficial",
	parameters = { stacks = 1, max_stacks = 1 },
	charges = function(self, eff) return eff.stacks end,
	on_gain = function(self, err) return nil, true end,
	on_lose = function(self, err) return nil, true end,
	updateEffect = function(self, old_eff, new_eff, e)
		-- Put this in __tmpvals so stuff like copyEffect doesn't break
		old_eff.__tmpvals = old_eff.__tmpvals or {}
		new_eff.__tmpvals = new_eff.__tmpvals or {}
		if old_eff.__tmpvals.damid then self:removeTemporaryValue("inc_damage", old_eff.__tmpvals.damid) end
		new_eff.__tmpvals.damid = self:addTemporaryValue("inc_damage", {all=new_eff.stacks * 3})

		if new_eff.ps and new_eff.ps._shader and new_eff.ps._shader.shad then
			if not new_eff.ps.shader then
				-- Actor cloning does not keep .shader fields so we may need to recreate it
				-- I don't know if this is the right fix
				self:removeParticles(new_eff.ps)
				new_eff.ps = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.5, rotation=0, radius=1.5, img="chaos_orbs"}, {type="boneshield", scrollingSpeed=-0.006, ellipsoidalFactor={1, 1.2}}))
			end

			new_eff.ps._shader.shad:resetClean()
			new_eff.ps._shader:setResetUniform("chargesCount", util.bound(new_eff.stacks, 0, 10))
			new_eff.ps.shader.chargesCount = util.bound(new_eff.stacks, 0, 10)
		end
	end,
	useOrb = function(self, eff, amt)
		local amt = amt or eff.stacks
		local def = self.tempeffect_def[eff.effect_id]
		
		eff.stacks = eff.stacks - amt
		if eff.stacks <= 0 then
			self:removeEffect(self.EFF_CHAOS_ORBS)
			return
		end

		def.updateEffect(self, eff, eff, def)
	end,
	on_merge = function(self, old_eff, new_eff, e)
		new_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)
		new_eff.ps = old_eff.ps
		e.updateEffect(self, old_eff, new_eff, e)
		return new_eff
	end,
	activate = function(self, eff, e)
		if core.shader.allow("adv") then
			eff.ps = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.5, rotatwion=0, radius=1.5, img="chaos_orbs"}, {type="boneshield", scrollingSpeed=-0.006, ellipsoidalFactor={1, 1.2}}))
			eff.ps._shader.shad:resetClean()
			eff.ps._shader:setResetUniform("chargesCount", 1)
			eff.ps.shader.chargesCount = 1
		end
		e.updateEffect(self, eff, eff, e)
	end,
	callbackOnChangeLevel = function(self, eff, what, zone, level)
		-- No cheesing orb stacks
		if what == "leave" then self:removeEffect(eff) end
	end,
	deactivate = function(self, eff, e)
		if eff.ps then self:removeParticles(eff.ps) end
		self:removeTemporaryValue("inc_damage", eff.__tmpvals.damid)
	end,
}

-- Fix for copyeffect
newEffect{
	name = "PUTRESCENT_PUSTULE", image = "talents/pustulent_growth.png",
	desc = _t"Putrescent Pustule",
	long_desc = function(self, eff) return ("%d pustules increasing resistance by %d%%."):tformat(eff.stacks, eff.stacks * eff.power) end,
	type = "magical",
	subtype = { horror=true, blight=true },
	status = "beneficial",
	parameters = { stacks = 1, max_stacks = 1 },
	charges = function(self, eff) return eff.stacks end,
	on_gain = function(self, err) return nil, true end,
	on_lose = function(self, err) return nil, true end,
	updateEffect = function(self, old_eff, new_eff, e)
		if old_eff.resists then self:removeTemporaryValue("resists", old_eff.resists) end
		new_eff.resists = self:addTemporaryValue("resists", {all=new_eff.stacks * new_eff.power})
	end,
	on_merge = function(self, old_eff, new_eff, e)
		-- new_eff.__tmpparticles = old_eff.__tmpparticles
		new_eff.stacks = util.bound(old_eff.stacks+1, 1, new_eff.max_stacks)
		e.updateEffect(self, old_eff, new_eff, e)
		return new_eff
	end,
	activate = function(self, eff, e)
		e.updateEffect(self, eff, eff, e)
	end,
	deactivate = function(self, eff, e)
		if eff.ps then self:removeParticles(eff.ps) end
		self:removeTemporaryValue("resists", eff.resists)
	end,
}

newEffect{
	name = "DIGEST", image = "talents/digest.png",
	desc = _t"Digesting",
	long_desc = function(self, eff) return ("Digesting %s."):tformat(eff.victim.name) end,
	type = "magical",
	subtype = { eat=true, digest=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# swallows a foe.", true end,
	on_lose = function(self, err) return _t"#Target# has finished digesting.", true end,
	parameters = { power=10 },
	callbackOnAct = function(self, eff)
		if not rng.percent(10) then return end
		if eff.victim.type ~= "humanoid" and eff.victim.type ~= "giant" and eff.victim.type ~= "demon" then return end
		local phrase = rng.table{
			"arr..kill..me..please...",
			"ARRRG!",
			"...mercy...",
			"I can feel myself rotting away, you can't do that!",
			"no..nooooo...NOOOO",
			"..no more..pain..*arg*"
		}
		self:setEmote(Emote.new(phrase, 90, colors.CRIMSON))
		game.logPlayer(self, "The victim in your stomach seems to still be alive: '#CRIMSON#%s'", phrase)
	end,
	activate = function(self, eff)
		eff.insanityid = self:addTemporaryValue("insanity_regen", eff.insanity)
		eff.was_in_combat = true

		if eff.tid then
			if self.hotkey and self.isHotkeyBound then
				local pos = self:isHotkeyBound("talent", self.T_DIGEST)
				if pos then
					self.hotkey[pos] = {"talent", eff.tid}
				end
			end

			local ohk = self.hotkey
			self.hotkey = nil -- Prevent assigning hotkey, we just did
			self:learnTalent(eff.tid, true, eff.lev, {no_unlearn=true})
			self.hotkey = ohk

			self.talent_no_resources = self.talent_no_resources or {}
			self:effectTemporaryValue(eff, "talent_no_resources", {[eff.tid] = 1})
		end

		local hx, hy = self:attachementSpot("belly", true) hx, hy = hx or 0, hy or 0
		self:effectParticles(eff, {type="digesting_foe", args={x=hx, y=hy}})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("insanity_regen", eff.insanityid)
		if eff.tid then
			if self.hotkey and self.isHotkeyBound then
				local pos = self:isHotkeyBound("talent", eff.tid)
				if pos then
					self.hotkey[pos] = {"talent", self.T_DIGEST}
				end
			end
			self:unlearnTalent(eff.tid, eff.lev, nil, {no_unlearn=true})
		end
		game.logPlayer(self, "The victim in your stomach finally dies from the painful agony.")
	end,
	on_timeout = function(self, eff)
		if not self.in_combat then
			eff.dur = eff.dur + 1
			if eff.was_in_combat and eff.insanityid then
				self:removeTemporaryValue("insanity_regen", eff.insanityid)
				eff.insanityid = nil
			end
		else
			if not eff.was_in_combat and not eff.insanityid then
				eff.insanityid = self:addTemporaryValue("insanity_regen", eff.insanity)
			end
		end
		eff.was_in_combat = self.in_combat
	end,
}

newEffect{
	name = "INNER_TENTACLES", image = "talents/inner_tentacles.png",
	desc = _t"Inner Tentacles",
	long_desc = function(self, eff) return ("Life leech %d%% chance, %d%% power."):tformat(eff.chance, eff.power) end,
	type = "magical",
	subtype = { pain=true, torture=true, tentacles=true, leech=true },
	status = "beneficial",
	parameters = { power=10, chance=10 },
	on_gain = function(self, err) return _t"#Target# is empowered by the pain of its victim.", true end,
	on_lose = function(self, err) return _t"#Target# is less powerfull.", true end,
	activate = function(self, eff)
	end,
	callbackOnDealDamage = function(self, eff, value, target, dead, death_node)
		-- Lifesteal done here to avoid stacking in bad ways with other LS effects
		if not rng.percent(eff.chance) then	return end
		if value <= 0 or not target or dead then return end
			local leech = math.min(value, target.life) * eff.power / 100
			if leech > 0 then
				self:heal(leech, self)
			end
	end,
}

newEffect{
	name = "HORRIFIC_DISPLAY", image = "talents/horrific_display.png",
	desc = _t"Horrific Display",
	long_desc = function(self, eff) return ("Appearance changed to an horror, everything is hostile to it."):tformat() end,
	type = "magical",
	subtype = { horror=true, morph=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return _t"#PURPLE##Target# turns into an horror.", true end,
	on_lose = function(self, err) return _t"#Target# is back to normal.", true end,
	on_timeout = function(self, eff)
		if not eff.src or eff.src:getTalentLevel(eff.src.T_DEMENTED_CALL_AMAKTHEL) < 5 then return end
		local tgts = {}

		self:project({type="ball", range=0, friendlyfire=false, radius=10}, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if target == eff.src or target:resolveSource() == eff.src then return end  -- Pseudofaction to avoid anything directly linked to the effect source
			if self:reactionToward(target) < 0 and not tgts[target] then
				tgts[target] = true
				local ox, oy = target.x, target.y
				target:pull(self.x, self.y, 1)
				if target.x ~= ox or target.y ~= oy then game.logSeen(target, "%s is pulled in!", target:getName():capitalize()) end
			end
		end)
	end,
	activate = function(self, eff)
		self:project({type="ball", radius=10}, self.x, self.y, function(px, py)
			local act = game.level.map(px, py, Map.ACTOR)
			if not act or self:reactionToward(act) <= 0 then return end
			if act == eff.src or act:resolveSource() == eff.src then return end  -- Pseudofaction to avoid anything directly linked to the effect source
			act:setTarget(nil)
		end)
		self:effectTemporaryValue(eff, "hated_by_everybody", 1)
		self.replace_display = mod.class.Actor.new{
			image="npc/horrific_display.png",
		}
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
	deactivate = function(self, eff)
		self.replace_display = nil
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
}

newEffect{
	name = "DISOLVED_FACE", image = "talents/disolved_face.png",
	desc = _t"Dissolved Face",
	long_desc = function(self, eff) return ("Blood and gore cover the target, dealing %0.2f darkness damage and %0.2f blight damage per disease."):tformat(eff.dam, eff.dam * 0.7) end,
	type = "magical",
	subtype = { darkness=true, blight=true, gore=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is covered in gore.", true end,
	on_lose = function(self, err) return _t"#Target# is no longer covered in gore.", true end,
	parameters = { power=10 },
	on_timeout = function(self, eff)
		DamageType:get(DamageType.DARKNESS).projector(eff.src or self, self.x, self.y, DamageType.DARKNESS, eff.dam)
		local diseases = self:effectsFilter{subtype={disease=true}}
		if #diseases > 0 then
			DamageType:get(DamageType.BLIGHT).projector(eff.src or self, self.x, self.y, DamageType.BLIGHT, (0.7 * eff.dam * #diseases) )
		end
	end,
}

newEffect{
	name = "GLIMPSE_OF_TRUE_HORROR", image = "talents/glimpse_of_true_horror.png",
	desc = _t"Glimpse of True Horror",
	long_desc = function(self, eff) return ("Target briefly saw what True Horror means, deeply scaring it. %d%% chances to fail using a talent."):tformat(eff.fail) end,
	type = "magical",
	subtype = { darkness=true, blight=true, horror=true, fear=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# saw true horror.", true end,
	on_lose = function(self, err) return _t"#Target# is less afraid.", true end,
	parameters = { fail=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "talent_fail_chance", eff.fail)
	end,
}

newEffect{
	name = "GLIMPSE_OF_TRUE_HORROR_SELF", image = "talents/glimpse_of_true_horror.png",
	desc = _t"Glimpse of True Horror",
	long_desc = function(self, eff) return ("Empowered by the fear of its foes, darkness and blight damage penetration increased by %d%%."):tformat(eff.pen) end,
	type = "magical",
	subtype = { darkness=true, blight=true, horror=true },
	status = "beneficial",
	on_gain = function(self, err) return _t"#Target# is empowered by the fear of #hisher# foes.", true end,
	on_lose = function(self, err) return _t"#Target# is less powerfull.", true end,
	parameters = { fail=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists_pen", {[DamageType.DARKNESS]=eff.pen, [DamageType.BLIGHT]=eff.pen})
	end,
}

newEffect{
	name = "WRITHING_HAIRS", image = "talents/writhing_hairs.png",
	desc = _t"Writhing Hairs",
	long_desc = function(self, eff) return ("Half turned to stone, reducing movement speed by %d%% and 35%% chances to shatter on damage, increasing damge taken by %d%%."):tformat(eff.speed * 100, eff.brittle) end,
	type = "magical",
	subtype = { stone=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is half-turned to stone.", true end,
	on_lose = function(self, err) return _t"#Target# looks less like a statue.", true end,
	parameters = { speed=0.1, brittle=10 },
	callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, state)
		if rng.percent(35) then
			return {dam = dam * eff.brittle / 100}
		end
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "movement_speed", -eff.speed)
	end,
}

newEffect{
	name = "SPLIT", image = "talents/split.png",
	desc = _t"Split",
	long_desc = function(self, eff) return ("Faded from time, reducing damage taken by %d%% and all damage dealt by %d%%."):tformat(eff.power, eff.dam) end,
	type = "magical",
	subtype = { temporal=true, },
	status = "detrimental",
	parameters = {power = 10 , rad = 1},
	on_gain = function(self, err) return _t"#Target# is removed from the timeline!", _t"+Split" end,
	on_lose = function(self, err) return _t"#Target# returns to normal time.", _t"-Split" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("numbed", eff.dam)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("numbed", eff.tmpid)
	end,
	callbackOnHit = function(self, eff, cb, src)
		cb.value = cb.value - (cb.value * (1 - eff.resist/100))
		return cb.value
	end,
}

newEffect{
	name = "HALO_OF_RUIN", image = "talents/halo_of_ruin.png",
	desc = _t"Halo of Ruin",
	long_desc = function(self, eff) return ("Increases spell critical chance by %d%%. At 5 stacks, next Nether spell is empowered."):tformat(eff.power * eff.charges) end,
	type = "magical",
	display_desc = function(self, eff) return ("%d Halo of Ruin"):tformat(eff.charges) end,
	charges = function(self, eff) return eff.charges end,
	subtype = { blight=true },
	status = "beneficial",
	parameters = {power=1, charges=1, max_charges=5},
	update_visual = function(self, eff)
		if not core.shader.active(4) then return end
		eff.visual_charges = eff.visual_charges or {}

		for i = eff.charges + 1, #eff.visual_charges do
			self:removeParticles(eff.visual_charges[i][1])
			self:removeParticles(eff.visual_charges[i][2])
			eff.visual_charges[i] = nil
		end
		for i = 1, eff.charges do
			if not eff.visual_charges[i] then
				eff.visual_charges[i] = {}
				eff.visual_charges[i][1] = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  y=-0.4, size_factor=1, img="halo_of_ruin"}, {type="rotatingshield", noup=2.0, appearTime=0.1, shieldIntensity=0.25, time_factor=450, ellipsoidalFactor=1.5}))
				eff.visual_charges[i][2] = self:addParticles(Particles.new("shader_shield", 1, {toback=false, y=-0.4, size_factor=1, img="halo_of_ruin"}, {type="rotatingshield", noup=1.0, appearTime=0.1, shieldIntensity=0.25, time_factor=450, ellipsoidalFactor=1.5}))
			end
		end
	end,
	on_merge = function(self, old_eff, new_eff, ed)
		-- remove the old value
		self:removeTemporaryValue("combat_spellcrit", old_eff.critid)
		
		-- add a charge
		old_eff.charges = math.min(old_eff.charges + 1, new_eff.max_charges)
		
		-- and apply the current values	
		old_eff.critid = self:addTemporaryValue("combat_spellcrit", old_eff.power * old_eff.charges)
		
		old_eff.dur = new_eff.dur

		ed.update_visual(self, old_eff)
		return old_eff
	end,
	activate = function(self, eff, ed)
		eff.critid = self:addTemporaryValue("combat_spellcrit", eff.power * eff.charges)
		ed.update_visual(self, eff)
	end,
	deactivate = function(self, eff, ed)
		self:removeTemporaryValue("combat_spellcrit", eff.critid)
		eff.charges = 0
		ed.update_visual(self, eff)
	end,
}

newEffect{
	name = "VOIDBURN", image = "talents/netherblast.png",
	desc = _t"Voidburn",
	long_desc = function(self, eff) return ("The target has been seared by the void, taking %0.2f darkness and %0.2f temporal damage each turn."):tformat(math.floor(eff.power/2), math.floor(eff.power/2)) end,
	type = "magical",
	subtype = { temporal=true, darkness=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return _t"#Target# is ignited by voidfire!", _t"+Voidburn" end,
	on_lose = function(self, err) return _t"#Target# is no longer ignited.", _t"-Voidburn" end,
	charges = function(self, eff) return math.floor(eff.power) end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.VOID).projector(eff.src, self.x, self.y, DamageType.VOID, eff.power)
	end,
}

newEffect{
	name = "DARK_WHISPERS", image = "talents/dark_whispers.png",
	desc = _t"Dark Whispers",
	long_desc = function(self, eff) return ("The target is being driven mad by the void, taking %0.2f darkness damage per turn and reducing all powers by %d."):tformat(eff.dam, eff.power) end,
	type = "magical",
	subtype = { darkness=true },
	status = "detrimental",
	parameters = { dam=10, power=10, maxpower=30 },
	on_gain = function(self, err) return _t"#Target# is haunted by the void!", _t"+Dark Whispers" end,
	on_lose = function(self, err) return _t"#Target#'s whispers fade.", _t"-Dark Whispers" end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("combat_dam", old_eff.damid)
		self:removeTemporaryValue("combat_spellpower", old_eff.spellid)
		self:removeTemporaryValue("combat_mindpower", old_eff.mindid)

		local olddam = old_eff.dam * old_eff.dur
		local newdam = new_eff.dam * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		local power = math.min(new_eff.maxpower, old_eff.power + new_eff.power)
		old_eff.dur = dur
		old_eff.dam = (olddam + newdam) / dur
		old_eff.power = power
		old_eff.damid = self:addTemporaryValue("combat_dam", -old_eff.power)
		old_eff.spellid = self:addTemporaryValue("combat_spellpower", -old_eff.power)
		old_eff.mindid = self:addTemporaryValue("combat_mindpower", -old_eff.power)
		return old_eff
	end,
	activate = function(self, eff)
		eff.damid = self:addTemporaryValue("combat_dam", -eff.power)
		eff.spellid = self:addTemporaryValue("combat_spellpower", -eff.power)
		eff.mindid = self:addTemporaryValue("combat_mindpower", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.damid)
		self:removeTemporaryValue("combat_spellpower", eff.spellid)
		self:removeTemporaryValue("combat_mindpower", eff.mindid)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.DARKNESS).projector(eff.src, self.x, self.y, DamageType.DARKNESS, eff.dam)
		if eff.src:knowTalent(eff.src.T_HIDEOUS_VISIONS) and not self:hasEffect(self.EFF_HIDEOUS_VISIONS) then 
			local t = eff.src:getTalentFromId(eff.src.T_HIDEOUS_VISIONS)
			local chance = t.getChance(eff.src, t)
			if self:hasEffect(self.EFF_CACOPHONY) then chance = chance + 20 end
			if rng.percent(chance) then
				t.hideous_vision(eff.src, t, self)
			end
		end
		if self:hasEffect(self.EFF_CACOPHONY) then
			local ceff = self:hasEffect(self.EFF_CACOPHONY)
			local cdam = ceff.power * eff.dam
			DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, cdam)
		end
	end,
}

newEffect{
	name = "HIDEOUS_VISIONS", image = "talents/hideous_visions.png",
	desc = _t"Hideous Visions",
	long_desc = function(self, eff) return ("The target is being distracted by a hallucination, reducing all damage dealt to non-hallucinations targets by %d%%."):tformat(eff.power) end,
	type = "other",
	subtype = { darkness=true },
	status = "detrimental",
	parameters = { power=1 },
	callbackOnDealDamage = function(self, eff, value, target, dead, death_node)
		if dead then return end
		if value <= 0 then return end
		if target == eff.src then return end
		value = value - (value * eff.power / 100)
		return value
	end,
}

newEffect{
	name = "CACOPHONY", image = "talents/cacophony.png",
	desc = _t"Cacophony",
	long_desc = function(self, eff) return ("The target is overwhelmed by voices from the void, giving them a 20%% higher chance to spawn hallucinations from Dark Whispers and causing them to take an additional %d%% temporal damage from Dark Whispers and Hideous Visions."):tformat(eff.power * 100) end,
	type = "magical",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return _t"#Target#'s mind is shattered by the void!", _t"+Cacophony" end,
	on_lose = function(self, err) return _t"#Target# seems more focused.", _t"-Cacophony" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ENTROPIC_WASTING", image = "talents/entropic_gift.png",
	desc = _t"Entropic Wasting",
	long_desc = function(self, eff) return ("The target is wasting away from entropic forces, taking %0.2f damage per turn."):tformat(eff.power) end,
	type = "other",
	charges = function(self, eff) return math.floor(eff.power*eff.dur) end,
	subtype = { temporal=true, darkness=true }, no_ct_effect = true,
	cancel_on_level_change = true,
	parameters = { power = 100, },
	on_gain = function(self, err) return _t"#Target# is wasting away!", _t"+Entropic Wasting" end,
	on_lose = function(self, err) return _t"#Target#'s is no longer wasting away.", _t"-Entropic Wasting" end,
	activate = function(self, eff)
		if self:knowTalent(self.T_NIHIL) then
			local t = self:getTalentFromId(self.T_NIHIL)
			t.do_nihil(self,t)
		end
		if core.shader.active() then
			local hx, hy = self:attachementSpot("head", true) hx, hy = hx or 0, hy or 0
			self:effectParticles(eff, {type="shader_shield", args={toback=true, x=hx, y=hy, size_factor=1, img="entropy_player"}, shader={type="tentacles", appearTime=0.6, time_factor=300, noup=0.0}})
		end
	end,
	deactivate = function(self, eff)
	end,
	on_merge = function(self, old_eff, new_eff)
		if self:knowTalent(self.T_NIHIL) then
			local t = self:getTalentFromId(self.T_NIHIL)
			t.do_nihil(self,t)
		end
		local adjusted_power = (old_eff.power * old_eff.dur / new_eff.dur)
		local dur = math.max(old_eff.dur, new_eff.dur)
		local power = adjusted_power + new_eff.power
		old_eff.dur = dur
		old_eff.power = power
		return old_eff
	end,
	on_timeout = function(self, eff)
		if self.resting then self:removeEffect(self.EFF_ENTROPIC_WASTING) return end
		if self:attr("ignore_entropic_wasting") then return end
		local dam = eff.power
		if eff.src:knowTalent(eff.src.T_REVERSE_ENTROPY) then
			local reduce = eff.src:callTalent(eff.src.T_REVERSE_ENTROPY, "getReduction") / 100
			dam = dam * (1 - reduce)
		end
		if (self.life - dam) > (self.die_at or 0) then
			self.life = self.life - dam
			game.logSeen(self, "#{bold}##LIGHT_STEEL_BLUE#%s loses %d health to the entropy.#{normal}##LAST##", self:getName():capitalize(), math.ceil(dam))
		else
			self.life = (self.die_at or 0) + 1
			game.logSeen(self, "#{bold}##RED#%s loses %d health and is almost overcome by the entropy!#{normal}##LAST##", self:getName():capitalize(), math.ceil(dam))
		end
	end,
}

newEffect{
	name = "ENTROPIC_GIFT", image = "talents/entropic_gift.png",
	desc = _t"Entropic Gift",
	long_desc = function(self, eff) return ("The full force of entropy has been brought to bear on the target, inflicting %0.2f darkness and %0.2f temporal damage each turn."):tformat(eff.power/2, eff.power/2) end,
	charges = function(self, eff) return math.floor(eff.power) end,
	type = "magical",
	subtype = { temporal=true, darkness=true },
	status = "detrimental",
	parameters = { power=10, resist=10 },
	on_gain = function(self, err) return _t"#Target# is consumed by entropy!", _t"+Entropic Gift" end,
	on_lose = function(self, err) return _t"#Target# has survived the entropic gift.", _t"-Entropic Gift" end,
	on_timeout = function(self, eff)
		local insanity = eff.src:callTalent(eff.src.T_ENTROPIC_GIFT, "getInsanity")
		if insanity > 0 and not self.turn_procs.entropic_gift then
			self.turn_procs.entropic_gift = 1
			eff.src:incInsanity(insanity) 
		end
		DamageType:get(DamageType.VOID).projector(eff.src, self.x, self.y, DamageType.VOID, eff.power)
	end,
	activate = function(self, eff)
		if core.shader.active() then
			local hx, hy = self:attachementSpot("head", true) hx, hy = hx or 0, hy or 0
			self:effectParticles(eff, {type="shader_shield", args={x=hx, y=hy, size_factor=1.5, img="entropic_gift"}, shader={type="tentacles", appearTime=0.6, time_factor=700, noup=0.0}})
		end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "PROPHECY_OF_MADNESS", image = "talents/prophecy_of_madness.png",
	desc = _t"Prophecy of Madness",
	long_desc = function(self, eff) return ("The target is doomed to madness. All talent cooldowns are increased by %d%%."):tformat(eff.power*100) end,
	type = "magical",
	subtype = { darkness=true, prophecy=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is doomed to madness!", _t"+Prophecy of Madness" end,
	on_lose = function(self, err) return _t"#Target# is free from the prophecy.", _t"-Prophecy of Madness" end,
	parameters = { power=0.4, cd=1, turns=3, nb=2,  },
	activate = function(self, eff)
		if not eff.twofold then
			if self:hasEffect(self.EFF_PROPHECY_OF_RUIN) then self:removeEffect(self.EFF_PROPHECY_OF_RUIN) end 
			if self:hasEffect(self.EFF_PROPHECY_OF_TREASON) then self:removeEffect(self.EFF_PROPHECY_OF_TREASON) end
		end
		if core.shader.active() then
			self:effectParticles(eff, {type="shader_shield", args={x=0, y=0, size_factor=1, img="prophecy_debuff"}, shader={type="tentacles", appearTime=1, time_factor=1000, noup=0.0}})
		end

	end,
	deactivate = function(self, eff)
	end,
	callbackOnTalentPost = function(self, eff, ab)
		if not eff.src then return end
		if not ab.innate then
			local eff = self:hasEffect(self.EFF_PROPHECY_OF_MADNESS)
			if eff.cd > 0 then
				local tids = {}
				for tid, _ in pairs(eff.src.talents_cd) do
					local tt = eff.src:getTalentFromId(tid)
					if not tt.fixed_cooldown then
						tids[#tids+1] = tt
					end
				end
	
				if #tids > 0 then
					local tid = rng.tableRemove(tids)
					eff.src:alterTalentCoolingdown(tid, - eff.cd)
					game.logSeen(eff.src, "%s talent '%s%s' is energized by the revelation!", eff.src:getName():capitalize(), (tid.display_entity and tid.display_entity:getDisplayString() or ""), tid.name)					
				end
			end
		end
	end,
}

newEffect{
	name = "PROPHECY_OF_RUIN", image = "talents/prophecy_of_ruin.png",
	desc = _t"Prophecy of Ruin",
	long_desc = function(self, eff) return ("The target is doomed to ruin.  On falling below 75%%, 50%% or 25%% life all enemies in radius %d will take %0.2f darkness damage"):tformat(eff.rad, eff.dam) end,
	type = "magical",
	subtype = { darkness=true, prophecy=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is doomed to ruin!", _t"+Prophecy of Ruin" end,
	on_lose = function(self, err) return _t"#Target# is free from the prophecy.", _t"-Prophecy of Ruin" end,
	parameters = { dam=1, rad=1 },
	activate = function(self, eff)
		if not eff.twofold then
			if self:hasEffect(self.EFF_PROPHECY_OF_MADNESS) then self:removeEffect(self.EFF_PROPHECY_OF_MADNESS) end 
			if self:hasEffect(self.EFF_PROPHECY_OF_TREASON) then self:removeEffect(self.EFF_PROPHECY_OF_TREASON) end
		end
		if core.shader.active() then
			self:effectParticles(eff, {type="shader_shield", args={x=0, y=0, size_factor=1, img="prophecy_debuff"}, shader={type="tentacles", appearTime=1, time_factor=1000, noup=0.0}})
		end

	end,
	deactivate = function(self, eff)
	end,
	callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, tmp)
		local eff = self:hasEffect(self.EFF_PROPHECY_OF_RUIN)
		if eff and eff.heal > 0 and dam > 0 and eff.src == src then
			src:heal(dam * eff.heal /100, self)
		end
	end,
	callbackOnHit = function(self, eff, cb)
		if cb.value <= 0 then return cb.value end
				
		local limit1 = self.max_life * 0.75
		local limit2 = self.max_life * 0.50
		local limit3 = self.max_life * 0.25
		local life = self.life - cb.value
		local dam = eff.dam
	
		if self.life > limit1 and life <= limit1 and not self.turn_procs.prophecy_ruin_1 then
			self.turn_procs.prophecy_ruin_1 = true
			local tg = {type="ball", radius=eff.rad, selffire=false, x=self.x, y=self.y, friendlyfire=false}
			eff.src:projectSource(tg, self.x, self.y, DamageType.DARKNESS, dam, nil, eff)
			if core.shader.active(4) then
				game.level.map:particleEmitter(self.x, self.y, eff.rad, "shader_ring", {radius=eff.rad*2, life=12}, {type="sparks", zoom=1, time_factor=400, hide_center=0, color1={0.4, 0.1, 0.4, 1}, color2={0.4, 0, 0.4, 1}})
			else
				game.level.map:particleEmitter(self.x, self.y, eff.rad, "generic_ball", {rm=75, rM=90, gm=10, gM=30, bm=90, bM=100, am=80, aM=150, radius=2})
			end			
		end
		
		if self.life > limit2 and life <= limit2 and not self.turn_procs.prophecy_ruin_2 then
			self.turn_procs.prophecy_ruin_2 = true
			local tg = {type="ball", radius=eff.rad, selffire=false, x=self.x, y=self.y, friendlyfire=false}
			eff.src:projectSource(tg, self.x, self.y, DamageType.DARKNESS, dam, nil, eff)
			if core.shader.active(4) then
				game.level.map:particleEmitter(self.x, self.y, eff.rad, "shader_ring", {radius=eff.rad*2, life=12}, {type="sparks", zoom=1, time_factor=400, hide_center=0, color1={0.4, 0.1, 0.4, 1}, color2={0.4, 0, 0.4, 1}})
			else
				game.level.map:particleEmitter(self.x, self.y, eff.rad, "generic_ball", {rm=75, rM=90, gm=10, gM=30, bm=90, bM=100, am=80, aM=150, radius=2})
			end						
		end
		
		if self.life > limit3 and life <= limit3 and not self.turn_procs.prophecy_ruin_3 then
			self.turn_procs.prophecy_ruin_3 = true
			local tg = {type="ball", radius=eff.rad, selffire=false, x=self.x, y=self.y, friendlyfire=false}
			eff.src:projectSource(tg, self.x, self.y, DamageType.DARKNESS, dam, nil, eff)
			if core.shader.active(4) then
				game.level.map:particleEmitter(self.x, self.y, eff.rad, "shader_ring", {radius=eff.rad*2, life=12}, {type="sparks", zoom=1, time_factor=400, hide_center=0, color1={0.4, 0.1, 0.4, 1}, color2={0.4, 0, 0.4, 1}})
			else
				game.level.map:particleEmitter(self.x, self.y, eff.rad, "generic_ball", {rm=75, rM=90, gm=10, gM=30, bm=90, bM=100, am=80, aM=150, radius=2})
			end				
		end
		
		return cb.value
	end,
}

newEffect{
	name = "PROPHECY_OF_TREASON", image = "talents/prophecy_of_treason.png",
	desc = _t"Prophecy of Treason",
	long_desc = function(self, eff) return ("The target is doomed to treason. Each turn they have a %d%% chance to attack an adjacent creature.  If no creatures are adjacent they will attack themself."):tformat(eff.power) end,
	type = "magical",
	subtype = { darkness=true, prophecy=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is doomed to treason!", _t"+Prophecy of Treason" end,
	on_lose = function(self, err) return _t"#Target# is free from the prophecy.", _t"-Prophecy of Treason" end,
	parameters = { power=10,},
	activate = function(self, eff)
		if not eff.twofold then
			if self:hasEffect(self.EFF_PROPHECY_OF_MADNESS) then self:removeEffect(self.EFF_PROPHECY_OF_MADNESS) end 
			if self:hasEffect(self.EFF_PROPHECY_OF_RUIN) then self:removeEffect(self.EFF_PROPHECY_OF_RUIN) end
		end
		if core.shader.active() then
			self:effectParticles(eff, {type="shader_shield", args={x=0, y=0, size_factor=1, img="prophecy_debuff"}, shader={type="tentacles", appearTime=1, time_factor=1000, noup=0.0}})
		end

	end,
	deactivate = function(self, eff)
	end,
	callbackOnAct = function(self, eff)
		if not self:enoughEnergy() then return nil end

		-- apply periodic timer instead of random chance
		if not eff.timer then
			eff.timer = rng.float(0, 100)
		end
		if not self:checkHit(eff.src:combatSpellpower(), self:combatSpellResist(), 0, 95, 5) then
			eff.timer = eff.timer + eff.power * 0.5
			game.logSeen(self, "#F53CBE#%s struggles to resist the prophecy.", self:getName():capitalize())
		else
			eff.timer = eff.timer + eff.power
		end
		if eff.timer > 100 then
			eff.timer = eff.timer - 100

			local start = rng.range(0, 8)
			local hit = false
			for i = start, start + 8 do
				local x = self.x + (i % 3) - 1
				local y = self.y + math.floor((i % 9) / 3) - 1
				if (self.x ~= x or self.y ~= y) then
					local target = game.level.map(x, y, Map.ACTOR)
					if target and not target.dead then
						game.logSeen(target, "#F53CBE#%s succumbs to the prophecy, attacking %s!", self:getName():capitalize(), target:getName():capitalize())
						self:attackTarget(target, nil, 0.1, false)
						hit = true
						return
					end
				end
			end
			if not hit then
				game.logSeen(self, "#F53CBE#%s succumbs to the prophecy, striking themself!", self:getName():capitalize())
				self:attackTarget(self, nil, 0.1, false)
				return
			end
		end
	end,
}

newEffect{
	name = "MARK_OF_TREASON", image = "talents/prophecy_of_treason.png",
	desc = _t"Mark of Treason",
	long_desc = function(self, eff) return ("When this target is damaged %d%% of the damage will also be done to the source of this effect."):tformat(eff.power) end,
	type = "magical",
	subtype = { darkness=true, prophecy=true },
	status = "detrimental",
	parameters = { power=40 },
	on_gain = function(self, err) return _t"#Target# is linked through the prophecy.", _t"+Mark of Treason" end,
	on_lose = function(self, err) return _t"#Target# prophetic link disappears.", _t"-Mark of Treason" end,
	callbackOnHit = function(self, eff, cb, src)
		if value.value <= 0 then return end
		if eff.source.dead then return end

		local linked_damage = cb.value * eff.power / 100
		eff.source:takeHit(linked_damage, src)		
		game:delayedLogMessage(self, eff.source, "linkofpain" ,"#ORANGE#The wounds of #Source# appear on #target#!#LAST#")
		game:delayedLogDamage(self, eff.source, linked_damage, ("#CRIMSON#(%d linked)#LAST#"):tformat(linked_damage), false)
		
	end,
	callbackOnMove = function(self, eff)
		self:removeParticles(eff.particle)
		if not eff.source.dead then
			eff.particle = self:addParticles(Particles.new("link_of_pain", 1, {tx=(eff.source.x-self.x), ty=(eff.source.y-self.y)}))
		end
	end,
	callbackOnAct = function(self, eff)
		self:removeParticles(eff.particle)
		if not eff.source.dead then
			eff.particle = self:addParticles(Particles.new("link_of_pain", 1, {tx=(eff.source.x-self.x), ty=(eff.source.y-self.y)}))
		end
	end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("link_of_pain", 1, {tx=(eff.source.x-self.x), ty=(eff.source.y-self.y)}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "NIHIL", image = "talents/nihil.png",
	desc = _t"Nihil",
	long_desc = function(self, eff) return ("The target is engulfed in entropy, reducing the duration of new beneficial effects and increasing the duration of new negative effects by %d%%.\nThis effect will fade in 2 turns if the source is not in line of sight."):tformat(eff.power*100) end,
	charges = function(self, eff) return eff.nb or 0 end,	
	type = "other",
	subtype = { temporal=true, darkness=true },
	status = "detrimental",
	parameters = { power=0.1, dam=0.1, numb=0, damage=0, nb=0 },
	on_gain = function(self, err) return _t"#Target# is wreathed in entropy." end,
	on_lose = function(self, err) return _t"#Target# is free of the entropy." end,
	activate = function(self, eff)
		if eff.src:knowTalent(eff.src.T_ERASE) then eff.damage = eff.src:spellCrit(eff.src:callTalent(eff.src.T_ERASE, "getDamage")) end -- Only calculate crit once per application
		eff.detid = self:addTemporaryValue("increase_detrimental_status_effects_time", eff.power)
		eff.benid = self:addTemporaryValue("reduce_beneficial_status_effects_time", eff.power)		
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("increase_detrimental_status_effects_time", eff.detid)
		self:removeTemporaryValue("reduce_beneficial_status_effects_time", eff.benid)		
	end,
	on_merge = function(self, old_eff, new_eff)
		-- We could recalculate crit here, but in the name of not giving up free crit procs so easily its proooobably better not to.. Debatable
		local dur = math.max(old_eff.dur, new_eff.dur)
		local nb = math.max(old_eff.nb, new_eff.nb) -- Don't reset Unravel count on merge
		--local power = old_eff.power + new_eff.power
		old_eff.dur = dur
		--old_eff.power = power
		old_eff.nb = nb
		return old_eff
	end,
	on_timeout = function(self, eff)
		-- Remove the entire effect independent of stacks if LOS is broken for more than 2 turns
		if eff.src.x and not self:hasLOS(eff.src.x, eff.src.y) then
			eff.fading = eff.fading or 0
			eff.fading = eff.fading + 1
			if eff.fading >= 2 then self:removeEffect(self.EFF_NIHIL) end
		else
			eff.fading = nil
		end
		if eff.src:knowTalent(eff.src.T_ERASE) then
			local dam = eff.damage
			local nb = 0
	
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.status == "detrimental" and e.type == "magical" then
					nb = nb + 1
				end
			end
			
			if nb > 0 then
				dam = dam * nb
				DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, dam)
			end
		end
	end,
	callbackOnDealDamage = function(self, eff, value, target, dead, death_node)
		if dead then return end
		if value <= 0 then return end
		
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type == "magical" then
				nb = nb + 1
			end
		end
		value = value - (value * eff.numb * nb / 100)
		return value
	end,
	callbackOnTemporaryEffect = function(self, eff, eff_id, e, p)
		local t = eff.src:getTalentFromId(eff.src.T_UNRAVEL_EXISTENCE)
		if not t or not eff.src:knowTalent(t) then return end
		if eff.src:isTalentCoolingDown(t) then return end
		if e.type == "magical" and e.status == "detrimental" and not e.subtype["cross tier"] and not (eff_id == self.EFF_ARCANE_EYE_SEEN) then
			eff.nb = eff.nb + 1
			if eff.nb >= 6 then
				t.unravel(eff.src, self, t, eff.dur)
				eff.nb = 0
				game.logSeen(self, "#LIGHT_RED#A void annihilator manifests from %s!", self:getName():capitalize())
			end
		end
	end,
}

newEffect{
	name = "ATROPHY", image = "talents/atrophy.png",
	desc = _t"Atrophy",
	long_desc = function(self, eff) return ("The target's mind and body is wasting away, reducing all stats by %d.\nThis effect will fade in 2 turns if the source is not in line of sight."):tformat(eff.power*eff.charges) end,
	type = "other",
	status = "detrimental",
	subtype = { temporal=true },
	parameters = { power=4, max_charges = 5, charges = 1  },
	on_gain = function(self, err) return _t"#Target# is wasting away." end,
	on_lose = function(self, err) return _t"#Target# regains their strength." end,
	charges = function(self, eff) return eff.charges or 0 end,
	no_stop_enter_worlmap = true,
	activate = function(self, eff)		
		eff.src.atrophy_targets = eff.src.atrophy_targets or {}
		eff.src.atrophy_targets[self] = true

		eff.statid = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_DEX] = -eff.power,
			[Stats.STAT_STR] = -eff.power,
			[Stats.STAT_CON] = -eff.power,
			[Stats.STAT_MAG] = -eff.power,
			[Stats.STAT_WIL] = -eff.power,
			[Stats.STAT_CUN] = -eff.power,			
		})

		local hx, hy = self:attachementSpot("shoulder2", true) hx, hy = hx or 0, hy or 0
		self:effectParticles(eff, {type="circle", args={x=hx, y=hy, oversize=1, base_rot=0, a=220, shader=true, appear=12, img="cultist_atrophy_debuff", speed=0, radius=0}})
	end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		
		local stackCount = old_eff.charges + new_eff.charges
		if stackCount >= old_eff.max_charges then 
			stackCount = old_eff.max_charges
		end
		
		self:removeTemporaryValue("inc_stats", old_eff.statid)
		old_eff.statid = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_DEX] = -old_eff.power*stackCount,
			[Stats.STAT_STR] = -old_eff.power*stackCount,
			[Stats.STAT_CON] = -old_eff.power*stackCount,
			[Stats.STAT_MAG] = -old_eff.power*stackCount,
			[Stats.STAT_WIL] = -old_eff.power*stackCount,
			[Stats.STAT_CUN] = -old_eff.power*stackCount,
		})
		
		old_eff.charges = stackCount
		return old_eff
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.statid) eff.statid = nil
	end,
	on_timeout = function(self, eff)
		-- Remove the entire effect independent of stacks if LOS is broken for more than 2 turns
		if eff.src.dead or not game.level:hasEntity(eff.src) then
			self:removeEffect(self.EFF_ATROPHY)
		elseif eff.src.x and not self:hasLOS(eff.src.x, eff.src.y) then
			eff.fading = eff.fading or 0
			eff.fading = eff.fading + 1
			if eff.fading >= 2 then self:removeEffect(self.EFF_ATROPHY) end
		else
			eff.fading = nil
		end
	end,
}

newEffect{
	name = "TEMPORAL_FEAST", image = "talents/temporal_feast.png",
	desc = _t"Temporal Feast",
	long_desc = function(self, eff) return ("Increases spellcast speed by %d%%."):tformat(eff.power * 100 * eff.charges) end,
	type = "magical",
	display_desc = function(self, eff) return ("%d Temporal Feast"):tformat(eff.charges) end,
	charges = function(self, eff) return eff.charges end,
	subtype = { speed=true, temporal=true },
	status = "beneficial",
	parameters = {power=0.1, charges=1, max_charges=5},
	on_merge = function(self, old_eff, new_eff)
		-- remove the old value
		self:removeTemporaryValue("combat_spellspeed", old_eff.speedid)
		
		-- add a charge
		old_eff.charges = math.max(new_eff.charges, old_eff.charges)
		
		-- and apply the current values	
		old_eff.speedid = self:addTemporaryValue("combat_spellspeed", old_eff.power * old_eff.charges)
		
		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.speedid = self:addTemporaryValue("combat_spellspeed", eff.power * eff.charges)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_spellspeed", eff.speedid)
	end,
}

newEffect{
	name = "VOID_RIFT", image = "talents/reality_fracture.png",
	desc = _t"Void Rift",
	long_desc = function(self, eff) return ("The target has %d active void rift(s)."):tformat(eff.charges) end,
	type = "other",
	display_desc = function(self, eff) return ("%d Void Rifts"):tformat(eff.charges) end,
	charges = function(self, eff) return eff.charges end,
	subtype = { darkness=true, temporal=true },
	status = "detrimental",
	parameters = {power=1, charges=1, max_charges=5},
	callbackOnActBase = function(self, eff)
		-- remove the old value
		self:removeTemporaryValue("inc_damage", eff.pid1)
		
		-- and apply the current values	
		eff.pid1 = self:addTemporaryValue("inc_damage", {all=eff.power * eff.charges})
		
		return eff
	end,	
	on_merge = function(self, old_eff, new_eff)
		-- remove the old value
		self:removeTemporaryValue("inc_damage", old_eff.pid1)
		
		-- add a charge
		old_eff.charges = math.min(old_eff.charges + 1, new_eff.max_charges)
		
		-- and apply the current values	
		old_eff.pid1 = self:addTemporaryValue("inc_damage", {all=old_eff.power * old_eff.charges})
		
		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.pid1 = self:addTemporaryValue("inc_damage", {all=eff.power * eff.charges})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid1)
	end,
}

--[=[
newEffect{
	name = "NETHER_BREACH", image = "talents/pierce_the_veil_nether.png",
	desc = _t"Nether Breach",
	long_desc = function(self, eff) return ("The target has a nether breach open firing beams at nearby enemies."):tformat() end,
	type = "other",
	subtype = { darkness=true, temporal=true },
	status = "detrimental",
	parameters = {power=1  },
	activate = function(self, eff)
		eff.pid1 = self:addTemporaryValue("inc_damage", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid1)
	end,
}

newEffect{
	name = "TEMPORAL_VORTEX", image = "talents/pierce_the_veil_temporal.png",
	desc = _t"Temporal Vortex",
	long_desc = function(self, eff) return ("The target has a temporal vortex open slowing nearby enemies."):tformat() end,
	type = "other",
	subtype = { darkness=true, temporal=true },
	status = "detrimental",
	parameters = { power=1 },
	activate = function(self, eff)
		eff.pid1 = self:addTemporaryValue("inc_damage", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid1)
	end,
}

newEffect{
	name = "DIMENSIONAL_GATEWAY", image = "talents/pierce_the_veil_dimensional.png",
	desc = _t"Dimensional Gateay",
	long_desc = function(self, eff) return ("The target has a dimensional gateway open summoning Void Skitterers."):tformat() end,
	type = "other",
	subtype = { darkness=true, temporal=true },
	status = "detrimental",
	parameters = { power=1 },
	activate = function(self, eff)
		eff.pid1 = self:addTemporaryValue("inc_damage", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid1)
	end,
}
--]=]
newEffect{
	name = "ACCELERATE", image = "talents/accelerate.png",
	desc = _t"Accelerate",
	long_desc = function(self, eff) return ("Moving at extreme speed (%d%% faster).  Any action other than movement will cancel it."):tformat(eff.power) end,
	type = "magical",
	subtype = { temporal=true, speed=true },
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return _t"#Target# is moving at extreme speed!", _t"+Accelerate" end,
	on_lose = function(self, err) return _t"#Target# slows down.", _t"-Accelerate" end,
	get_fractional_percent = function(self, eff)
		local d = game.turn - eff.start_turn
		return util.bound(360 - d / eff.possible_end_turns * 360, 0, 360)
	end,
	lists = 'break_with_step_up',
	activate = function(self, eff)
		eff.start_turn = game.turn
		eff.possible_end_turns = 10 * (eff.dur+1)
		eff.tmpid = self:addTemporaryValue("wild_speed", 1)
		eff.moveid = self:addTemporaryValue("movement_speed", eff.power/100)
		if self.ai_state then eff.aiid = self:addTemporaryValue("ai_state", {no_talents=1}) end -- Make AI not use talents while using it
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("wild_speed", eff.tmpid)
		if eff.aiid then self:removeTemporaryValue("ai_state", eff.aiid) end
		self:removeTemporaryValue("movement_speed", eff.moveid)
	end,
}

newEffect{
	name = "SUSPEND_DET", image = "talents/suspend.png",
	desc = _t"Suspend",
	long_desc = function(self, eff) return _t"The target is removed from the normal time stream, unable to act but unable to take any damage. Each turn, beneficial effects decrease in duration." end,
	type = "other",
	subtype = { temporal=true },
	status = "detrimental",
	tick_on_timeless = true,
	parameters = {},
	on_gain = function(self, err) return _t"#Target# is removed from time!", _t"+Suspend" end,
	on_lose = function(self, err) return _t"#Target# is returned to normal time.", _t"-Suspend" end,
	activate = function(self, eff)
		eff.iid = self:addTemporaryValue("invulnerable", 1)
		eff.sid = self:addTemporaryValue("time_prison", 1)
		eff.tid = self:addTemporaryValue("no_timeflow", 1)
		eff.imid = self:addTemporaryValue("status_effect_immune", 1)
		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="arcanegeneric"}, {type="circular_flames", ellipsoidalFactor={1,2}, time_factor=3000, noup=2.0}))
			eff.particle1.toback = true
			eff.particle2 = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="arcanegeneric"}, {type="circular_flames", ellipsoidalFactor={1,2}, time_factor=3000, noup=1.0}))
		else
			eff.particle1 = self:addParticles(Particles.new("time_prison", 1))
		end
		self.energy.value = 0
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.iid)
		self:removeTemporaryValue("time_prison", eff.sid)
		self:removeTemporaryValue("no_timeflow", eff.tid)
		self:removeTemporaryValue("status_effect_immune", eff.imid)
		if eff.particle1 then self:removeParticles(eff.particle1) end
		if eff.particle2 then self:removeParticles(eff.particle2) end

			local todel = {}
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if not e.tick_on_timeless then
					if e.status == "beneficial" then
						p.dur = p.dur - eff.power
						if p.dur <= 0 then todel[#todel+1] = eff_id end
					end
				end
			end
			while #todel > 0 do
				self:removeEffect(table.remove(todel))
			end
	end,
}


newEffect{
	name = "SUSPEND_BEN", image = "talents/suspend.png",
	desc = _t"Suspend",
	long_desc = function(self, eff) return _t"The target is removed from the normal time stream, unable to act but unable to take any damage. Each turn, negative effects and cooldowns will decrease in duration." end,
	type = "other",
	subtype = { temporal=true },
	status = "detrimental",
	tick_on_timeless = true,
	parameters = { },
	on_gain = function(self, err) return _t"#Target# is removed from time!", _t"+Suspend" end,
	on_lose = function(self, err) return _t"#Target# is returned to normal time.", _t"-Suspend" end,
	activate = function(self, eff)
		eff.iid = self:addTemporaryValue("invulnerable", 1)
		eff.sid = self:addTemporaryValue("time_prison", 1)
		eff.tid = self:addTemporaryValue("no_timeflow", 1)
		eff.imid = self:addTemporaryValue("status_effect_immune", 1)
		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="arcanegeneric"}, {type="circular_flames", ellipsoidalFactor={1,2}, time_factor=3000, noup=2.0}))
			eff.particle1.toback = true
			eff.particle2 = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="arcanegeneric"}, {type="circular_flames", ellipsoidalFactor={1,2}, time_factor=3000, noup=1.0}))
		else
			eff.particle1 = self:addParticles(Particles.new("time_prison", 1))
		end
		self.energy.value = 0
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.iid)
		self:removeTemporaryValue("time_prison", eff.sid)
		self:removeTemporaryValue("no_timeflow", eff.tid)
		self:removeTemporaryValue("status_effect_immune", eff.imid)
		if eff.particle1 then self:removeParticles(eff.particle1) end
		if eff.particle2 then self:removeParticles(eff.particle2) end

		local todel = {}
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if not e.tick_on_timeless then
				if e.status == "detrimental" and e.type ~= "other" then
					p.dur = p.dur - eff.power
					if p.dur <= 0 then todel[#todel+1] = eff_id end
				end
			end
		end
		while #todel > 0 do
			self:removeEffect(table.remove(todel))
		end

		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and self.talents_cd[tid] then tids[#tids+1] = t end
		end

		while #tids > 0 do
			local tt = rng.tableRemove(tids)
			if not tt then break end
			self.talents_cd[tt.id] = self.talents_cd[tt.id] - eff.power
			if self.talents_cd[tt.id] <= 0 then self.talents_cd[tt.id] = nil end				
		end
		self.energy.value = 1000 -- guarantee the caster's turn comes up first or at least very soon
	end,
}

newEffect{
	name = "JINX", image = "talents/jinxed_touch.png",
	desc = _t"Jinxed",
	long_desc = function(self, eff)
		local desc = _t"The target has %d reduced saves and defense, and %d%% reduced critical chance.\nThis effect will fade in 2 turns if the source is not in line of sight."
		if eff.stacks > 6 and eff.fail then desc = _t"The target has %d reduced saves and defense, %d%% reduced critical chance, and %d%% chance to fail talent use.\nThis effect will fade in 2 turns if the source is not in line of sight." end
		return desc:tformat(eff.power * eff.stacks, eff.crit * eff.stacks, (eff.stacks - 6) * eff.fail)
	end,
	type = "other",
	no_stop_enter_worlmap = true,
	display_desc = function(self, eff) return ("%d Jinx"):tformat(eff.stacks) end,
	charges = function(self, eff) return eff.stacks or 1 end,
	subtype = { temporal=true },
	status = "detrimental",
	parameters = {power=1, crit=1, fail=0, stacks=1, max_stacks=8 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		
		local stackCount = old_eff.stacks + new_eff.stacks
		if stackCount >= old_eff.max_stacks then 
			stackCount = old_eff.max_stacks
		end

		self:removeTemporaryValue("combat_def", old_eff.def)		
		self:removeTemporaryValue("combat_mentalresist", old_eff.mental)
		self:removeTemporaryValue("combat_spellresist", old_eff.spell)
		self:removeTemporaryValue("combat_physresist", old_eff.physical)
		self:removeTemporaryValue("combat_physcrit", old_eff.pcritid)
		self:removeTemporaryValue("combat_spellcrit", old_eff.scritid)
		self:removeTemporaryValue("combat_mindcrit", old_eff.mcritid)
		
		if old_eff.failid then self:removeTemporaryValue("talent_fail_chance", old_eff.failid) end

		old_eff.def = self:addTemporaryValue("combat_def", -old_eff.power*stackCount)		
		old_eff.mental = self:addTemporaryValue("combat_mentalresist", -old_eff.power*stackCount)
		old_eff.spell = self:addTemporaryValue("combat_spellresist", -old_eff.power*stackCount)
		old_eff.physical = self:addTemporaryValue("combat_physresist", -old_eff.power*stackCount)
		old_eff.pcritid = self:addTemporaryValue("combat_physcrit", -old_eff.crit*stackCount)
		old_eff.scritid = self:addTemporaryValue("combat_spellcrit", -old_eff.crit*stackCount)
		old_eff.mcritid = self:addTemporaryValue("combat_mindcrit", -old_eff.crit*stackCount)
		
		if old_eff.fail > 0 and stackCount > 6 then
			old_eff.failid = self:addTemporaryValue("talent_fail_chance", old_eff.fail*(stackCount - 6))
		end		
		
		old_eff.stacks = stackCount
		
		return old_eff
		
	end,
	activate = function(self, eff)
		eff.def = self:addTemporaryValue("combat_def", -eff.power*eff.stacks)			
		eff.mental = self:addTemporaryValue("combat_mentalresist", -eff.power*eff.stacks )
		eff.spell = self:addTemporaryValue("combat_spellresist", -eff.power*eff.stacks)
		eff.physical = self:addTemporaryValue("combat_physresist", -eff.power*eff.stacks)
		eff.pcritid = self:addTemporaryValue("combat_physcrit", -eff.crit*eff.stacks)
		eff.scritid = self:addTemporaryValue("combat_spellcrit", -eff.crit*eff.stacks)
		eff.mcritid = self:addTemporaryValue("combat_mindcrit", -eff.crit*eff.stacks)
		if eff.fail > 0 and eff.stacks > 6 then
			eff.failid = self:addTemporaryValue("talent_fail_chance", eff.fail*(eff.stacks - 6))
		end

		local hx, hy = self:attachementSpot("shoulder1", true) hx, hy = hx or 0, hy or 0
		self:effectParticles(eff, {type="circle", args={x=hx, y=hy, oversize=1.1, base_rot=0, a=220, shader=true, appear=8, img="cultist_jinxed_debuff", speed=0, radius=0}})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.def)	
		self:removeTemporaryValue("combat_mentalresist", eff.mental)
		self:removeTemporaryValue("combat_spellresist", eff.spell)
		self:removeTemporaryValue("combat_physresist", eff.physical)
		self:removeTemporaryValue("combat_physcrit", eff.pcritid)
		self:removeTemporaryValue("combat_spellcrit", eff.scritid)
		self:removeTemporaryValue("combat_mindcrit", eff.mcritid)
		if eff.failid then self:removeTemporaryValue("talent_fail_chance", eff.failid) end
	end,
	on_timeout = function(self, eff)
		-- Remove the entire effect independent of stacks if LOS is broken for more than 2 turns
		if eff.src.x and not self:hasLOS(eff.src.x, eff.src.y) then
			eff.fading = eff.fading or 0
			eff.fading = eff.fading + 1
			if eff.fading >= 2 then self:removeEffect(self.EFF_JINX) end
		else
			eff.fading = nil
		end
	end,
}

newEffect{
	name = "FORTUNE", image = "talents/lucky_day.png",
	desc = _t"Fortune",
	--long_desc = function(self, eff) return ("The target has %d increased saves and defense, and %d%% increased critical chance."):tformat(eff.power * eff.stacks, eff.crit * eff.stacks) end,
	long_desc = function(self, eff)
		local desc = _t"The target has %d increased saves and defense, and %d%% increased critical chance."
		if eff.stacks > 6 and eff.avoid then desc = _t"The target has %d increased saves and defense, %d%% increased critical chance, and %d%% chance to avoid all damage." end
		return desc:tformat(eff.power * eff.stacks, eff.crit * eff.stacks, (eff.stacks - 6) * eff.avoid)
	end,	
	type = "other",
	display_desc = function(self, eff) return ("%d Jinx"):tformat(eff.stacks) end,
	charges = function(self, eff) return eff.stacks or 1 end,
	subtype = { temporal=true },
	status = "beneficial",
	parameters = {power=1, crit=1, stacks=1, max_stacks=8 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		
		local stackCount = old_eff.stacks + new_eff.stacks
		if stackCount >= old_eff.max_stacks then 
			stackCount = old_eff.max_stacks
		end

		self:removeTemporaryValue("combat_def", old_eff.def)		
		self:removeTemporaryValue("combat_mentalresist", old_eff.mental)
		self:removeTemporaryValue("combat_spellresist", old_eff.spell)
		self:removeTemporaryValue("combat_physresist", old_eff.physical)
		self:removeTemporaryValue("combat_physcrit", old_eff.pcritid)
		self:removeTemporaryValue("combat_spellcrit", old_eff.scritid)
		self:removeTemporaryValue("combat_mindcrit", old_eff.mcritid)
		
		if old_eff.failid then self:removeTemporaryValue("cancel_damage_chance", old_eff.failid) end

		old_eff.def = self:addTemporaryValue("combat_def", old_eff.power*stackCount)		
		old_eff.mental = self:addTemporaryValue("combat_mentalresist", old_eff.power*stackCount)
		old_eff.spell = self:addTemporaryValue("combat_spellresist", old_eff.power*stackCount)
		old_eff.physical = self:addTemporaryValue("combat_physresist", old_eff.power*stackCount)
		old_eff.pcritid = self:addTemporaryValue("combat_physcrit", old_eff.crit*stackCount)
		old_eff.scritid = self:addTemporaryValue("combat_spellcrit", old_eff.crit*stackCount)
		old_eff.mcritid = self:addTemporaryValue("combat_mindcrit", old_eff.crit*stackCount)
		
		if old_eff.avoid > 0 and stackCount > 6 then
			old_eff.failid = self:addTemporaryValue("cancel_damage_chance", old_eff.avoid*(stackCount - 6))
		end		
		
		old_eff.stacks = stackCount
		
		return old_eff
		
	end,
	activate = function(self, eff)
		eff.def = self:addTemporaryValue("combat_def", -eff.power*eff.stacks)			
		eff.mental = self:addTemporaryValue("combat_mentalresist", -eff.power*eff.stacks )
		eff.spell = self:addTemporaryValue("combat_spellresist", -eff.power*eff.stacks)
		eff.physical = self:addTemporaryValue("combat_physresist", -eff.power*eff.stacks)
		eff.pcritid = self:addTemporaryValue("combat_physcrit", eff.crit*eff.stacks)
		eff.scritid = self:addTemporaryValue("combat_spellcrit", eff.crit*eff.stacks)
		eff.mcritid = self:addTemporaryValue("combat_mindcrit", eff.crit*eff.stacks)
		if eff.avoid > 0 and eff.stacks > 6 then
			eff.failid = self:addTemporaryValue("cancel_damage_chance", eff.avoid*(eff.stacks - 6))
		end

		local hx, hy = self:attachementSpot("head", true) hx, hy = hx or 0, hy or 0
		self:effectParticles(eff, {type="circle", args={x=hx, y=hy, oversize=1.1, base_rot=0, a=220, shader=true, appear=8, img="cultist_luckdrinker_buff", speed=0, radius=0}})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.def)	
		self:removeTemporaryValue("combat_mentalresist", eff.mental)
		self:removeTemporaryValue("combat_spellresist", eff.spell)
		self:removeTemporaryValue("combat_physresist", eff.physical)
		self:removeTemporaryValue("combat_physcrit", eff.pcritid)
		self:removeTemporaryValue("combat_spellcrit", eff.scritid)
		self:removeTemporaryValue("combat_mindcrit", eff.mcritid)
		if eff.failid then self:removeTemporaryValue("cancel_damage_chance", eff.failid) end
	end,
}

newEffect{
	name = "UNRAVEL_EXISTENCE", image = "talents/unravel_existence.png",
	desc = _t"Unravelling",
	long_desc = function(self, eff) return ("The target is being erased from reality. Each time a magical effect is applied, they will take %0.2f darkness damage and %0.2f temporal damage. If 5 effects are applied, a powerful void horror will appear."):tformat(eff.power, eff.power) end,
	type = "magical",
	subtype = { temporal=true, darkness=true },
	status = "detrimental",
	parameters = { power=10, nb=0, dur=5 },
	on_gain = function(self, err) return _t"#Target# is being erased from reality!" end,
	on_lose = function(self, err) return _t"#Target# has survived the unraveling." end,
	callbackOnTemporaryEffect = function(self, eff, eff_id, e, p)

		if e.type == "magical" and e.status == "detrimental" then
			DamageType:get(DamageType.DARKNESS).projector(eff.src, self.x, self.y, DamageType.DARKNESS, eff.power)
			DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, eff.power)
			eff.nb = eff.nb + 1
			if eff.nb >= 5 then
				local t = eff.src:getTalentFromId(eff.src.T_UNRAVEL_EXISTENCE)
				t.unravel(eff.src, self, t, eff.dur)
				game.logSeen(self, "#LIGHT_RED#A void annihilator manifests from %s!", self:getName():capitalize())				
				self:removeEffect(self.EFF_UNRAVEL_EXISTENCE)
			end
		end	
		
		return true
	end,
	on_die = function(self, eff)
		local t = eff.src:getTalentFromId(eff.src.T_UNRAVEL_EXISTENCE)
		t.unravel(eff.src, self, t, eff.dur)
		game.logSeen(self, "#LIGHT_RED#A void annihilator manifests from %s!", self:getName():capitalize())				
		self:removeEffect(self.EFF_UNRAVEL_EXISTENCE)
	end,
}

newEffect{
	name = "FATEBREAKER", image = "talents/fatebreaker.png",
	desc = _t"Fatebreaker",
	long_desc = function(self, eff) return ("The target has tied itself to the fate of another. If it dies, it's chosen target will die in it's place and it will be healed by %d for each stack of Fortune and Jinx."):tformat(eff.power) end,
	type = "magical",
	subtype = { temporal=true, darkness=true },
	status = "beneficial",
	parameters = { power=10, target, },
	on_gain = function(self, err) return _t"#Target# intertwines it's fate!" end,
	on_lose = function(self, err) return _t"#Target#'s fate is no longer linked to another." end,
	callbackOnHit = function(self, eff, cb, src)
		if cb.value >= (self.life - self.die_at) then
			local target = game.level.map(eff.target.x, eff.target.y, Map.ACTOR)
			if not target then return end
			heal = 0
			if self:hasEffect(self.EFF_FORTUNE) then
				local eff2 = self:hasEffect(self.EFF_FORTUNE)
				heal = eff.power * eff2.stacks
				self:removeEffect(self.EFF_FORTUNE)
			end
			if target:hasEffect(target.EFF_JINX) then
				local eff2 = target:hasEffect(target.EFF_JINX)
				heal = eff.power * eff2.stacks
				target:removeEffect(target.EFF_JINX)
			end			
			if heal > 0 then
				self:heal(heal, self)
			end
			DamageType:get(DamageType.VOID).projector(self or eff.src, eff.target.x, eff.target.y, DamageType.VOID, cb.value)
			target:check("on_fatebreaker_call", self)
			cb.value = 0
			self:removeEffect(self.EFF_FATEBREAKER)
			self:setEffect(self.EFF_FATEBREAKER_TEMP, 1, {src=self, target=eff.target})
		end
		return cb.value
	end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("fatebreaker", 1, {tx=eff.src.x-self.x, ty=eff.src.y-self.y}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
	on_timeout = function(self, eff)
		local target = eff.target or self
		if core.fov.distance(self.x, self.y, target.x, target.y) >= 20 or target.dead or not game.level:hasEntity(target) then return true end

		self:removeParticles(eff.particle)
		eff.particle = self:addParticles(Particles.new("fatebreaker", 1, {tx=eff.target.x-self.x, ty=eff.target.y-self.y}))
	end,
}

newEffect{
	name = "FATEBREAKER_TEMP", image = "talents/fatebreaker.png",
	desc = _t"Fatebreaker",
	long_desc = function(self, eff) return ("Redirecting all damage as temporal and darkness to %s."):tformat(eff.target:getName()) end,
	type = "other",
	subtype = { temporal=true, darkness=true },
	status = "beneficial",
	parameters = { power=100, target, },
	callbackOnHit = function(self, eff, cb, src)
		local target = game.level.map(eff.target.x, eff.target.y, Map.ACTOR)
		if not target then return end
		if self._fakebreaking_temp then return cb.value end
		self._fakebreaking_temp = true
		DamageType:get(DamageType.VOID).projector(self or eff.src, eff.target.x, eff.target.y, DamageType.VOID, cb.value)
		self._fakebreaking_temp = nil
		cb.value = 0
		return cb.value
	end,
}

newEffect{
	name = "DECAYING_GROUND", image = "talents/decaying_grounds.png",
	desc = _t"Decaying Ground",
	long_desc = function(self, eff) return ("All cooldowns increased by %d%%."):tformat(eff.power * 100) end,
	type = "magical",
	subtype = { blight=true, corrupted=true },
	status = "detrimental",
	on_gain = function(self, err) return _t"#Target# is caught in decaying ground.", true end,
	on_lose = function(self, err) return _t"#Target# is free from the decaying ground.", true end,
	parameters = { power=10 },
	activate = function(self, eff)
	end,
}

newEffect{
	name = "CRIPPLING_DISEASE", image = "talents/maggot_breath.png",
	desc = _t"Crippling Disease",
	long_desc = function(self, eff) return ("The target is infected by a disease, reducing its speed by %d%% and doing %0.2f blight damage per turn."):tformat(eff.speed*100, eff.dam) end,
	type = "magical",
	subtype = {slow=true, disease=true, blight=true},
	status = "detrimental",
	parameters = {speed = 0.1, dam = 0},
	on_gain = function(self, err) return _t"#Target# is afflicted by a crippling disease!", true end,
	on_lose = function(self, err) return _t"#Target# is free from the crippling disease.", true end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam, eff.src)
		else if eff.dam > 0 then DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end end
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.speed)
		--self:effectTemporaryValue(eff, "global_speed_add", -eff.speed)  Using addTemporaryValue for now to avoid a serious bug with Cyst Burst
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "DEFILED_BLOOD", image = "talents/defiled_blood.png",
	desc = _t"Defiled Blood",
	long_desc = function(self, eff) return ("Covered in defiled blood, healing the source for %d%% of all damage done."):tformat(eff.power) end,
	type = "magical",
	subtype = {blood=true, leech=true},
	status = "detrimental",
	parameters = {power=10},
	on_gain = function(self, err) return _t"#Target# is covered in black blood!", true end,
	on_lose = function(self, err) return _t"#Target# is clear from the black blood.", true end,
}


newEffect{
	name = "TELEPORT_KROSHKKUR", image = "talents/teleport_kroshkkur.png",
	desc = _t"Teleport: Kroshkkur",
	long_desc = function(self, eff) return _t"The target is waiting to be recalled back to Kroshkkur." end,
	type = "magical",
	subtype = { teleport=true },
	status = "beneficial",
	cancel_on_level_change = true,
	parameters = { },
	activate = function(self, eff)
		eff.leveid = game.zone.short_name.."-"..game.level.level
	end,
	deactivate = function(self, eff)
		if game.state.cults_kroshkkur_destroyed then game.log("#CRIMSON#Kroshkkur is destroyed, there is nothing to teleport to.") return end
		if self ~= game:getPlayer(true) then return end
		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then 
				if actor.summoner and actor.summoner == self then
					seen = false
				else
					seen = true
				end
			end
		end, nil)
		if seen then
			game.log("There are creatures that could be watching you; you cannot take the risk of teleporting to Kroshkkur.")
			return
		end

		if self:canBe("worldport") and not self:attr("never_move") and eff.dur <= 0 then
			game:onTickEnd(function()
				if eff.leveid == game.zone.short_name.."-"..game.level.level and game.player.can_change_zone then
					game.logPlayer(self, "You are yanked out of this place!")
					game:changeLevel(1, "cults+town-kroshkkur")
				end
			end)
		else
			game.logPlayer(self, "Space restabilizes around you.")
		end
	end,
}

newEffect{
	name = "CULTS_BOOK_TIMEOUT", image = "shockbolt/object/artifact/forbidden_tome_home.png",
	desc = _t"Forbidden Tome",
	long_desc = function(self, eff) return _t"Slowly transfered to a Forbidden Tome." end,
	type = "magical",
	subtype = {book=true},
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return _t"#Target# is entering a Forbidden Tome!", true end,
	on_lose = function(self, err) return _t"#Target# enters a Forbidden Tome!", true end,
	activate = function(self, eff)
		eff.leveid = game.zone.short_name.."-"..game.level.level
	end,
	deactivate = function(self, eff)
		if eff.dur > 0 or eff.forbid then return end
		if self ~= game:getPlayer(true) then return end
		game:onTickEnd(function()
			if eff.leveid == game.zone.short_name.."-"..game.level.level and game.player.can_change_zone then
				Cults.handleBookTransition(eff.tome, self)
			end
		end)
	end,
}

newEffect{
	name = "CULTS_BOOK_HOME_TIMEOUT", image = "shockbolt/object/spellbook.png",
	desc = _t"Forbidden Tome",
	long_desc = function(self, eff) return ("Inside Forbidden Tome: \"Home, Horrific Home\" for %d turns."):tformat(eff.dur) end,
	type = "other",
	subtype = {book=true},
	status = "detrimental",
	no_stop_enter_worlmap = true,
	parameters = {},
	callbackOnChangeLevel = function(self, eff, mode)
		if mode == "leave" then
			eff.ignore = true
			game:onTickEnd(function() self:removeEffect(self.EFF_CULTS_BOOK_HOME_TIMEOUT, true, true) end)
		end
	end,
	deactivate = function(self, eff)
		game:onTickEnd(function()
			if game.zone and game.zone.short_name == "cults+ft-home" then
				game:changeLevelReal(1, "useless", {temporary_zone_shift_back=true})
			end
		end)
	end,
}

newEffect{
	name = "CULTS_BOOK_COOLDOWN", image = "shockbolt/object/artifact/forbidden_tome_home.png",
	desc = _t"Forbidden Tome Cooldown",
	long_desc = function(self, eff) return _t"Unable to enter Forbidden Tomes." end,
	type = "other",
	no_stop_enter_worlmap = true,
	subtype = {book=true},
	status = "detrimental",
	parameters = {},
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "KROG_WRATH", image = "talents/krog_wrath.png",
	desc = _t"Wrath of the Wilds",
	long_desc = function(self, eff) return ("%d%% chance to stun any foes hit."):tformat(eff.power) end,
	type = "mental",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { power=10 },
	callbackOnDealDamage = function(self, eff, value, target, dead, death_node)
		if dead then return end
		if value <= 0 then return end
		if not target:canBe("stun") then return end
		if self.turn_procs.krog_wrath and not rng.percent(eff.power) then return end
		self.turn_procs.krog_wrath = self.turn_procs.krog_wrath or {}
		if self.turn_procs.krog_wrath[target.uid] then return end
		self.turn_procs.krog_wrath[target.uid] = true
		target:setEffect(target.EFF_STUNNED, 3, {apply_power=math.max(self:combatMindpower(), self:combatPhysicalpower())})
	end,
	activate = function(self, eff)
		local hx, hy = self:attachementSpot("head", true) hx, hy = hx or 0, hy or 0
		self:effectParticles(eff, {type="circle", args={x=hx, y=hy, oversize=1, base_rot=0, a=220, shader=true, appear=12, img="krog_wotw_aura", speed=0, radius=0}})
	end,
}

newEffect{
	name = "WARBORN", image = "talents/warborn.png",
	desc = _t"Warborn",
	long_desc = function(self, eff) return ("Reduces all damage taken by %d%%."):tformat(eff.power) end,
	type = "physical",
	subtype = { protection=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {all=eff.power})
		if self.moddable_tile and not Map.tiles.no_moddable_tiles then
			local img = "shockbolt/player/ogre_male/krog_male_warborn"
			if self.female then img = "shockbolt/player/ogre_female/krog_female_warborn" end
			self:effectParticles(eff, {type="image", args={size=128, y=-32, image=img}})
		end
	end,
}

newEffect{
	name = "HYPOSTASIS_AWAKEN", image = "talents/horrific_display.png",
	desc = _t"Awoken",
	long_desc = function(self, eff) return ("True power is revealed!\n\nAll debuffs removed and all talent cooldowns reset on application.\n\nEach turn a radius 2 explosion will occur in a random space dealing %0.2f darkness and temporal damage and destroying any diggable walls."):tformat(self:getStat("mag") * 5 / 2) end,
	type = "other",
	subtype = { opness=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		for e, _ in pairs(self.__particles) do if e.def == "hypostasis_entropy" then self:removeParticles(e) break end end
		self:addParticles(Particles.new("hypostasis_entropy", 1, {awoke=true}))

		self:removeEffectsFilter(self, function(eff)
				if eff.status == "detrimental" and eff.type ~= "other" then return true end
			end)
		self.talents_cd = {}
	end,
	on_timeout = function(self, eff)
		local tx, ty = self:getTarget()
		if not tx then return end

		local list = {}
		self:project({type="ball", range=10, radius=3}, tx, ty, function(px, py) list[#list+1] = {x=px, y=py} end)
		if #list == 0 then return end

		local spot = rng.table(list)
		if not spot or not spot.x then return end
		self:project({type="ball", x=spot.x, y=spot.y, radius=2, selffire=false, friendlyfire=false}, spot.x, spot.y, DamageType.VOID, self:getStat("mag") * 5)
		self:project({type="ball", x=spot.x, y=spot.y, radius=2}, spot.x, spot.y, DamageType.DIG, 1)

		game.level.map:particleEmitter(spot.x, spot.y, 2, "generic_sploom", {rm=50, rM=80, gm=120, gM=160, bm=180, bM=200, am=80, aM=150, radius=2, basenb=120})

		game:playSoundNear(self, "talents/arcane")
	end,
	deactivate = function(self, eff)
		for e, _ in pairs(self.__particles) do if e.def == "hypostasis_entropy" then self:removeParticles(e) break end end
		self:addParticles(Particles.new("hypostasis_entropy", 1, {}))
	end,
}

newEffect{
	name = "TOTAL_COLLAPSE", image = "talents/horrific_display.png",
	desc = _t"Total Collapse",
	long_desc = function(self, eff) return ("Your body can not function properly here, it is slowly wasting away. Each turn you take %0.2f void damage and any new debuff on you lasts %d%% longer. Each turn those penalties increase until the effect is removed."):tformat(eff.dam, eff.debuffdur) end,
	type = "other",
	subtype = { entropy=true },
	status = "detrimental",
	no_stop_enter_worlmap = true,
	decrease = 0, no_remove = true,
	zone_wide_effect = true,
	charges = function(self, eff) return eff.stacks end,
	parameters = { dam=10, debuffdur=10, stacks=1 },
	on_timeout = function(self, eff, e)
		DamageType:get(DamageType.VOID).projector(eff.src or self, self.x, self.y, DamageType.VOID, eff.dam)

		eff.dam = math.ceil((eff.dam + 10) * 1.35)
		eff.debuffdur = math.ceil((eff.debuffdur + 5) * 1.05)
		eff.stacks = eff.stacks + 1
	end,
	callbackOnTemporaryEffect = function(self, eff, eff_id, e, p)
		if e.status ~= "detrimental" then return end
		if e.type == "other" then return end
		p.dur = p.dur + math.ceil(p.dur * eff.debuffdur / 100)
	end,
}

newEffect{
	name = "SAVE_KROSHKKUR", image = "talents/teleport_kroshkkur.png",
	desc = _t"Save Kroshkkur",
	long_desc = function(self, eff) return ("Kroshkkur is still under threat from %s."):tformat(eff.threat) end,
	type = "other",
	subtype = { threat=true },
	status = "neutral",
	parameters = { },
	deactivate = function(self, eff)
		if eff.dur > 0 then return end
		game.bignews:say(120, "#CRIMSON#You waited too long, Kroshkkur has been destroyed by %s!", eff.threat)
		game.state.cults_kroshkkur_destroyed = true
		self:setQuestStatus(eff.quest, engine.Quest.FAILED)
	end,
	on_merge = function(self, old_eff, new_eff, e)
		return old_eff
	end,
}

newEffect{
	name = "GASTRIC_WAVE_BUFF", image = "effects/gastric_wave.png",
	desc = _t"Covered in Gastric Fluids",
	long_desc = function(self, eff) return ("Reduces all damage taken by %d%% and remove all detrimental effects on application."):tformat(eff.power) end,
	type = "magical",
	subtype = { protection=true },
	status = "beneficial",
	parameters = { power=70 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {all=eff.power})
		self:removeEffectsFilter(self, {status="detrimental"}, 999)
	end,
}

newEffect{
	name = "GASTRIC_WAVE_DEBUFF", image = "effects/gastric_wave.png",
	desc = _t"Covered in Gastric Fluids",
	long_desc = function(self, eff) return ("Reduces all damage done by %d%% and increase all detrimental effects durations by 6 turns on application."):tformat(eff.power) end,
	type = "magical",
	subtype = { debilitate=true },
	status = "detrimental",
	parameters = { power=45 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_damage", {all=-eff.power})
		for _, eff_id in ipairs(self:effectsFilter({status="detrimental"}, 999)) do if eff_id ~= self.EFF_GASTRIC_WAVE_DEBUFF then
			local p = self:hasEffect(eff_id)
			if p and p.dur then p.dur = p.dur + 6 end
		end end
	end,
}

newEffect{
	name = "GODFEASTER_EVENT_BLINDED", image = "effects/blinded.png",
	desc = _t"Blinded",
	long_desc = function(self, eff) return _t"The target is blinded, unable to see anything." end,
	type = "other",
	subtype = { blind=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return _t"#Target# loses sight!", _t"+Blind" end,
	on_lose = function(self, err) return _t"#Target# recovers sight.", _t"-Blind" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("blind", 1)
		if game.level then
			self:resetCanSeeCache()
			if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("blind", eff.tmpid)
		if game.level then
			self:resetCanSeeCache()
			if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
		end
	end,
}

newEffect{
	name = "ILLUSORY_CASTLE_MADNESS",
	desc = _t"Lost in a weird place",
	long_desc = function(self, eff) return ("The target is starting to get mad (%d stacks), reducing mind damage resistance by %d%%, mental save by %d, confusion resistance by %d%%, generating %0.1f insanity per turn."):tformat(eff.stacks, eff.stacks * 6, eff.stacks * 5, eff.stacks * 4, eff.stacks * 0.5) end,
	type = "other",
	status = "detrimental",
	subtype = { insanity=true, confusion=true, madness=true },
	no_stop_enter_worlmap = true,
	decrease = 0, no_remove = true,
	parameters = {},
	charges = function(self, eff) return eff.stacks end,
	updateEffect = function(self, old_eff, new_eff, e)
		if old_eff.resists then self:removeTemporaryValue("resists", old_eff.resists) end
		if old_eff.mental then self:removeTemporaryValue("combat_mentalresist", old_eff.mental) end
		if old_eff.confusion then self:removeTemporaryValue("confusion_immune", old_eff.confusion) end
		if old_eff.insanity then self:removeTemporaryValue("insanity_regen", old_eff.insanity) end
		if new_eff then
			new_eff.resists = self:addTemporaryValue("resists", {[DamageType.MIND]=-new_eff.stacks * 6})
			new_eff.mental = self:addTemporaryValue("combat_mentalresist", -new_eff.stacks * 5)
			new_eff.confusion = self:addTemporaryValue("confusion_immune", -new_eff.stacks * 0.04)
			new_eff.insanity = self:addTemporaryValue("insanity_regen", new_eff.stacks * 0.5)
		end
	end,
	on_merge = function(self, old_eff, new_eff, e)
		new_eff.levels = old_eff.levels
		new_eff.levels[game.level.level] = true
		new_eff.stacks = table.count(new_eff.levels)
		e.updateEffect(self, old_eff, new_eff, e)
		return new_eff
	end,
	activate = function(self, eff, e)
		eff.levels = { [game.level.level] = true }
		eff.stacks = 1
		e.updateEffect(self, eff, eff, e)
	end,
	deactivate = function(self, eff, e)
		e.updateEffect(self, eff, nil, e)
	end,
}

newEffect{
	name = "GLASS_SPLINTERS", image = "talents/glass_splinters.png",
	desc = _t"Glass Splinters",
	long_desc = function(self, eff) return ("Nasty glass splinters that make you bleed, doing %0.2f arcane damage per turn. Deals %0.2f arcane damage on move. Talents have %d%% chances to fail."):tformat(eff.bleed, eff.move, eff.fail) end,
	type = "magical",
	subtype = { wound=true, cut=true, bleed=true, fail=true },
	status = "detrimental",
	parameters = { bleed=1, move=1, fail=0 },
	on_gain = function(self, err) return _t"#Target# starts to bleed due to glass splinters.", true end,
	on_lose = function(self, err) return _t"#Target# stops bleeding.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "talent_fail_chance", eff.fail)
	end,
	callbackOnMove = function(self, eff, moved, force, ox, oy)
		if not moved or force or (self.x == ox and self.y == oy) then return end
		DamageType:get(DamageType.ARCANE).projector(eff.src or self, self.x, self.y, DamageType.ARCANE, eff.move)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.ARCANE).projector(eff.src or self, self.x, self.y, DamageType.ARCANE, eff.bleed)
	end,
}


newEffect{
	name = "PERSISTANT_WILL", image = "effects/persistent_will.png",
	desc = _t"Persistant Will",
	long_desc = function(self, eff) return ("Convinced that arcane users are filth to be destroyed."):tformat() end,
	type = "mental",
	subtype = { will=true, domination=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return _t"#PURPLE##Target# is convinced arcane users must be destroyed.", true end,
	on_lose = function(self, err) return _t"#Target# looks more kindly toward arcane users.", true end,
	on_timeout = function(self, eff)
		self:setTarget(nil)
	end,
	activate = function(self, eff)
		self:setTarget(nil)
		self:effectTemporaryValue(eff, "hates_arcane", 1)
	end,
	deactivate = function(self, eff)
		self:setTarget(nil)
	end,
}

-- These could use visuals and less boring descriptions and such
-- The pool of effects here is not terribly important, effects can be changed/rethemed as desired
newEffect{
	name = "TWISTED_SPEED", image = "talents/maggot_breath.png",
	desc = _t"Twisted Evolution: Speed",
	long_desc = function(self, eff) return ("The target is evolved increasing its global speed by %d%%."):tformat(eff.speed*100) end,
	type = "other",
	subtype = {speed=true},
	status = "beneficial",
	parameters = {speed = 0.1},
	on_gain = function(self, err) return _t"#Target# is evolved and acting faster!", true end,
	on_lose = function(self, err) return _t"#Target# is no longer evolved to move faster.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "global_speed_add", eff.speed)
	end,
}

newEffect{
	name = "TWISTED_FORM", image = "talents/maggot_breath.png",
	desc = _t"Twisted Evolution: Form",
	long_desc = function(self, eff) return ("The target is evolved increasing all its stats by %d."):tformat(eff.stat) end,
	type = "other",
	subtype = {},
	status = "beneficial",
	parameters = {stat = 1},
	on_gain = function(self, err) return _t"#Target#'s body is evolved!", true end,
	on_lose = function(self, err) return _t"#Target#'s body' is no longer evolved.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_stats", {
			[Stats.STAT_DEX] = eff.stat,
			[Stats.STAT_STR] = eff.stat,
			[Stats.STAT_CON] = eff.stat,
			[Stats.STAT_MAG] = eff.stat,
			[Stats.STAT_WIL] = eff.stat,
			[Stats.STAT_CUN] = eff.stat,			
		})
	end,
}

newEffect{
	name = "TWISTED_POWER", image = "talents/maggot_breath.png",
	desc = _t"Twisted Evolution: Power",
	long_desc = function(self, eff) return ("The target is evolved increasing its damage by %d%%."):tformat(eff.dam) end,
	type = "other",
	subtype = {},
	status = "beneficial",
	parameters = {dam = 1},
	on_gain = function(self, err) return _t"#Target# is evolved to deal more damage!", true end,
	on_lose = function(self, err) return _t"#Target# is no longer evolved to deal more damage.", true end,

	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_damage", {all = eff.dam})
	end,
}

newEffect{
	name = "SHOES_SLOWLY",
	desc = _t"Shoes of Moving Slowly",
	long_desc = function(self, eff) return ("Stay put, increasing your armour and defense by %d."):tformat(eff.stacks * 2) end,
	type = "magical",
	status = "beneficial",
	subtype = { speed=true },
	parameters = {},
	charges = function(self, eff) return eff.stacks end,
	updateEffect = function(self, old_eff, new_eff, e)
		if old_eff then
			self:removeTemporaryValue("combat_armor", old_eff.combat_armor)
			self:removeTemporaryValue("combat_def", old_eff.combat_def)
		end
		if new_eff then
			new_eff.combat_armor = self:addTemporaryValue("combat_armor", new_eff.stacks * 2)
			new_eff.combat_def = self:addTemporaryValue("combat_def", new_eff.stacks * 2)
		end
	end,
	on_merge = function(self, old_eff, new_eff, e)
		new_eff.stacks = math.min(old_eff.stacks + 1, 12)
		e.updateEffect(self, old_eff, new_eff, e)
		return new_eff
	end,
	activate = function(self, eff, e)
		eff.stacks = 1
		e.updateEffect(self, nil, eff, e)
	end,
	deactivate = function(self, eff, e)
		e.updateEffect(self, eff, nil, e)
	end,
	callbackOnMove = function(self, eff, moved, force, ox, oy)
		if not moved or (ox == self.x and oy == self.y) then return end -- Even forced move remove it
		game:onTickEnd(function() self:removeEffect(self.EFF_SHOES_SLOWLY) end)
	end,
}

newEffect{
	name = "ENTROPIC_ROD", image = "talents/entropic_gift.png",
	desc = _t"Entropic Feedback",
	long_desc = function(self, eff) return ("The target healing is distorted by entropy for %d%% of the healing done over 8 turns."):tformat(eff.power) end,
	type = "magical",
	subtype = {},
	status = "detrimental",
	parameters = {power = 100},
	on_gain = function(self, err) return _t"#Target# is enveloped with entropic forces!", true end,
	on_lose = function(self, err) return _t"#Target# is no longer enveloped by entropic forces.", true end,
	callbackPriorities={callbackOnHeal = 1}, -- trigger after (most) other healing callbacks
	callbackOnHeal = function(self, eff, value, src, raw_value)
		if raw_value > 0 and not eff.projecting and not self.resting and not self.reverse_entropy then -- avoid feedback; it's bad to lose out on dmg but it's worse to break the game
			eff.projecting = true
			local dam = math.floor(value / 8 * (eff.power / 100))
			local psrc = eff.src
			psrc.__project_source = t
			self:setEffect(self.EFF_ENTROPIC_WASTING, 8, {src=eff.src, power=dam})
			psrc.__project_source = nil
			eff.projecting = false
		end
	end,
}

newEffect{
	name = "HORRIFIC_FORTRESS", image = "talents/dwarf_resilience.png",
	desc = _t"Horrific Fortress",
	long_desc = function(self, eff) return ("All damages except physical reduced by %d as long as %s is alive."):tformat(eff.power, eff.src:getName()) end,
	type = "magical",
	subtype = {horror=true, armor=true},
	status = "beneficial", decrease = 0,
	parameters = {power = 10},
	on_gain = function(self, err) return _t"#Target# is bolstered at the sight of the horror!", true end,
	on_lose = function(self, err) return _t"#Target# is less armoured.", true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "flat_damage_armor", {all=eff.power, [DamageType.PHYSICAL]=-eff.power})
		self:effectTemporaryValue(eff, "stone_fortress_active", 1)
	end,
	on_timeout = function(self, eff)
		if not eff.src or not game.level or not game.level:hasEntity(eff.src) or eff.src:attr("dead") then
			return true
		end
	end,
}
