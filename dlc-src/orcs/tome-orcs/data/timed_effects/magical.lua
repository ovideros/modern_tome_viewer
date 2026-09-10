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
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

-- used by Viral Injector in chemistry.lua
newEffect{
	name = "TINKER_VIRAL", image = "talents/rotting_disease.png",
	desc = _t"Viral Injection",
	long_desc = function(self, eff) return ("The target is infected by a disease, reducing its highest %d stats by %d and doing %0.2f blight damage per turn."):tformat(eff.num_stats, eff.power, eff.dam) end,
	type = "magical",
	subtype = {disease=true, blight=true},
	status = "detrimental",
	parameters = {num_stats = 1, dam = 1, power = 1},
	on_gain = function(self, err) return _t"#Target# is injected with a pathogen!" end,
	on_lose = function(self, err) return _t"#Target# is free from the pathogen." end,
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam, eff.src)
		else DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
	end,
	on_merge = function(self, old_eff, new_eff)
		-- recalculating which stats to lower seems like a terrible idea
		old_eff.dur = math.max(old_eff.dur, new_eff.dur)
		return old_eff
	end,
	activate = function(self, eff)
		local l = { {Stats.STAT_STR, self:getStat("str")}, {Stats.STAT_DEX, self:getStat("dex")}, {Stats.STAT_CON, self:getStat("con")}, {Stats.STAT_MAG, self:getStat("mag")}, {Stats.STAT_WIL, self:getStat("wil")}, {Stats.STAT_CUN, self:getStat("cun")}, }
		table.sort(l, function(a,b) return a[2] > b[2] end)
		local inc = {}
		for i = 1, eff.num_stats do inc[l[i][1]] = -eff.power end
		self:effectTemporaryValue(eff, "inc_stats", inc)
	end,
	deactivate = function(self, eff)
		
	end,
}

newEffect{
	name = "STEAM_SHIELD", image = "talents/barrier.png",
	desc = _t"Steam Shield",
	long_desc = function(self, eff) return ("The target is surrounded by a magical steam shield, absorbing %d/%d damage and burning attackers for %d fire damage before it crumbles."):tformat(self.damage_shield_absorb, eff.power, self:damDesc(DamageType.FIRE, eff.retaliate)) end,
	type = "magical",
	subtype = { arcane=true, shield=true },
	status = "beneficial",
	parameters = { power=100, retaliate=15, },
	on_gain = function(self, err) return _t"A shield forms around #target#.", _t"+Shield" end,
	on_lose = function(self, err) return _t"The shield around #target# crumbles.", _t"-Shield" end,
	on_aegis = function(self, eff, aegis)
		self.damage_shield_absorb = self.damage_shield_absorb + eff.power * aegis / 100
		if core.shader.active(4) then
			self:removeParticles(eff.particle)
			local bc = {0.4, 0.7, 1.0, 1.0}
			local ac = {0x21/255, 0x9f/255, 0xff/255, 1}
			if eff.color then
				bc = table.clone(eff.color) bc[4] = 1
				ac = table.clone(eff.color) ac[4] = 1
			end
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.3, img="runicshield"}, {type="runicshield", shieldIntensity=0.14, ellipsoidalFactor=1.2, time_factor=5000, bubbleColor=bc, auraColor=ac}))
		end		
	end,
	damage_feedback = function(self, eff, src, value)
		if eff.particle and eff.particle._shader and eff.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			eff.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			eff.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "on_melee_hit", {[DamageType.FIRE]=eff.retaliate})
		eff.power = self:getShieldAmount(eff.power)
		eff.dur = self:getShieldDuration(eff.dur)
		eff.tmpid = self:addTemporaryValue("damage_shield", eff.power)
		if eff.reflect then eff.refid = self:addTemporaryValue("damage_shield_reflect", eff.reflect) end
		--- Warning there can be only one time shield active at once for an actor
		self.damage_shield_absorb = eff.power
		self.damage_shield_absorb_max = eff.power
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, nil, {type="shield", shieldIntensity=0.2, color=eff.color or {0.4, 0.7, 1.0}}))
		else
			eff.particle = self:addParticles(Particles.new("damage_shield", 1))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("damage_shield", eff.tmpid)
		if eff.refid then self:removeTemporaryValue("damage_shield_reflect", eff.refid) end
		self.damage_shield_absorb = nil
		self.damage_shield_absorb_max = nil
	end,
}


