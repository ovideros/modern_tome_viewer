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

local initState = engine.DamageType.initState
local useImplicitCrit = engine.DamageType.useImplicitCrit

-- Physical damage + repulsion; checks for attack power against physical resistance
newDamageType{
	name = _t("pulse detonator", "damage type"), type = "PULSE_DETONATOR",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)

		local target = game.level.map(x, y, Map.ACTOR)
		if target and not state[target] then
			state[target] = true
			DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam, state)
			if target:checkHit(src:combatSteampower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(dam.x or src.x, dam.y or src.y, dam.dist)
				target:crossTierEffect(target.EFF_OFFBALANCE, src:combatSteampower())
				game.logSeen(target, "%s is knocked back!", target:getName():capitalize())
			else
				game.logSeen(target, "%s resists the knockback!", target:getName():capitalize())
			end
			if target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, dam.dur, {apply_power=src:combatSteampower()})
			end
		end
	end,
}

newDamageType{
	name = _t("darkness pull", "damage type"), type = "DARKNESS_PULL",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)

		local target = game.level.map(x, y, Map.ACTOR)
		if _G.type(dam) ~= "table" then dam = {dam=dam, dist=1, px = src.x, py = src.y} end
		if target then
			DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam)
			if (dam.ignore_resist or target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15)) and target:canBe("knockback") then
				target:pull(dam.px, dam.py, dam.dist)
				if (not dam.silent) then
					game.logSeen(target, "%s is pulled!", target:getName():capitalize())
				end
			else
				if (not dam.silent) then
					game.logSeen(target, "%s resists the pull!", target:getName():capitalize())
				end
			end
		end
	end,
}

newDamageType{
	name = _t("darkness pin", "damage type"), type = "DARKNESS_PIN",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) ~= "table" then dam = {dam=dam, pin=4} end
		DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, dam.pin, {src=src, apply_power=src:combatSpellpower(), no_ct_effect=true})
			else
				game.logSeen(target, "%s resists!", target:getName():capitalize())
			end
		end
	end,
}

newDamageType{
	name = _t("drain negative", "damage type"), type = "DRAIN_NEGATIVE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam, factor=0.2} end
		local target = game.level.map(x, y, Map.ACTOR)
		local realdam = DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam)
		if target and (realdam > 0 or dam.min) then
			local drain = (dam.min and math.max(dam.min, realdam * dam.factor)) or realdam * dam.factor
			src:incNegative(drain)
		end
	end,
}

--in short, effects must have damage, I use this for lucent wrath
newDamageType{
	name = _t("null_type", "damage type"), type="NULL_TYPE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
	end,
}

--light and darkness in a mix
newDamageType{
	name = _t("light + dark", "damage type"), type = "LIGHT_DARK",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) ~= "table" then dam = {dam=dam, light_part=1/2} end
		local light_dam = DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam.dam * dam.light_part)
		local dark_dam  = DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam * (1 - dam.light_part))
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if dam.slow and dark_dam > 0 then
				target:setEffect(target.EFF_SLOW_MOVE, 5, {apply_power=src:combatSpellpower(), power=dam.slow}, true)
			end if dam.slow and light_dam > 0 then
				target:setEffect(target.EFF_SLOW_TALENT, 5, {apply_power=src:combatSpellpower(), power=dam.slow * 0.6}, true)
			end
		end
	end,
}

-- Blight needles, physical damage + potential diseases
newDamageType{
	name = _t("blighted needles", "damage type"), type = "BLIGHTED_NEEDLES", text_color = "#DARK_GREEN#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("disease") and rng.percent(dam.disease_chance or 20) then
			local eff = rng.table{{target.EFF_ROTTING_DISEASE, "con"}, {target.EFF_DECREPITUDE_DISEASE, "dex"}, {target.EFF_WEAKNESS_DISEASE, "str"}}
			target:setEffect(eff[1], dam.dur or 5, { src = src, [eff[2]] = dam.disease_power or 5, dam = dam.disease_dam or (dam.dam / 5) })
		end
	end,
}

