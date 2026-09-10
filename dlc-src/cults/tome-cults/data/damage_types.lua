-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

local initState = engine.DamageType.initState
local useImplicitCrit = engine.DamageType.useImplicitCrit


newDamageType{
	name = _t("unstable rift", "damage type"), type="RIFT",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:reactionToward(target) < 0 then
			if dam.edam > 0 then DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam.edam, state) end
			if dam.pin > 0 and target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, dam.pin, {apply_power=src:combatSpellpower()})
			end
		end
	end,
}

newDamageType{
	name = _t("rift explosion", "damage type"), type = "RIFT_EXPLOSION",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not target.turn_procs.rift_explosion then
			target.turn_procs.rift_explosion = true
			DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam, state)
			return dam
		end
	end,
}

newDamageType{
	name = _t("voidburn", "damage type"), type = "VOIDBURN",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		DamageType:get(DamageType.VOID).projector(src, x, y, DamageType.VOID, dam.dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Set on fire!
			local finaldam = dam.dam * dam.perc
			target:setEffect(target.EFF_VOIDBURN, dam.dur, {src=src, power=finaldam / dam.dur, no_ct_effect=true})
		end
		return init_dam
	end,
}

newDamageType{
	name = _t("slowing void", "damage type"), type = "VOID_SLOW",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		
		local target = game.level.map(x, y, Map.ACTOR)
		if not target or target.dead then return end
		DamageType:get(DamageType.VOID).projector(src, x, y, DamageType.VOID, dam.dam, state)		
		local dur = dam.dur or 4
		if target:canBe("slow") then
			target:setEffect(target.EFF_SLOW, dam.dur, {power=0.4, src:combatSpellpower()})
		end
	end,
}

newDamageType{
	name = _t("draining void", "damage type"), type = "VOID_DRAIN",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam, healfactor=0.1} end
		local target = game.level.map(x, y, Map.ACTOR) -- Get the target first to make sure we heal even on kill
		local realdam1 = DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam.dam / 2, state)
		local realdam2 = DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam / 2, state)	
		local realdam = realdam1 + realdam2
		if target and realdam > 0 and not src:attr("dead") then
			src.reverse_entropy = true
			src:heal(realdam * dam.healfactor, target)
			src:logCombat(target, "#Source# drains life from #Target#!")
			src.reverse_entropy = nil
		end
		return realdam
	end,
}

newDamageType{
	name = _t("mesmerize", "damage type"), type = "MESMERIZE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("stun") then
				game:onTickEnd(function() target:setEffect(target.EFF_DAZED, 2, {apply_power=dam.apply_power, no_ct_effect=true}) end) --onTickEnd to avoid breaking the daze
			end
		end
	end,
}

-- Darkness+Temporal damage, sets any negative magical effect under 3 duration to 3 duration
newDamageType{
	name = _t("obliterating void", "damage type"), type = "OBLIVION",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then 
			if _G.type(dam) == "table" then dam, dur, perc = dam.dam, dam.dur, (dam.initial or perc) end
			local init_dam = dam
			if init_dam > 0 then DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, init_dam, state) end
			if init_dam > 0 then DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, init_dam, state) end

			local effects = target:effectsFilter({types={magical=true}, status="detrimental"}, 10)
			for _, effect in ipairs(effects) do
				if target.tmp[effect].dur < 3 then target.tmp[effect].dur = 3 end
			end
			return init_dam
		end
	end,
}

newDamageType{
	name = _t("aging temporal", "damage type"), type = "TEMPORAL_AGING",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)

		if _G.type(dam) == "number" then dam = {dam=dam, chance=25, apply=src:combatSpellpower()} end
		
		local target = game.level.map(x, y, Map.ACTOR)
		if not target or target.dead then return end
		
		local eff = rng.range(1, 3)
		local power = dam.apply_power or src:combatSpellpower()
		local dur = dam.dur or 2
		-- Pull random effect
		if eff == 1 then
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, dur, {apply_power=power, no_ct_effect=true})
			else
				game.logSeen(target, "%s resists the blindness!", target:getName():capitalize())
			end
		elseif eff == 2 then
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, dur, {apply_power=power, no_ct_effect=true})
			else
				game.logSeen(target, "%s resists the pin!", target:getName():capitalize())
			end
		elseif eff == 3 then
			if target:canBe("confusion") then
				target:setEffect(target.EFF_CONFUSED, dur, {power=50, apply_power=power, no_ct_effect=true})
			else
				game.logSeen(target, "%s resists the confusion!", target:getName():capitalize())
			end
		end
		DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam.dam, state)		
	end,
}

-- Scourge drake
newDamageType{
	name = _t("decaying ground", "damage type"), type = "DECAYING_GROUND", text_color = "#DARK_GREEN#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("slow") then
			target:setEffect(target.EFF_DECAYING_GROUND, 3, { power=dam.power or 10 })
		end
	end,
}

newDamageType{
	name = _t("defiled blood", "damage type"), type = "DEFILED_BLOOD", text_color = "#BLACK#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)

		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end

		local tentacle = src:callTalent(src.T_MUTATED_HAND, "getTentacleCombat")
		if not tentacle then return end

		local speed, hit = src:attackTargetWith(target, tentacle, DamageType.DARKNESS, dam)
		if hit then
			target:setEffect(target.EFF_DEFILED_BLOOD, 2, {power=src:callTalent(src.T_DEFILED_BLOOD, "getHeal")})
		end
		game.level.map:particleEmitter(x, y, 1, "tentacle_ground", {img="tentacle_black"})
	end,
}

newDamageType{
	name = _t("antropy energies", "damage type"), type = "ENTROPIC_VOID_HELPER", text_color = "#GOLD#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)

		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end

		target:removeEffect(target.EFF_TOTAL_COLLAPSE, false, true)

		local npc = game.level:findEntity{define_as="HYPOSTASIS"}
		if not npc then return end

		game.level.data.antropic_accumulation = (game.level.data.antropic_accumulation or 0) + 1
		if game.level.data.antropic_accumulation > 10 then
			game.logSeen(npc, "#PURPLE#The %s fully awakens as you absorb antropic forces!", npc.name)
			npc:awakenAntropic()
			game.level.data.antropic_accumulation = 0
		else
			game.logSeen(npc, "#PURPLE#The %s seems to shudder as you absorb some antropic forces.", npc.name)
		end
	end,
}