newEffect{
	name = "TWILIT_ECHOES", image="talents/twilight.png",
	desc = _t"Twilit Echoes",
	long_desc = function(self, eff) return ([[The target feels the echoes of all light and dark damage it takes. Light damage slows the target by %0.2f%% per point of damage dealt, up to a maximum of %d%% at %d damage. Dark damage creates an effect at the tile for %d turns which deals %d%% of the damage dealt each turn. It will be refreshed as long as the target continues taking damage from it or another source.]])
		:tformat(eff.slow_per * 100, eff.slow_max * 100, eff.slow_max / eff.slow_per, eff.echo_dur, eff.dam_factor * 100) end,
	type = "magical",
	subtype = { dark=true, light=true},
	status = "detrimental",
	doEcho = function(type, dam, eff, target, src, x, y)
		if type == DamageType.LIGHT then
			target:setEffect(target.EFF_ECHOED_LIGHT, eff.echo_dur, {power = dam * eff.slow_per, max = eff.slow_max})
		elseif type == DamageType.DARKNESS then --you can never be too sure
			local echo
			if eff.dark_echoes then for _, e in ipairs(eff.dark_echoes) do
				if e.duration > 0 and e.x == x and e.y == y then
					echo = e
				end
			end end
			if not echo then
				game.level.map:addEffect(src, 
					x, y, 4,
					DamageType.DARKNESS, dam * eff.dam_factor,
					0,
					5, nil,
					{type="shadow_zone"},
					nil, src:spellFriendlyFire()
				)
				--it's hacky yeah, but map:addEffect should really return the instance
				echo = game.level.map.effects[#game.level.map.effects]
				eff.dark_echoes = eff.dark_echoes or {}
				table.insert(eff.dark_echoes, echo)
			else
				if echo.duration < eff.echo_dur and echo.duration > 0 then
					old_dur = echo.duration
					old_dam = old_dur * echo.dam
					local new_dam = dam * eff.dam_factor * eff.echo_dur + old_dam
					echo.duration = eff.echo_dur
					echo.dam = new_dam / eff.echo_dur
				else
					
				end
			end
		end
	end,
}

newEffect{
	name = "ECHOED_LIGHT", image="talents/twilight.png",
	desc = _t"Echoed Light",
	long_desc = function(self, eff) return ([[The light damage the target has taken is echoed, slowing them by %d%%. Taking additional damage while Twilit Echoes is active will refresh and increase the slow up to a maximum of %d%%.]])
		:tformat(eff.power * 100, eff.max * 100) end,
	type = "magical",
	subtype = { slow=true},
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
	on_merge = function(self, old_eff, new_eff)
		max = math.max(old_eff.max, new_eff.max)
		old_eff.power = math.min(old_eff.power + new_eff.power, max)
		self:removeTemporaryValue("global_speed_add", old_eff.tmpid)
		old_eff.tmpid = self:addTemporaryValue("global_speed_add", -old_eff.power)
		return old_eff
	end,
}

newEffect{
	name = "FLIP_SWAP", image="talents/twilight.png", --Twilight oddly fits
	desc = _t"Mirror Worlded",
	cancel_on_level_change = true,
	long_desc = function(self, eff) return (_t"This unit will flip spaces soon.") end,
	type = "magical",
	parameters = { cancel = 0 },
	subtype = {temporal = true},
	activate = function(self, eff)
		eff.oldx = self.x
		eff.oldy = self.y
	end,
	callbackOnLevelChange = function(self, eff)
		eff.cancel = 1
	end,
	deactivate = function(self, eff)
		if eff.cancel == 1 then return nil end
		local newx = eff.oldx + (eff.oldx - self.x)
		local newy = eff.oldy + (eff.oldy - self.y)
		
		local x, y = util.findFreeGrid(newx, newy, 3, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "That space is occupied!")
		else
			game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
			self:teleportRandom(x, y, 0)
			game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		end
	end,
}

newEffect{
	name = "STARSCAPE", image = "talents/starscape.png",
	desc = _t"Starscape",
	long_desc = function(self, eff) return (_t"Has summoned the starscape, slowing all creatures 67%.") end,
	type = "magical",
	subtype = {celestial=true},
	status = "beneficial",
	activate = function(self, eff)
		game:onTickEnd(function()
			if game.zone.no_planechange then
				eff.dur = 0
				return
			end
		
			local Map = require("engine.Map")
			require "engine.class"
			eff.terrains = eff.terrains or mod.class.Grid:loadList("/data/general/grids/void.lua")
			eff.entity_list = {}
			
			eff.radius = eff.radius or 8
			local tg = {type="ball", radius = eff.radius, block_radius = function() return false end}
			
			for _, e in pairs(game.level.entities) do
				if e.x and e.y and core.fov.distance(e.x, e.y, self.x, self.y) <= eff.radius then
					local tile = game.level.map.map[e.x + e.y * game.level.map.w]
					--check common layers first then everything
					if tile[Map.ACTOR] == e then eff.entity_list[e] = Map.ACTOR end
					if tile[Map.PROJECTILE] == e then eff.entity_list[e] = Map.PROJECTILE end
					if tile[Map.TRAP] == e then eff.entity_list[e] = Map.TRAP end
					if tile then
						for k, _ in pairs(tile) do
							if tile[k] == e then
								eff.entity_list[e] = k
								break
							end
						end
					end
					--game.level:removeEntity(e, true)
					if eff.entity_list[e] and e.setEffect then
						e:setEffect(e.EFF_ZERO_GRAVITY, eff.dur, {})
					end
				end
			end
			local oldlevel = game.level:cloneFull()
			
			game.level.starscape_source_level = oldlevel
			game.zone.no_planechange = true
			
			local grids = self:project(tg, self.x, self.y, function(px, py) end)
			--don't change the properties of the grids in the middle of the projection
			if grids then for px, ys in pairs(grids or {}) do for py, _ in pairs(ys) do 
				local oe = game.level.map(px, py, Map.TERRAIN)
				local g
				if oe.does_block_move then
					g = eff.terrains.SPACETIME_RIFT:clone()
				else
					g = eff.terrains.VOID:clone()
				end
				g.block_sight = oe.block_sight or false
				g.is_starscape = true
				if oe:attr("temporary") and oe.old_feat then 
					oe.old_feat = g
				else
					game.zone:addEntity(game.level, g, "terrain", px, py)
					game.nicer_tiles:updateAround(game.level, px, py)
				end
			end end end
			
			eff.grids = grids
				
			for _, e in pairs(game.level.entities) do
				if e.x and e.y and core.fov.distance(e.x, e.y, self.x, self.y) > eff.radius then
					if e.EFF_OUTSIDE_THE_STARSCAPE then
						e:setEffect(e.EFF_OUTSIDE_THE_STARSCAPE, eff.dur, {})
					end
					e.energy.mod_starscape = e.energy.mod
					e.energy.mod = 0
				end
			end
			
			local level = game.level
			
			game.level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height})
			game.level.data.background = function(level, x, y, nb_keyframes)
				game.level.background_particle.ps:toScreen(x, y, true, 1)
			end
			
			self.star_plane_on_die = self.on_die
			self.on_die = function(self, ...)
				self:removeEffect(self.EFF_STARSCAPE)
				local args = {...}
				game:onTickEnd(function()
					if self.star_plane_on_die then self:star_plane_on_die(unpack(args)) end
					self.on_die, self.star_plane_on_die = self.star_plane_on_die, nil
				end)
			end
			
			game.level.map:redisplay()
		end)
	end,
	deactivate = function(self, eff)
		game:onTickEnd(function()
			local Map = require("engine.Map")
			eff.entity_list = {}
			
			for _, e in pairs(game.level.entities) do
				if e.x and e.y and core.fov.distance(e.x, e.y, self.x, self.y) <= eff.radius then
					local tile = game.level.map.map[e.x + e.y * game.level.map.w]
					--check common layers first then everything
					if tile[Map.ACTOR] == e then eff.entity_list[e] = Map.ACTOR end
					if tile[Map.PROJECTILE] == e then eff.entity_list[e] = Map.PROJECTILE end
					if tile[Map.TRAP] == e then eff.entity_list[e] = Map.TRAP end
					if tile then
						for k, _ in pairs(tile) do
							if tile[k] == e then
								eff.entity_list[e] = k
								break
							end
						end
					end
				end
			end
			local oldlevel = game.level.starscape_source_level
			
			if eff.grids then for px, ys in pairs(eff.grids or {}) do for py, _ in pairs(ys) do 
				local oe = oldlevel.map(px, py, Map.TERRAIN)
				if not oe.is_starscape then
					game.zone:addEntity(game.level, oe, "terrain", px, py)
					game.nicer_tiles:updateAround(game.level, px, py)
				end
			end end end
			
			for _, e in pairs(game.level.entities) do
				if e.hasEffect and e:hasEffect(e.EFF_OUTSIDE_THE_STARSCAPE) then
					e:removeEffect(e.EFF_OUTSIDE_THE_STARSCAPE)
				end
				if e.hasEffect and e:hasEffect(e.EFF_ZERO_GRAVITY) then
					e:removeEffect(e.EFF_ZERO_GRAVITY, nil, true)
				end
				if e.energy.mod_starscape then e.energy.mod = e.energy.mod_starscape end
			end
			
			game.zone.no_planechange = false
						
			game.level.background_particle = oldlevel.background_particle
			game.level.data.background = oldlevel.data.background_particle
			
			game.level.map:redisplay()
			game.level.map:recreate()
			game.uiset:setupMinimap(game.level)
		end)
	end,
	on_timeout = function(self, eff)
		-- Starscape doesn't cooldown in the starscape
		if eff.t then self.talents_cd[eff.t] = (self.talents_cd[eff.t] or 0) + 1 end
		
	end,
}