-- Corrupted blood, blight damage + potential diseases
newDamageType{
	name = _t("infective darkness", "damage type"), type = "MIASMA", text_color = "#DARK_GREEN#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("disease") and rng.percent(dam.disease_chance or 20) then
			local eff = rng.table{{target.EFF_ROTTING_DISEASE, "con"}, {target.EFF_DECREPITUDE_DISEASE, "dex"}, {target.EFF_WEAKNESS_DISEASE, "str"}}
			target:setEffect(eff[1], dam.dur or 5, { src = src, [eff[2]] = dam.disease_power or 5, dam = dam.disease_dam or (dam.dam / 5) })
		end
	end,
}

-- Regen steam, damage bleeding
newDamageType{
	name = _t("fiery vapour", "damage type"), type = "FIERY_VAPOUR", text_color = "#RED#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam, steam=3} end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		if target:getMaxSteam() > 0 then
			target:incSteam(dam.steam)
		end
		if #target:effectsFilter({subtype={bleed=1}}, 1) > 0 then
			DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam.dam)
		end
	end,
}

-- Heals
newDamageType{
	name = _t("repairing", "damage type"), type = "REPAIR_MECHANICAL",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target.repairable then
			target:attr("allow_on_heal", 1)
			target:heal(dam, src)
			target:attr("allow_on_heal", -1)
		end
	end,
}

-- Heals
newDamageType{
	name = _t("mind drone", "damage type"), type = "MIND_DRONE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:reactionToward(target) < 0 then
			target:setEffect(target.EFF_MIND_DRONE, 6, {apply_power=src:combatSteampower(), fail=dam.fail, reduction=dam.reduction})
		end
		return 0
	end,
}

-- Physical damage + repulsion; checks for attack power against physical resistance
newDamageType{
	name = _t("20% chance of physical repulsion", "damage type"), type = "THUNDERCLAP_COATING",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		state = initState(state)
		if _G.type(dam) ~= "table" then dam = {dam=dam, dist=3} end
		if target and not state[target] and rng.percent(20) then
			state[target] = true
			DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam, state)
			if target:checkHit(src:combatSteampower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(dam.x or src.x, dam.y or src.y, dam.dist)
				target:crossTierEffect(target.EFF_OFFBALANCE, src:combatPhysicalpower())
				game.logSeen(target, "%s is knocked back!", target:getName():capitalize())
			else
				game.logSeen(target, "%s resists the knockback!", target:getName():capitalize())
			end
		end
	end,
}

-- Heals on attack
newDamageType{
	name = _t("temporal ripples", "damage type"), type = "TEMPORAL_RIPPLES",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:reactionToward(target) < 0 then
			target:setEffect(target.EFF_TEMPORAL_RIPPLES, 2, {power=dam})
		end
		return 0
	end,
}

-- Heals on attack
newDamageType{
	name = _t("curse of amakthel", "damage type"), type = "CURSE_OF_AMAKTHEL",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:reactionToward(target) < 0 then
			target:setEffect(target.EFF_CURSE_OF_AMAKTHEL, 2, {power=dam})
		end
		return 0
	end,
}

-- Mind + Sear temp effect
newDamageType{
	name = _t("psionic searing", "damage type"), type = "PSIONIC_FOG",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.MIND).projector(src, x, y, DamageType.MIND, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(target.EFF_SEARED, 1, { apply_power=src:combatMindpower(), power=dam.sear or 10 })
		end
	end,
}

-- Damages a range of resources
newDamageType{
	name = _t("resource shock", "damage type"), type = "RESOURCE_SHOCK",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target.stamina then target:incStamina(-dam) end
			if target.mana then target:incMana(-dam) end
			if target.psi then target:incPsi(-dam) end
			if target.steam then target:incSteam(-dam) end
		end
	end,
}

newDamageType{
	name = _t("smoke cloud", "damage type"), type = "SMOKE_CLOUD",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if src:reactionToward(target) < 0 then
				if target:canBe("confusion") then
					local reapplied = target:hasEffect(target.EFF_CONFUSED)
					target:setEffect(target.EFF_CONFUSED, 2, { power=dam.dam, src=src }, reapplied)
				end
			else
				local reapplied = target:hasEffect(target.EFF_SMOKE_COVER)
				target:setEffect(target.EFF_SMOKE_COVER, 1, { power=dam.chance, stealth = dam.stealth }, reapplied)
			end
		end
	end,
}

