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

local _M = loadPrevious(...)
local Dialog = require "engine.ui.Dialog"
local Particles = require "engine.Particles"

local init = _M.init
function _M:init(t, no_default)
	t.max_steam = t.max_steam or 100
	t.steam_regen = t.steam_regen or 0
	t.combat_steamspeed = t.combat_steamspeed or 1
	init(self, t, no_default)
end

_M.sustainCallbackCheck.callbackOnMedicalSalve = "talents_on_medical_salve"

_M:bindHook("Actor:move", function(self, data)
	if data.moved and not data.forced and self:isTalentActive(self.T_TINKER_ROCKET_BOOTS) and (data.ox ~= self.x or data.oy ~= self.y) then
		game.level.map:addEffect(self, data.ox, data.oy, 4, engine.DamageType.INFERNO, self:callTalent(self.T_TINKER_ROCKET_BOOTS, "getDam"), 0, 5, nil, {type="inferno"}, nil, true)
	end
end)

_M:bindHook("Actor:getSpeed", function(self, data)
	if data.speed_type == "steamtech" then
		data.speed = self:combatSteamSpeed()
		return true
	end
end)

_M:bindHook("Actor:tooltip", function(self, data)
	if self:knowTalent(self.T_STEAM_POOL) then
		data.ts:add(_t"#FFD700#St. power#FFFFFF#: ", self:colorStats("combatSteampower"), true)
	end
end)

local getTalentSpeedType = _M.getTalentSpeedType
function _M:getTalentSpeedType(t)
	if t.is_steam then return "steamtech" end
	return getTalentSpeedType(self, t)
end

--- Call when an object is worn
-- This doesnt call the base interface onWear, it copies the code because we need some tricky stuff
local onWear = _M.onWear
function _M:onWear(o, inven_id, bypass_set)
	if self:knowTalent(self.T_INNOVATION) and o.wielder and o.power_source and (o.power_source.technique or o.power_source.steam) then
		if o.__innovation_adds then
			o:tableTemporaryValuesRemove(o.__innovation_adds)
			o.__innovation_adds = nil
		end
		
		local factor = self:callTalent(self.T_INNOVATION, "getFactor") / 100

		o.__innovation_adds = {}
		if o.wielder.combat_spellresist then o:tableTemporaryValue(o.__innovation_adds, {"wielder", "combat_spellresist"}, math.ceil(o.wielder.combat_spellresist * factor)) end
		if o.wielder.combat_physresist then o:tableTemporaryValue(o.__innovation_adds, {"wielder", "combat_physresist"}, math.ceil(o.wielder.combat_physresist * factor)) end
		if o.wielder.combat_mentalresist then o:tableTemporaryValue(o.__innovation_adds, {"wielder", "combat_mentalresist"}, math.ceil(o.wielder.combat_mentalresist * factor)) end
		if o.wielder.combat_armor then o:tableTemporaryValue(o.__innovation_adds, {"wielder", "combat_armor"}, math.ceil(o.wielder.combat_armor * factor)) end
		if o.wielder.combat_def then o:tableTemporaryValue(o.__innovation_adds, {"wielder", "combat_def"}, math.ceil(o.wielder.combat_def * factor)) end
		if o.wielder.inc_stats then 
			local adds = {}
			for k, v in pairs(o.wielder.inc_stats) do adds[k] = math.ceil(v * factor) end
			o:tableTemporaryValue(o.__innovation_adds, {"wielder", "inc_stats"}, adds)
		end
	end

	if o.define_as == "STEAMGUN_ANNIHILATOR" and self == game.player and self.descriptor and self.descriptor.subclass == "Annihilator" then
		world:gainAchievement("ORCS_DOUBLE_ANNIHILATOR", self)
	end

	onWear(self, o, inven_id, bypass_set)
end

--- Call when an object is taken off
local onTakeoff = _M.onTakeoff
function _M:onTakeoff(o, inven_id, bypass_set)
	onTakeoff(self, o, inven_id, bypass_set)

	if o.__innovation_adds then
		o:tableTemporaryValuesRemove(o.__innovation_adds)
		o.__innovation_adds = nil
	end
end