newEffect{
	name = "VAMPIRIC_SURGE", image = "talents/vampiric_surge.png",
	desc = _t"Vampiric Surge",
	long_desc = function(self, eff) return ("This unit is recovering %d%% of all damage it deals as health."):tformat(eff.power) end,
	type = "magical",
	subtype = { corruption=true },
	status = "beneficial",
	parameters = { power=0.1, hits=1 },
	on_gain = function(self, err) return _t"#Target# is overflowing with dark power!", _t"+Vamp Surge" end,
	on_lose = function(self, err) return _t"#Target#'s dark aura fades.", _t"-Vamp Surge" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "lifesteal", eff.power)
	end,
}

newEffect{
	name = "TEMPORAL_RIPPLES", image = "talents/temporal_ripples.png",
	desc = _t"Temporal Ripples",
	long_desc = function(self, eff) return ("Attackers dealing damage will be healed for %d%% of the damage done."):tformat(eff.power) end,
	type = "magical",
	subtype = { chronomancy=true, temporal=true },
	status = "detrimental",
	parameters = { power=100 },
	on_gain = function(self, err) return _t"#Target# is fluctuating in time!", true end,
	on_lose = function(self, err) return _t"#Target# is no longer fluctuating.", true end,
	callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, state)
		if not src.heal then return end
		src:heal(dam * eff.power / 100, self)
	end,
}