newDamageType{
	name = _t("lightning web", "damage type"), type = "LIGHTNING_WEB",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if src:reactionToward(target) < 0 then
				local shield, shield_combat = src:hasShield()
				if not shield then return nil end
				src:attackTargetWith(target, shield_combat, DamageType.LIGHTNING, dam.dam)
			else
				target:setEffect(target.EFF_LIGHTNING_WEB, 1, { src=src, power=dam.block } )
			end
		end
	end,
}

newDamageType{
	name = _t("incendiary grenade", "damage type"), type = "INCENDIARY_GRENADE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local dur = 3
		local perc = 50
		if _G.type(dam) == "table" then dam, dur, perc = dam.dam, dam.dur, (dam.initial or perc) end
		local init_dam = dam * perc / 100
		if init_dam > 0 then DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, init_dam, state) end
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			-- Set on fire!
			dam = dam - init_dam
			target:setEffect(target.EFF_INCENDIARY_GRENADE, dur, {src=src, dam=dam / dur, power=src:callTalent(src.T_SAPPER, "getFirePower"), apply_power=src:combatSteampower()})
		end
		return init_dam
	end,
}

newDamageType{
	name = _t("chemical grenade", "damage type"), type = "CHEMICAL_GRENADE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam, power=0.15} end
		DamageType:get(DamageType.ACID).projector(src, x, y, DamageType.ACID, dam.dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(target.EFF_SLOW, 3, {power=src:callTalent(src.T_SAPPER, "getAcidPower")/100, apply_power=src:combatSteampower()})
		end
	end,
}

newDamageType{
	name = _t("shock grenade", "damage type"), type = "SHOCK_GRENADE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		DamageType:get(DamageType.LIGHTNING).projector(src, x, y, DamageType.LIGHTNING, dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(target.EFF_SHOCKED, src:callTalent(src.T_SAPPER, "getLightningPower"), {apply_power=src:combatSteampower()})
		end
	end,
}

newDamageType{
	name = _t("phosphorous", "damage type"), type = "PHOSPHOROUS",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:knowTalent(src.T_INCENDIARY_POWDER) then
			local dam = src:callTalent(src.T_INCENDIARY_POWDER, "getDamage")
			local apr = src:callTalent(src.T_INCENDIARY_POWDER, "getApr")
			local fear = src:callTalent(src.T_INCENDIARY_POWDER, "getFear")
			target:setEffect(target.EFF_BURNING_PHOSPHOROUS, 3, { src=src, dam=dam/3, initdam=dam/2, fire=fire, apr=apr, fear=fear})
		end
	end,
}

newDamageType{
	name = _t("fire wall", "damage type"), type = "FIREWALL",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam.dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(target.EFF_SCORCHED, 2, {resist=dam.power, apply_power=src:combatSteampower()})
		end
	end,
}


newDamageType{
	name = _t("volatile fuel", "damage type"), type = "FLAME_FUEL",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam.dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			local burns = {}
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.fire and p.power and e.status == "detrimental" then
					burns[#burns+1] = {id=eff_id, params=p}
				end
			end
			-- Make them EXPLODE !!!
			for i, d in ipairs(burns) do
				DamageType:get(DamageType.FIRE).projector(src, x, y, engine.DamageType.FIRE, d.params.power * d.params.dur * dam.burn)
				target:removeEffect(d.id)
			end
			game.level.map:particleEmitter(target.x, target.y, 1, "ball_fire", {radius=1})
		end
	end,
}

newDamageType{
	name = _t("chemical", "damage type"), type = "ACID_BLINDDISARM",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.ACID).projector(src, x, y, DamageType.ACID, dam.dam, state)
		
		local target = game.level.map(x, y, Map.ACTOR)
		if not target or target.dead then return end
		
		local eff = rng.range(1, 2)
		local power = dam.apply_power or src:combatSteampower()
		local dur = dam.dur or 2
		-- Pull random effect
		if eff == 1 then
			if target:canBe("disarm") then
				target:setEffect(target.EFF_DISARMED, dur, {apply_power=power, no_ct_effect=true})
			end
		elseif eff == 2 then
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, dur, {apply_power=power, no_ct_effect=true})
			end
		end
	end,
}