local on_set_temporary_effect = _M.on_set_temporary_effect
function _M:on_set_temporary_effect(eff_id, e, p)
	local ret = on_set_temporary_effect(self, eff_id, e, p)

	if self:attr("ignore_fireburn") and (eff_id == self.EFF_BURNING or eff_id == self.EFF_BURNING_SHOCK) then p.dur = 0 end
	
	if self:attr("ignore_bleed") and (eff_id == self.EFF_CUT or eff_id == self.EFF_DEEP_WOUND) then p.dur = 0 end

	if self:attr("heal_on_detrimental_status") and p.dur > 0 and e.status == "detrimental" and (e.type == "physical" or e.type == "magical" or e.type =="mental") and not (self.turn_procs.heal_detrimental and self.turn_procs.heal_detrimental >= 3) then
		self:attr("disable_ancestral_life", 1)
		self:heal(self:attr("heal_on_detrimental_status"))
		self.turn_procs.heal_detrimental = self.turn_procs.heal_detrimental or 0
		self.turn_procs.heal_detrimental = self.turn_procs.heal_detrimental + 1
		self:attr("disable_ancestral_life", -1)

	end
	return ret
end

local die = _M.die
function _M:die(src, death_note)
	local ret = die(self, src, death_note)
	if src and game.party:hasMember(src) and self.type == "giant" and self.subtype == "steam" and self.civilian then
		world:gainAchievement("ORCS_CIVILIAN_KILLER", src)
		game.zone.dead_civilian = true
	end
	return ret
end

local levelup = _M.levelup
function _M:levelup()
	levelup(self)

	if self == game.player and self.level == 10 and self.descriptor and self.descriptor.race == "Orc" and self.descriptor.class == "Tinker" then
		game:setAllowedBuild("cosmetic_race_orc", true)
	end
end

local canBe = _M.canBe
function _M:canBe(what)
	if what == "worldport" then
		local q = self:hasQuest("orcs+kruk-invasion")
		if q and not q:isStatus(engine.Quest.DONE) and game.zone and game.zone.short_name == "orcs+town-kruk" then
			Dialog:simplePopup(_t"Kruk Invasion", _t"You can not recall until you have placed the bomb at the tunnel's end!")
			return false, 0
		end
	end
	return canBe(self, what)
end

-- local base_canWearObject = _M.canWearObject
-- function _M:canWearObject(o, try_slot)
--         local oldreq = nil
--         if o.subtype == "shield" and self:knowTalent(self.T_STATIC_SHOCK) then
--                 oldreq = rawget(o, "require")
--                 o.require = table.clone(oldreq or {}, true)
--                 if o.require.stat and o.require.stat.str then
--                         o.require.stat.cun, o.require.stat.str = o.require.stat.str, nil
--                 end
--         end
--         if o.subtype == "steamsaw" and self:knowTalent(self.T_OVERRUN) then
--                 oldreq = rawget(o, "require")
--                 o.require = table.clone(oldreq or {}, true)
--                 if o.require.stat and o.require.stat.str then
--                         o.require.stat.dex, o.require.stat.dex = o.require.stat.str, nil
--                 end
--         end				
--         local ret = base_canWearObject(self, o, try_slot)
--         if oldreq then o.require = oldreq end
--         return ret
-- end

local base_updateObjectRequirements = _M.updateObjectRequirements
function _M:updateObjectRequirements(o)
	local oldreq = rawget(o, "require")
	if not oldreq then return oldreq end
	local newreq
	if o.subtype == "shield" and self:knowTalent(self.T_STATIC_SHOCK) then
		newreq = newreq or table.clone(oldreq, true)
		if newreq.stat and newreq.stat.str then
			newreq.stat.cun, newreq.stat.str = newreq.stat.str, nil
		end
	elseif o.subtype == "steamsaw" and self:knowTalent(self.T_OVERRUN) then
		newreq = newreq or table.clone(oldreq, true)
		if newreq.stat and newreq.stat.str then
			newreq.stat.dex, newreq.stat.str = newreq.stat.str, nil
		end
	elseif o.type == "armor" and self:knowTalent(self.T_MECHARACHNID_LINK) then
		newreq = newreq or table.clone(oldreq, true)
		if newreq.stat and newreq.stat.str then
			newreq.stat.dex, newreq.stat.str = newreq.stat.str, nil
		end
	end
	if newreq then o.require = newreq end
	local ret, reason = base_updateObjectRequirements(self, o)
	return ret, reason
end

local hasArcheryWeapon = _M.hasArcheryWeapon
function _M:hasArcheryWeapon(type, quickset)
	if self.archery_weapon_override then
		if not self.archery_weapon_override.ignore_disarm and
			self:attr('disarmed')
		then return nil, 'disarmed' end
		return unpack(self.archery_weapon_override)
	end
	if self:attr('disarmed') then return nil, 'disarmed' end
	return hasArcheryWeapon(self, type, quickset)
end