newEffect{
	name = "DEATH_MOMENTUM", image = "talents/whitehooves.png",
	desc = _t"Death Momentum",
	long_desc = function(self, eff) return ("You have %d charges."):tformat(eff.stacks) end,
	type = "magical",
	subtype = { undead=true },
	status = "beneficial",
	parameters = { stacks=1, max_stacks=1 },
	charges = function(self, eff) return eff.stacks end,
	unsetCharges = function(self, eff)
		if eff.speedid then self:removeTemporaryValue("movement_speed", eff.speedid) eff.speedid = nil end
		if eff.flatid then self:removeTemporaryValue("flat_damage_armor", eff.flatid) eff.flatid = nil end
		if eff.damid then self:removeTemporaryValue("inc_damage", eff.damid) eff.damid = nil end
	end,
	setCharges = function(self, eff)
		eff.speedid = self:addTemporaryValue("movement_speed", 0.2 * eff.stacks)
		if self:knowTalent(self.T_DEAD_HIDE) then
			eff.flatid = self:addTemporaryValue("flat_damage_armor", {all=self:callTalent(self.T_DEAD_HIDE, "getFlatResist") * eff.stacks})
		end
		if self:knowTalent(self.T_LIFELESS_RUSH) then
			eff.damid = self:addTemporaryValue("inc_damage", {all=self:callTalent(self.T_LIFELESS_RUSH, "getDam") * eff.stacks})
		end
	end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = math.max(new_eff.dur, old_eff.dur)
		if new_eff.force_stacks then
			new_eff.force_stacks = nil
			old_eff.stacks = new_eff.max_stacks
		else
			old_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)
		end
		local e = self:getEffectFromId(self.EFF_DEATH_MOMENTUM)
		e.unsetCharges(self, old_eff)
		e.setCharges(self, old_eff)
		return old_eff
	end,
	activate = function(self, eff)
		local e = self:getEffectFromId(self.EFF_DEATH_MOMENTUM)
		e.setCharges(self, eff)
	end,
	deactivate = function(self, eff)
		local e = self:getEffectFromId(self.EFF_DEATH_MOMENTUM)
		e.unsetCharges(self, eff)
	end,
	on_timeout = function(self, eff)
		if eff.dur == 1 then
			if eff.stacks > 1 then
				eff.stacks = eff.stacks - 1 
				eff.dur = 2
				local e = self:getEffectFromId(self.EFF_DEATH_MOMENTUM)
				e.unsetCharges(self, eff)
				e.setCharges(self, eff)
			end
		end
	end,
}