newDamageType{
	name = _t("debilitating acid", "damage type"), type = "DEBILITATING_ACID",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		DamageType:get(DamageType.ACID).projector(src, x, y, DamageType.ACID, dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src and src:knowTalent(src.T_SAFETY_OVERRIDE) then
			local inc = src:callTalent(src.T_SAFETY_OVERRIDE, "getBoltDamageIncrease")/100
			local dur = src:callTalent(src.T_SAFETY_OVERRIDE, "getBoltDuration")
			
			local effs = target:effectsFilter({status="detrimental", types={physical=true, magical=true, mental=true,}}, 50)
			local nb = #effs
			if nb > 0 then
				for _, eff_id in ipairs(effs) do
					target.tmp[eff_id].dur = target.tmp[eff_id].dur + dur
				end
				for i = 1, nb do
					target.turn_procs.debilitating_acid = 1 + (target.turn_procs.debilitating_acid or 0)
					if target.turn_procs.debilitating_acid <= 6 then
						DamageType:get(DamageType.ACID).projector(src, x, y, DamageType.ACID, dam*inc) 
					end
				end
			end
		end
	end,
}

newDamageType{
	name = _t("caustic steam", "damage type"), type = "CAUSTIC_STEAM",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:knowTalent(src.T_MIASMA_ENGINE) and not target:hasEffect(target.EFF_MIASMA_ADAPTATION) then
			target:setEffect(target.EFF_MIASMA, 2, {src=src, fail=src:callTalent(src.T_MIASMA_ENGINE, "getChance"), heal=src:callTalent(src.T_MIASMA_ENGINE, "getHealing"), dam=src:callTalent(src.T_MIASMA_ENGINE, "getDamage"), apply_power=src:combatSteampower(), no_ct_effect=true})
		end
	end,
}

-- Technomancy stuff
newDamageType{
	name = _t("galvanic", "damage type"), type = "GALVANIC", text_color = "#STEEL_BLUE#",
	damdesc_split = { {DamageType.FIRE, 0.5}, {DamageType.LIGHTNING, 0.5} },
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local dts = table.shuffle{DamageType.LIGHTNING, DamageType.FIRE}
		local realdam1 = DamageType:get(dts[1]).projector(src, x, y, dts[1], dam / 2, state)
		local realdam2 = DamageType:get(dts[2]).projector(src, x, y, dts[2], dam / 2, state)
		return (realdam1 or 0) + (realdam2 or 0)
	end,
}
newDamageType{
	name = _t("occult", "damage type"), type = "OCCULT", text_color = "#ORCHID#",
	damdesc_split = function(src)
		if not src:hasEffect(src.EFF_AETHER_AVATAR) or not src:isTalentActive(src.T_METATEMPORAL_SPINNER) then
			return { {DamageType.ARCANE, 0.5}, {DamageType.TEMPORAL, 0.5} }
		else
			return DamageType.ARCANE
		end
	end,
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if not src:hasEffect(src.EFF_AETHER_AVATAR) or not src:isTalentActive(src.T_METATEMPORAL_SPINNER) then
			-- We dnot shuffle, as archmages dont have temporal, we always watn arcane first
			local realdam1 = DamageType:get(DamageType.ARCANE).projector(src, x, y, DamageType.ARCANE, dam / 2, state)
			local realdam2 = DamageType:get(DamageType.TEMPORAL).projector(src, x, y, DamageType.TEMPORAL, dam / 2, state)
			return (realdam1 or 0) + (realdam2 or 0)
		else
			return DamageType:get(DamageType.ARCANE).projector(src, x, y, DamageType.ARCANE, dam, state)
		end
	end,
}
newDamageType{
	name = _t("terrene", "damage type"), type = "TERRENE", text_color = "#LIGHT_UMBER#",
	damdesc_split = { {DamageType.PHYSICAL, 0.5}, {DamageType.COLD, 0.5} },
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local dts = table.shuffle{DamageType.COLD, DamageType.PHYSICAL}
		local realdam1 = DamageType:get(dts[1]).projector(src, x, y, dts[1], dam / 2, state)
		local realdam2 = DamageType:get(dts[2]).projector(src, x, y, dts[2], dam / 2, state)
		return (realdam1 or 0) + (realdam2 or 0)
	end,
}