--------------------------------------------------------------------------------------------
-- Resources
--------------------------------------------------------------------------------------------

local learnTalent = _M.learnTalent
function _M:learnTalent(t_id, ...)
	if not learnTalent(self, t_id, ...) then return false end
	local t = _M.talents_def[t_id]
	if t.type[1] == "inscriptions/implants" then self:updateModdableTile() end
	local tt = _M.talents_types_def[t.type[1]]
	if tt and tt.can_offshoot then self:attr("can_offshoot", 1) end
	return true
end

local unlearnTalent = _M.unlearnTalent
function _M:unlearnTalent(t_id, ...)
	if not unlearnTalent(self, t_id, ...) then return false end
	local t = _M.talents_def[t_id]
	if t.type[1] == "inscriptions/implants" then self:updateModdableTile() end
	local tt = _M.talents_types_def[t.type[1]]
	if tt and tt.can_offshoot then self:attr("can_offshoot", -1) end
	return true
end

local postUseTalent = _M.postUseTalent
function _M:postUseTalent(ab, ret, silent)
	if not ret then return end

	if self.talent_kind_log then
		if ab.is_steam then self.talent_kind_log.steam = (self.talent_kind_log.steam or 0) + 1 end
	end

	return postUseTalent(self, ab, ret, silent)
end

local getTalentRange = _M.getTalentRange
function _M:getTalentRange(t)
	local r = getTalentRange(self, t)
	if r > 1 and (t.is_spell or t.is_mind) and self:attr("spell_psionic_range_increase") then
		r = math.min(10, r + self.spell_psionic_range_increase)
	end
	return r
end

local paradoxDoAnomaly = _M.paradoxDoAnomaly
function _M:paradoxDoAnomaly(...)
	local ret = paradoxDoAnomaly(self, ...)

	if ret and not game.state.seen_weissi_anomaly_lore and self.player and self.x and self.y and rng.percent(1) then
		game.state.seen_weissi_anomaly_lore = true
		game:onTickEnd(function()
			local o = mod.class.Object.new{
				type = "lore", subtype="lore", not_in_stores=true, no_unique_lore=true,
				unided_name = _t"scroll", identified=true,
				display = "?", color=colors.ANTIQUE_WHITE, image="object/scroll-lore.png",
				encumber = 0,
				checkFilter = function(self) if self.lore and game.party.lore_known and game.party.lore_known[self.lore] then print('[LORE] refusing', self.lore) return false else return true end end,
				desc = _t[[This parchment contains some lore.]],

				name = _t"time-warped paper scrap", lore="orcs-mirror-graynot-3",
				desc = _t[[It came a long way away!]],
				rarity = false,
				encumberance = 0,
			}
			game.level.map:addObject(self.x, self.y, o)
			game.bignews:saySimple(120, "#LIGHT_BLUE#Spacetime shudders for an instant as a note falls out from a different timeline!")
		end)
	end

	return ret
end

--------------------------------------------------------------------------------------------
-- APE
--------------------------------------------------------------------------------------------

local transmoInven = _M.transmoInven
function _M:transmoInven(inven, idx, o, transmo_source)
	transmo_source = transmo_source or self.default_transmo_source
	if (not transmo_source and not self:attr("has_transmo_orcs")) or (transmo_source and transmo_source.define_as ~= "APE") then return transmoInven(self, inven, idx, o, transmo_source) end

	local price = math.min(o:getPrice() * self:transmoPricemod(o), 25) * o:getNumber()
	local price = math.min(o:getPrice() * self:transmoPricemod(o), 25) * o:getNumber()
	price = math.floor(price * 100) / 100 -- Make sure we get at most 2 digit precision
	if price ~= price or not tostring(price):find("^[0-9]") then price = 1 end -- NaN is the only value that does not equals itself, this is the way to check it since we do not have a math.isnan method
	if inven and idx then self:removeObject(inven, idx, true) end

	if o.metallic and o.material_level then
		local id = "LUMP_ORE"..o.material_level
		if game.party.__ingredients_def[id] then
			game.party:collectIngredient(id, o:getNumber())
		end
	elseif o.type == "scroll" and o.subtype == "infusion" and o.material_level_gen_range then
		local lvl = util.bound(rng.range(o.material_level_gen_range.min, o.material_level_gen_range.max), 1, 5)
		local id = "HERBS"..lvl
		if game.party.__ingredients_def[id] then
			game.party:collectIngredient(id, o:getNumber() * 5)
		end
	elseif o.type == "scroll" and o.subtype == "schematic" and o.material_level_gen_range then
		local lvl = util.bound(rng.range(o.material_level_gen_range.min, o.material_level_gen_range.max), 1, 5)
		local id = "HERBS"..lvl
		if game.party.__ingredients_def[id] then
			game.party:collectIngredient(id, o:getNumber() * 2)
		end
	elseif o.type == "weapon" and o.subtype == "mindstar" and o.material_level then
		local id = "HERBS"..o.material_level
		if game.party.__ingredients_def[id] then
			game.party:collectIngredient(id, o:getNumber())
		end
	end

	self:sortInven()
	self:incMoney(price)
	game.log("You gain %0.2f gold from the melting of %s.", price, o:getName{do_count=true, do_color=true})