newEffect{
	name = "ETHEREAL_STEAM", image = "talents/ethereal_steam.png",
	desc = _t"Ethereal Steam",
	long_desc = function(self, eff) return ("Deals %0.2f occult damage per turn and each time a talent is used, the caster regens one turn of a random cooldown."):tformat(eff.dam) end,
	type = "magical",
	subtype = { arcane=true, temporal=true, steam=true, technomancy=true },
	status = "detrimental",
	parameters = { dam=10 },
	on_gain = function(self, err) return _t"#Target# covered in arcane-infused steam!", true end,
	on_lose = function(self, err) return _t"#Target# is free from the steam.", true end,
	callbackOnTalentPost = function(self, eff, ab)
		if ab.innate then return end

		local nb = eff.src:talentCooldownFilter(function(t) return t.is_technomancy end, 1, 1, false)
		if nb == 0 then
			eff.src:talentCooldownFilter(function(t) return t.is_spell end, 1, 1, false)
		end
	end,
	activate = function(self, eff)
		eff.tx, eff.ty = eff.src.x-self.x, eff.src.y-self.y
		eff.particle = self:addParticles(Particles.new("ethereal_steam", 1, {tx=eff.tx, ty=eff.ty}))
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
	end,
	callbackOnActBase = function(self, eff)
		if not eff.src or not eff.src.x or core.fov.distance(eff.src.x, eff.src.y, self.x, self.y) > 10 then
			return true
		end

		eff.src:setEffect(eff.src.EFF_ETHEREAL_LINK, 1, {})

		local tx, ty = eff.src.x-self.x, eff.src.y-self.y
		if tx ~= eff.tx or ty ~= eff.ty then
			eff.tx, eff.ty = tx, ty
			self:removeParticles(eff.particle)
			eff.particle = self:addParticles(Particles.new("ethereal_steam", 1, {tx=eff.tx, ty=eff.ty}))
		end
	end,
	on_timeout = function(self, eff)
		if not eff.src or not eff.src.x or core.fov.distance(eff.src.x, eff.src.y, self.x, self.y) > 10 then
			return true
		end

		eff.src:project({type="beam", range=10}, self.x, self.y, DamageType.OCCULT, eff.dam)		
	end,
}

newEffect{
	name = "ETHEREAL_LINK", image = "talents/ethereal_steam.png",
	desc = _t"Ethereal Link",
	long_desc = function(self, eff) return ("While Ethereal Steam exists the cooldown of Metaphasic Spin is reduced to 6."):tformat(eff.dam) end,
	type = "magical",
	subtype = { arcane=true, temporal=true, steam=true, technomancy=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "metaphasic_spin_cd_reduce", 1)
	end,
}

newEffect{
	name = "METAPHASIC_ECHO", image = "talents/metaphasic_pulse.png",
	desc = _t"Metaphasic Echoes",
	long_desc = function(self, eff) return ("Project your saw along the leftover breaches."):tformat() end,
	type = "magical",
	subtype = { arcane=true, temporal=true, steam=true, technomancy=true },
	status = "beneficial",
	parameters = { },
	callbackOnCloned = function(self, eff)
		eff.list = {}
	end,
	callbackOnChangeLevel = function(self, eff, what)
		eff.list = {}
	end,
	activate = function(self, eff)
		eff.list = eff.list or {}
	end,
	on_timeout = function(self, eff)
		if #eff.list > 0 then
			self:callTalent(self.T_METAPHASIC_PULSE, "doEcho", eff.list)
		end
	end,
}