end

local transmoHelpPopup = _M.transmoHelpPopup
function _M:transmoHelpPopup()
	if not self:attr("has_transmo_orcs") or not self.default_transmo_source or self.default_transmo_source.define_as ~= "APE" then return transmoHelpPopup(self) end
	Dialog:simplePopup(_t"APE", _t"When you close the inventory window, all items in the APE will be melted.")
end

local transmoGetName = _M.transmoGetName
function _M:transmoGetName()
	if not self:attr("has_transmo_orcs") or not self.default_transmo_source or self.default_transmo_source.define_as ~= "APE" then return transmoGetName(self) end
	return "APE"
end

local transmoGetWord = _M.transmoGetWord
function _M:transmoGetWord()
	if not self:attr("has_transmo_orcs") or not self.default_transmo_source or self.default_transmo_source.define_as ~= "APE" then return transmoGetWord(self) end
	return _t"melt down"
end

--------------------------------------------------------------------------------------------
-- Tinkers
--------------------------------------------------------------------------------------------

function _M:getMedicalInjector()
	if not self.medical_injector_config then return end

	local c = self.medical_injector_config
	for i = 1, #c do
		local tid = c[i]
		if not self:isTalentCoolingDown(tid.id) then
			local data = self:getInscriptionData(tid.name)
			return data, tid.id
		end
	end
	return nil
end

function _M:addMedicalInjector(t)
	self.medical_injector_config = self.medical_injector_config or {}
	local c = self.medical_injector_config
	c[#c+1] = {name=t.short_name, id=t.id}
end

function _M:removeMedicalInjector(t)
	self.medical_injector_config = self.medical_injector_config or {}
	local c = self.medical_injector_config
	for i = 1, #c do
		if c[i].name == t.short_name then table.remove(c, i) break end
	end
end

function _M:setFirstMedicalInjector(t)
	self.medical_injector_config = self.medical_injector_config or {}
	local c = self.medical_injector_config
	for i = 1, #c do
		if c[i].name == t.short_name then table.remove(c, i) break end
	end
	table.insert(c, 1, {name=t.short_name, id=t.id})
end

--------------------------------------------------------------------------------------------
-- Cosmetic
--------------------------------------------------------------------------------------------
local MOflipX = _M.MOflipX
function _M:MOflipX(v)
	local oldflip = self._flipx
	MOflipX(self, v)
	
	if v ~= oldflip and self:attr("steam_generator_nb") == 1 then
		self:updateSteamGeneratorParticles()
	end
end

function _M:updateSteamGeneratorParticles()
	local nb = self:attr("steam_generator_nb")
	
	if self.__steam_generator_particles1 then self:removeParticles(self.__steam_generator_particles1) end
	if self.__steam_generator_particles2 then self:removeParticles(self.__steam_generator_particles2) end
	
	if nb == 1 then
		local bx2, by2 = self:attachementSpot("shoulder2", true)
		if bx2 then
			bx2 = bx2 + 0.05
			by2 = by2 - 0.2
			self.__steam_generator_particles1 = self:addParticles(Particles.new("steam_generator_fumes", 1, {x=bx2 * (self._flipx and -1 or 1), y=by2}))
		end
	elseif nb == 2 then
		local bx1, by1 = self:attachementSpot("shoulder1", true)
		local bx2, by2 = self:attachementSpot("shoulder2", true)
		if bx1 then
			bx1 = bx1 - 0.05
			by1 = by1 - 0.2
			self.__steam_generator_particles1 = self:addParticles(Particles.new("steam_generator_fumes", 1, {x=bx1, y=by1}))
		end
		if bx2 then
			bx2 = bx2 + 0.05
			by2 = by2 - 0.2
			self.__steam_generator_particles2 = self:addParticles(Particles.new("steam_generator_fumes", 1, {x=bx2, y=by2}))
		end
	end
end


return _M