newEffect{
	name = "SPIDERBOT_SHIELD", image = "talents/spiderbot_shield.png",
	desc = _t"Spiderbots Shield",
	long_desc = function(self, eff) return ("%d spiderbots are protecting you, each with %d life. Current top spiderbot has %d life remaining."):tformat(eff.nb, eff.life, eff.cur_life) end,
	type = "magical",
	subtype = { arcane=true, temporal=true, technomancy=true },
	status = "beneficial",
	parameters = { life=30, nb=4 },
	on_gain = function(self, err) return _t"#Target# covered with micro spiderbots!", true end,
	on_lose = function(self, err) return _t"#Target# is no longer protected by spiderbots.", true end,
	callbackOnHit = function(self, eff, cb, src, dt)
		if not eff.nb or eff.nb <= 0 then return end
		if not cb.value then return end

		if cb.value >= eff.cur_life then
			eff.nb = eff.nb - 1
			eff.cur_life = eff.life

			if eff.adv_gfx then
				if eff.particles[1] and eff.particles[1]._shader and eff.particles[1]._shader.shad then
					-- Clones don't copy this so we need to recreate it sometimes
					if not eff.particles[1].shader then eff.particles[1] = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.5, rotation=0, radius=1.5, img="bone_shield"}, {type="boneshield"})) end
					eff.particles[1]._shader.shad:resetClean()
					eff.particles[1]._shader:setResetUniform("chargesCount", util.bound(eff.nb, 0, 10))
					eff.particles[1].shader.chargesCount = util.bound(eff.nb, 0, 10)
				end
			else
				local pid = table.remove(eff.particles)
				self:removeParticles(pid)
			end
			game:delayedLogDamage(src, self, 0, ("#SLATE#(%d to spiderbot - destructed)#LAST#"):tformat(cb.value), false)
			if self:isTalentActive(self.T_CRYOGENIC_DIGS) and src and src.x and src.y then
				local x, y = src.x, src.y
				if x ~= self.x and y ~= self.y then
					game.level.map:particleEmitter(self.x, self.y, 1, "spiderbot_move", {tx=x-self.x, ty=y-self.y}, nil, 13)
				end
				self:callTalent(self.T_CRYOGENIC_DIGS, "doDig", x, y)
			end
		else
			eff.cur_life = eff.cur_life - cb.value
			game:delayedLogDamage(src, self, 0, ("#SLATE#(%d to spiderbot)#LAST#"):tformat(cb.value), false)
		end
		cb.value = 0
		return true
	end,
	activate = function(self, eff)
		local adv_gfx = core.shader.allow("adv") and true or false
		local ps = {}
		if adv_gfx then
			ps[1] = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.5, rotation=0, radius=1.5, img="spiderbot_shield"}, {type="boneshield"}))
			ps[1]._shader.shad:resetClean()
			ps[1]._shader:setResetUniform("chargesCount", util.bound(eff.nb, 0, 10))
			ps[1].shader.chargesCount = util.bound(eff.nb, 0, 10)
		else
			for i = 1, eff.nb do ps[#ps+1] = self:addParticles(Particles.new("bone_shield", 1)) end
		end

		eff.adv_gfx = adv_gfx
		eff.particles = ps
		eff.cur_life = eff.life
	end,
	deactivate = function(self, eff)
		for i, particle in ipairs(eff.particles) do self:removeParticles(particle) end
	end,
}

newEffect{
	name = "ELECTRON_INCANTATION", image = "talents/electron_incantation.png",
	desc = _t"Electron Incantation",
	long_desc = function(self, eff) return ("Arcane Dynamo returns %d more steam per 10 mana spent."):tformat(eff.power) end,
	type = "magical",
	subtype = { spell=true, technomancy=true },
	status = "beneficial",
	parameters = { power=2 },
	on_gain = function(self, err) return nil, true end,
	on_lose = function(self, err) return nil, true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "arcane_dynamo", eff.power)
	end,
}

newEffect{
	name = "GALEN_DYNAMO", image = "talents/electron_incantation.png",
	desc = _t"Defensive Circuit: Dynamo Boost",
	long_desc = function(self, eff) return ("Arcane Dynamo returns %d more steam per 10 mana spent."):tformat(eff.power) end,
	type = "magical",
	subtype = { spell=true, technomancy=true },
	status = "beneficial",
	parameters = { power=2 },
	on_gain = function(self, err) return nil, true end,
	on_lose = function(self, err) return nil, true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "arcane_dynamo", eff.power)
	end,
}

newEffect{
	name = "GALEN_PROTECTION", image = "talents/electron_incantation.png",
	desc = _t"Defensive Circuit: Resistances Boost",
	long_desc = function(self, eff) return ("All resistances increased by %d%%."):tformat(eff.power) end,
	type = "magical",
	subtype = { spell=true, technomancy=true },
	status = "beneficial",
	parameters = { power=2 },
	on_gain = function(self, err) return nil, true end,
	on_lose = function(self, err) return nil, true end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {all=eff.power})
	end,
}
