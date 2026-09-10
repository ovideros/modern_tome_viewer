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
local Stats = require "engine.interface.ActorStats"

demon_seeds_effects = {
	----------------------------------------------------------------------------
	-- Common demons
	----------------------------------------------------------------------------
	["fire imp"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_FIRE_BOLTS] = math.ceil(lvl/10)}
		end,
		OFFHAND = function(self, t, o, host, lvl)
			local v = math.ceil(lvl/2)
			o.object_tinker.wielder.resists = {[DamageType.FIRE] = 10 + v, [DamageType.BLIGHT] = 10 + v, [DamageType.PHYSICAL] = 10 + v}
			o.object_tinker.wielder.flat_damage_armor = {[DamageType.FIRE] = v, [DamageType.BLIGHT] = v, [DamageType.PHYSICAL] = v}
		end,
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_FIERY_CLEANSING] = math.ceil(lvl/10)}
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_regen_when_hit = 2
		end,
	},
	["wretchling"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_CORROSIVE_SLASHES] = math.ceil(lvl/10)}
		end,
		OFFHAND = function(self, t, o, host, lvl)
			local v = math.ceil(lvl/2)
			o.object_tinker.wielder.resists = {[DamageType.ACID] = 10 + v, [DamageType.DARKNESS] = 10 + v, [DamageType.BLIGHT] = 10 + v}
			o.object_tinker.wielder.flat_damage_armor = {[DamageType.ACID] = v, [DamageType.DARKNESS] = v, [DamageType.BLIGHT] = v}
		end,
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_ACIDIC_BATH] = math.ceil(lvl/10)}
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_regen_when_hit = 2
		end,
	},
	["quasit"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_FARSTRIKE] = math.ceil(lvl/10)}
		end,
		OFFHAND = function(self, t, o, host, lvl)
			local v = math.ceil(lvl/2)
			o.object_tinker.wielder.resists_pen = {[DamageType.ACID] = v, [DamageType.PHYSICAL] = v, [DamageType.BLIGHT] = v}
			o.object_tinker.wielder.inc_damage = {[DamageType.ACID] = 7 + v, [DamageType.PHYSICAL] = 7 + v, [DamageType.BLIGHT] = 7 + v}
		end,
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_OVERPOWER] = math.ceil(lvl/10)}
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_regen_when_hit = 3
		end,
	},
	["water imp"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_FROST_GRAB] = math.ceil(lvl/10)}
		end,
		OFFHAND = function(self, t, o, host, lvl)
			local v = math.ceil(lvl/2)
			o.object_tinker.wielder.resists_pen = {[DamageType.DARKNESS] = v, [DamageType.FIRE] = v, [DamageType.BLIGHT] = v}
			o.object_tinker.wielder.inc_damage = {[DamageType.DARKNESS] = 7 + v, [DamageType.FIRE] = 7 + v, [DamageType.BLIGHT] = 7 + v}
		end,
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_BLACKICE] = math.ceil(lvl/10)}
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_regen_when_hit = 3
		end,
	},
	["onilug"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_CURSED_ARM] = math.ceil(lvl/10)}
		end,
		OFFHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_HEXED_SHIELD] = math.ceil(lvl/10)}
		end,
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.teleport_immune = math.ceil(math.scale(lvl, 1, 50, 25, 100)) / 100
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_on_melee = 1
		end,
	},
	["dolleg"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.talent_level = math.ceil(lvl/10)
			o.on_tinker = function(self, o, who)
				if not o.combat then return true end
				o.combat.talent_on_hit = o.combat.talent_on_hit or {}
				o.combat.talent_on_hit.T_BLOOD_SPRAY = {level=self.talent_level, chance=13}
			end
			o.on_untinker = function(self, o, who)
				if not o.combat or not o.combat.talent_on_hit then return true end
				o.combat.talent_on_hit.T_BLOOD_SPRAY = nil
			end
			o.special_desc_demon = function(self) return ("13%% chance to trigger a Blood Spray cast of level %d"):tformat(self.talent_level) end
		end,
		OFFHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_PAIN_AFFINITY] = math.ceil(lvl/10)}
		end,
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_BLIGHTED_PATH] = math.ceil(lvl/10)}
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_on_melee = 1
		end,
	},
	["dúathedlen"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_CORRUPT_LIGHT] = math.ceil(lvl/10)}
		end,
		OFFHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.esp = { demon = 1 }
			if lvl > 20 then o.object_tinker.wielder.esp.humanoid = 1 end
			if lvl >= 50 then o.object_tinker.wielder.esp = nil o.object_tinker.wielder.esp_all = 1 end
		end,
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_SHADOWMELD] = math.ceil(lvl/10)}
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_on_melee = 1
		end,
	},
	["uruivellas"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DISARM] = math.ceil(lvl/10)}
		end,
		OFFHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_DOOM_STORM] = math.ceil(lvl/10)}
		end,
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.global_speed_add = 0.1 + math.ceil(lvl/6) / 100
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_on_melee = 2
		end,
	},
	["thaurhereg"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_SILENCE] = math.ceil(lvl/10)}
		end,
		OFFHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_BLOOD_SHIELD] = math.ceil(lvl/10)}
		end,
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.silence_immune = math.ceil(math.scale(lvl, 1, 50, 25, 100)) / 100
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_on_melee = 2
		end,
	},
	["daelach"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_DOOM_TENDRILS] = math.ceil(lvl/10)}
		end,
		OFFHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_FIERY_PORTAL] = math.ceil(lvl/10)}
		end,
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.stun_immune = math.ceil(math.scale(lvl, 1, 50, 25, 100)) / 100
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_on_melee = 3
		end,
	},
	["wretch titan"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_ACID_CONE] = math.ceil(lvl/10)}
		end,
		OFFHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_ACID_BURST] = math.ceil(lvl/10)}
		end,
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.ignore_direct_crits = math.ceil(math.scale(lvl, 1, 50, 10, 35))
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_on_melee = 3
		end,
	},
	["champion of Urh'Rok"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_DOOMED_NATURE] = math.ceil(lvl/10)}
		end,
		OFFHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_ARMOURED_LEVIATHAN] = math.ceil(lvl/10)}
		end,
		BODY = function(self, t, o, host, lvl)
			local stats = math.ceil(lvl / 10)*5
			o.object_tinker.wielder.max_life = 4 * lvl
			o.object_tinker.wielder.inc_stats = { [Stats.STAT_MAG] = stats, [Stats.STAT_STR] = stats }
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_regen = math.ceil(lvl/15)
			o.object_tinker.wielder.stamina_regen = math.ceil(lvl/15) * 1.3
			o.object_tinker.wielder.learn_talent = {[self.T_BLOODCASTING] = math.ceil(lvl/10)}
		end,
	},
	["forge-giant"] = {
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_DOOMFIRE] = math.ceil(lvl/10)}
		end,
		OFFHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_FLASH_BLOCK] = math.ceil(lvl/10)}
		end,
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.reduce_detrimental_status_effects_time = 40
			o.special_desc_demon = function(self) return _t"Reduces duration of detrimental effects by 40%" end
		end,
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.vim_regen = math.ceil(lvl/15)
			o.object_tinker.wielder.stamina_regen = math.ceil(lvl/15) * 1.3
			o.object_tinker.wielder.learn_talent = {[self.T_BLOODCASTING] = math.ceil(lvl/10)}
		end,
	},

	----------------------------------------------------------------------------
	-- Unique demons
	----------------------------------------------------------------------------

	["Walrog"] = { force_slot = "FINGER",
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_FROSTFIRE_NOVA] = 5}
		end,
	},
	["Corrupted Daelach"] = { force_slot = "MAINHAND",
		MAINHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_FETID_BREATH] = 5}
		end,
	},
	["Kryl-Feijan"] = { force_slot = "FINGER",
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_BLOOD_DRINKER] = 5}
		end,
	},
	["Planar Controller"] = { force_slot = "OFFHAND",
		OFFHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_FEARSCAPE_SHIFT] = 3}
		end,
	},
	["Khulmanar, General of Urh'Rok"] = { force_slot = "OFFHAND",
		OFFHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_INFERNAL_BREATH] = 3}
		end,
	},
	["Shasshhiy'Kaish"] = { force_slot = "OFFHAND",
		OFFHAND = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_METEOR_SLAM] = 5}
		end,
	},
	["Draebor, the Imp"] = { force_slot = "FINGER",
		FINGER = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_BLAZING_PHASE] = 5}
		end,
	},
	["Rogroth, Eater of Souls"] = { force_slot = "BODY",
		BODY = function(self, t, o, host, lvl, demon)
			demon:unlearnTalent(demon.T_DEMON_SOUL_EATER, 9999)
			o.on_tinker = function(self, o, who)
				if not o.talents_add_levels_filters then o.talents_add_levels_filters = {} end
				table.insert(o.talents_add_levels_filters,
					{desc=_t"+2 to all Demon Seeds, Spellblaze and Demonic Pact talents", filter=function(who, t, lvl)
						if t.type[1] == "corruption/demon-seeds" or t.type[1] == "corruption/demonic-pact" or t.type[1] == "corruption/spellblaze" then
							return lvl + 2
						end
					end, rogroth_marker=true}
				)
			end
			o.on_untinker = function(self, o, who)
				if not o.talents_add_levels_filters then return end
				for i, d in ripairs(o.talents_add_levels_filters) do
					if d.rogroth_marker then table.remove(o.talents_add_levels_filters, i) end
				end
			end
			o.special_desc_demon = function(self) return _t"+2 to all Demon Seeds, Spellblaze and Demonic Pact talents" end
		end,
	},
	["Lithfengel"] = { force_slot = "BODY",
		BODY = function(self, t, o, host, lvl)
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_DISEASED_BODY] = 5}
			o.object_tinker.wielder.disease_immune = util.bound(lvl / 100, 0, 0.5) + 0.5
		end,
	},
	["Harkor'Zun"] = { force_slot = "BODY",
		BODY = function(self, t, o, host, lvl)
			local v = math.ceil(lvl/2)
			o.object_tinker.wielder.resists = {[DamageType.FIRE] = 10 + v, [DamageType.PHYSICAL] = 10 + v}
			o.object_tinker.wielder.learn_talent = {[self.T_DEMON_SEED_VOLCANIC_SKIN] = 5}
		end,
	},
}

local seeds = {
	[1] = {"fire imp", "wretchling"},
	[2] = {"quasit", "water imp"},
	[3] = {"dolleg", "dúathedlen", "onilug"},
	[4] = {"uruivellas", "thaurhereg"},
	[5] = {"daelach", "wretch titan"},
	[6] = {"forge-giant", "champion of Urh'Rok"},
}
demon_seeds_tiers = seeds

local demons = nil
local seeds_list_hooked = false

availableDemonSeed = function(self, t, use_all, filter)
	local list = {}
	if use_all then
		self:inventoryApplyAll(function(inven, item, o)
			if o.tinker and o.tinker.is_tinker == "demon-seed" and (not o.tinker.demon.dead or o.tinker.demon.dead_by_unsummon) and game.level and not game.level:hasEntity(o.tinker.demon) and (not filter or filter(o.tinker.demon)) then
				list[#list+1] = {name=("%s (%d/%d life, level %d)"):tformat(o.tinker.demon:getName(), o.tinker.demon.life, o.tinker.demon.max_life, o.tinker.demon.level), demon=o.tinker.demon}
			elseif o.is_tinker == "demon-seed" and (not o.demon.dead or o.demon.dead_by_unsummon) and game.level and not game.level:hasEntity(o.demon) and (not filter or filter(o.demon)) then
				list[#list+1] = {name=("%s (%d/%d life, level %d)"):tformat(o.demon:getName(), o.demon.life, o.demon.max_life, o.demon.level), demon=o.demon}
			end
		end)
	else
		self:inventoryApplyAll(function(inven, item, o) if o.tinker and o.tinker.is_tinker == "demon-seed" then
			if inven.worn and (not o.tinker.demon.dead or o.tinker.demon.dead_by_unsummon) and game.level and not game.level:hasEntity(o.tinker.demon) and (not filter or filter(o.tinker.demon)) then
				list[#list+1] = {name=("%s (%d/%d life, level %d)"):tformat(o.tinker.demon:getName(), o.tinker.demon.life, o.tinker.demon.max_life, o.tinker.demon.level), demon=o.tinker.demon}
			end
		end end)
	end
	return #list > 0, list
end

createSeed = function(self, t, host, force_first)
	if not demons then
		local t = mod.class.NPC:loadList{"/data/general/npcs/minor-demon.lua", "/data/general/npcs/major-demon.lua", "/data/general/npcs/aquatic_demon.lua"}
		demons = {}
		for i, d in ipairs(t) do
			if d.name then demons[d.name] = d end
		end
	end

	local mlvl = util.bound(math.floor(self:getTalentLevel(t)), 1, 6)
	local lvl = mlvl
	if rng.percent(75) then lvl = rng.range(1, mlvl) end

	local slot = rng.table(table.keys(self.tinker_restrict_slots))
	local kind
	if force_first then slot = "MAINHAND" end
	-- slot = "BODY" -- TEST! DISABLE!

	if host.type == "demon" then
		kind = host.name
		if not demon_seeds_effects[kind] then kind = rng.table(seeds[lvl]) end
	else
		kind = rng.table(seeds[lvl])
	end
	if force_first then kind = "fire imp" end
	-- kind = "dolleg" -- TEST! DISABLE!
	if not demon_seeds_effects[kind] then return end

	if demon_seeds_effects[kind].force_slot then slot = demon_seeds_effects[kind].force_slot end

	local hlevel = util.bound(host.level, 1, 50)

	local function makeSeed()
		local demon = demons[kind]
		if not demon and demon_seeds_effects[kind] then demon = host end
		if not demon then demon = demons["fire imp"] end
		demon = demon:cloneFull()
		demon:resolve()
		demon:resolve(nil, true)
		demon.make_escort = nil
		demon.summon = nil
		demon.life = demon.max_life
		demon.no_drops = true
		demon.exp_worth = 0
		demon:forceLevelup(hlevel)
		demon.levelup = function() end
		demon.forceLevelup = function() end
		if demon.level > hlevel then
			local diff = demon.level - hlevel
			demon.generic_damage_penalty = 50 * diff / demon.level
			demon._seed_dam_penalty_tmp = demon:addTemporaryValue("generic_damage_penalty", 50 * diff / demon.level)
			demon._seed_life_penalty_tmp = demon:addTemporaryValue("max_life", -demon.max_life * (60 * diff / demon.level) / 100)
			demon._seed_level_orig = demon.level
			demon.level = hlevel
			demon.life = demon.max_life
		end

		local add_mos = nil
		local image = "object/demon_seeds/seed_"..tostring(demon.type or "unknown").."_"..tostring(demon.subtype or "unknown"):lower():gsub("[^a-z0-9]", "_").."_"..(demon.name or "unknown"):lower():gsub("[^a-z0-9]", "_")..".png"
		if not fs.exists("/data/gfx/shockbolt/"..image) then
			image = demon.image
			add_mos = demon.add_mos
		end

		local o = mod.class.Object.new{
			power_source = {arcane=true},
			type = "seed", subtype = "demon",
			identified=true, no_unique_lore = true,
			name = _t"demon seed", display = '*', color=colors.RED, unique=true,
			add_name = " #DEMON_SEED#",
			image = image, add_mos = add_mos,
			desc = _t[[The seed of a demon.]],
			cost = 0, encumber = 0,
			is_tinker = "demon-seed",
			rarity = false,
			on_slot = slot,
			material_level = util.bound(math.ceil(hlevel / 10), 1, 5),
			demon = demon,
			object_tinker = { wielder = {} },
			special_desc = function(self)
				local desc = ("Demon status: %s."):tformat((not self.demon.dead or self.demon.dead_by_unsummon) and ("alive (%d%% life)"):tformat(100*self.demon.life/self.demon.max_life) or _t"dead (can not be summoned)")
				if self.special_desc_demon then desc = self:special_desc_demon().."\n"..desc end
				return desc
			end,
			getSubtypeOrder = function(self) return self.on_slot..tostring(self.demon.name) end,
		}
		if demon_seeds_effects[kind] and demon_seeds_effects[kind][slot] then
			demon_seeds_effects[kind][slot](self, t, o, host, hlevel, demon)
		end
		return o
	end

	local function updateSeed(o)
		local demon = o.demon
		local hlevel = math.max(hlevel, demon.level)

		-- Get current life %
		local life_p = math.ceil(100 * demon.life / demon.max_life)

		-- Reset maluses
		if demon._seed_dam_penalty_tmp then demon:removeTemporaryValue("generic_damage_penalty", demon._seed_dam_penalty_tmp) demon._seed_dam_penalty_tmp = nil end
		if demon._seed_life_penalty_tmp then demon:removeTemporaryValue("max_life", demon._seed_life_penalty_tmp) demon._seed_life_penalty_tmp = nil end
		if demon._seed_level_orig then demon.level = demon._seed_level_orig demon._seed_level_orig = nil end

		-- Update the demon
		demon.dead = nil
		demon.dead_by_unsummon = nil
		demon.levelup = nil
		demon.forceLevelup = nil
		demon:forceLevelup(hlevel)
		demon.levelup = function() end
		demon.forceLevelup = function() end
		if demon.level > hlevel then
			local diff = demon.level - hlevel
			demon.generic_damage_penalty = 50 * diff / demon.level
			demon._seed_dam_penalty_tmp = demon:addTemporaryValue("generic_damage_penalty", 50 * diff / demon.level)
			demon._seed_life_penalty_tmp = demon:addTemporaryValue("max_life", -demon.max_life * (60 * diff / demon.level) / 100)
			demon._seed_level_orig = demon.level
			demon.level = hlevel
		end
		demon.life = demon.max_life * life_p / 100
		demon:heal(t:_getHeal(self), self)

		o.material_level = util.bound(math.ceil(hlevel / 10), 1, 5)
		o.object_tinker = {wielder={}}
		o.talent_level = nil
		o.on_tinker = nil
		o.on_untinker = nil
		o.special_desc_demon = nil
		if demon_seeds_effects[kind] and demon_seeds_effects[kind][slot] then
			demon_seeds_effects[kind][slot](self, t, o, host, hlevel, demon)
		end
	end

	local found, found_inven, found_item, found_in = false, false, false, false
	local function checkSeed(o)
		if o.type == "seed" and o.subtype == "demon" and o.demon then
			print("Testing inferior demon", o.demon.name, o.demon.level, "against trying to make", kind, hlevel)
			if o.demon.name == kind and o.on_slot == slot then
				return true
			end
		end
	end
	self:inventoryApplyAll(function(inven, item, o)
		if checkSeed(o) then found_inven, found_item, found, found_in = inven, item, o, false
		elseif o.tinker and checkSeed(o.tinker) then found_inven, found_item, found, found_in = inven, item, o.tinker, o
		end
	end)

	-- This kind/slot combo didnt exist, we create it
	if not found then
		local o = makeSeed()
		local attach_inven, attach_item, free = self:findTinkerSpot(o)
		local worn, base_o = false, nil
		if attach_inven and attach_item and free then
			self:attr("free_tinker_attach", 1)
			worn, base_o = self:doWearTinker(nil, nil, o, attach_inven, attach_item, nil, false)
			self:attr("free_tinker_attach", -1)
		end
		
		if not worn then
			self:addObject("INVEN", o)
			self:sortInven()		
			game.logPlayer(self, "#CRIMSON#You extract a %s and add it to your inventory.", o:getName{do_color=true})
		else
			game.logPlayer(self, "#CRIMSON#You extract a %s and bind it to your %s.", o:getName{do_color=true}, base_o:getName{do_color=true})
		end
	-- Kind/slot combo existed, we upgrade it, if possible
	else
		local was_worn, was_tinkered = false, false

		self:attr("save_cleanup", 1)

		local resustains = {}
		if found.object_tinker and found.object_tinker.wielder and found.object_tinker.wielder.learn_talent then
			for tid, lvl in pairs(found.object_tinker.wielder.learn_talent) do
				local st = self:getTalentFromId(tid)
				if st.mode == "sustained" and self:isTalentActive(tid) then resustains[#resustains+1] = tid end
			end
		end

		if found_in and found_in.wielded then
			was_worn = true
			self:onTakeoff(found_in, found_inven, true)
		end
		if found_in then
			was_tinkered = true
			self:doTakeoffTinker(found_in, found, true)
		end

		updateSeed(found)

		if was_tinkered then
			self:attr("free_tinker_attach", 1)
			self:doWearTinker(nil, nil, found, found_inven, found_item, nil, false)
			self:attr("free_tinker_attach", -1)
		end
		if was_worn then
			self:onWear(found_in, found_inven, true)
		end

		for _, tid in ipairs(resustains) do
			if not self:isTalentActive(tid) then
				self:forceUseTalent(tid, {ignore_energy=true, ignore_ressources=true, ignore_cooldown=true, no_talent_fail=true})
				self.talents_cd[tid] = nil
			end
		end
		self:attr("save_cleanup", -1)

		game.logPlayer(self, "#CRIMSON#You feed vim into your %s, increasing its level to %d and healing it.", found:getName{do_color=true}, found.demon.level)
	end

	if self.player then world:gainAchievement("ASHES_SEED_500", self) end
end

local function seed_gfx_update(self)
	local body = self:getInven("BODY") and self:getInven("BODY")[1] or false
	local mh = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1] or false
	local oh = self:getInven("OFFHAND") and self:getInven("OFFHAND")[1] or false
	if body then body = body.tinker and body.tinker.is_tinker == "demon-seed" and true or false end
	if mh then mh = mh.tinker and mh.tinker.is_tinker == "demon-seed" and true or false end
	if oh then oh = oh.tinker and oh.tinker.is_tinker == "demon-seed" and true or false end

	local img = nil
	if body and mh and oh then img = "demon_seeds_all"
	elseif body and not mh and not oh then img = "demon_seeds_body"
	elseif not body and not mh and oh then img = "demon_seeds_lh"
	elseif not body and mh and not oh then img = "demon_seeds_rh"
	elseif body and not mh and oh then img = "demon_seeds_lh_body"
	elseif body and mh and not oh then img = "demon_seeds_rh_body"
	elseif not body and mh and oh then img = "demon_seeds_lh_rh"
	end

	if self._demonseed_gfx then
		self:removeParticles(self._demonseed_gfx)
		self._demonseed_gfx = nil
	end

	if img and core.shader.active() then
		self._demonseed_gfx = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1, img=img}, {type="tentacles", appearTime=0.6, time_factor=1000, noup=0.0}))
	end
end

newTalent{
	name = "Demon Seed",
	type = {"corruption/demonic-pact", 1},
	require = {
		stat = { mag=function(level) return 12 + (level-1) * 2 end },
		level = function(level) return 0 + (level-1) * 6  end,
	},
	points = 5,
	vim = 5,
	stamina = 8,
	cooldown = 8,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = 2, DISABLE = { daze = 1 } },
	getDam = function(self, t) return self:combatTalentWeaponDamage(t, 0.6, 1.4, self:getTalentLevel(self.T_SHIELD_EXPERTISE)), self:combatTalentWeaponDamage(t, 0.6, 1.6) end,
	getDazeDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	getHeal = function(self, t) return math.floor(self:combatTalentScale(t, 10, 30)) end,
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "You require a weapon and a shield to use this talent.") end return false end return true end,
	createSeed = createSeed,
	demon_seeds_tiers = demon_seeds_tiers,
	demon_seeds_effects = demon_seeds_effects,
	callbackOnWearTinker = seed_gfx_update,
	callbackOnTakeoffTinker = seed_gfx_update,
	on_learn = function(self, t)
		local lvl = self:getTalentLevelRaw(t)
		if lvl == 1 then
			self.can_tinker = self.can_tinker or {}
			self.can_tinker["demon-seed"] = 1
			self.tinker_restrict_slots = { MAINHAND=1 }
		end
	end,
	on_unlearn = function(self, t)
		local lvl = self:getTalentLevelRaw(t)
		if lvl == 0 then
			self.can_tinker["demon-seed"] = nil
			self.tinker_restrict_slots.MAINHAND = nil
		end
	end,
	action = function(self, t)
		if not seeds_list_hooked then
			seeds_list_hooked = true
			self:triggerHook{"DemonicPact:updateSeedsList", demon_seeds_tiers=t.demon_seeds_tiers, demon_seeds_effects=demon_seeds_effects}
		end

		local shield, shield_combat = self:hasShield()
		if not shield then return nil end

		local tg = {type="hit", range=1}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local shielddam, weapondam = t.getDam(self, t)

		local hit = self:attackTarget(target, DamageType.BLIGHT, weapondam, true)

		if hit then
			-- We dont want the player to end up with a demon seed!
			local chance = 100
			if target.rank <= 2 then chance = 5
			elseif target.rank <= 3 then chance = 20
			elseif target.rank <= 3.5 then chance = 50
			end
			if config.settings.cheat then chance = 100 end

			-- First time it always works
			if not self:attr("used_demon_seed") then chance = 100 end

			if self.player and not target.demonic_summon and target.exp_worth > 0 and not game.party:hasMember(target) then
				if target.dead then
					if rng.percent(chance) then
						createSeed(self, t, target, not self:attr("used_demon_seed"))
						game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, a=90, limit_life=8, shader=true, appear=8, speed=2, img="blood_circle", radius=self:getTalentRadius(t)})
						self:attr("used_demon_seed", 1)
					end
				else
					target:setEffect(target.EFF_DEMON_SEED, 1, {src=self, power=self:getTalentLevel(t), chance=chance, force_first=not self:attr("used_demon_seed")})
					game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, a=90, limit_life=8, shader=true, appear=8, speed=2, img="blood_circle", radius=self:getTalentRadius(t)})
					self:attr("used_demon_seed", 1)
				end
			end

			local speed, hit2 = self:attackTargetWith(target, shield_combat, nil, shielddam) 
			if hit2 and target:canBe("stun") then target:setEffect(target.EFF_DAZED, t.getDazeDuration(self, t), {apply_power=self:combatSpellpower()}) end
		end

		game.level.map:particleEmitter(x, y, 1, "circle", {shader=true, oversize=1, a=120, appear=8, limit_life=14, speed=0, base_rot=180, img="demon_seed", radius=0})

		return true
	end,
	info = function(self, t)
		local _, color_normal = self:textRank(2)
		local _, color_elite = self:textRank(3)
		local _, color_rare = self:textRank(3.2)
		local _, color_unique = self:textRank(3.5)
		local _, color_boss = self:textRank(4)

		local shield, weapon = t.getDam(self, t)
		return ([[Strike a blow with your weapon for %d%% blight damage.
		If the attack hits a demonic seed tries to take hold inside your foe and you follow up with a shield strike dealing %d%% damage and dazing your target for %d turns.
		
		The seed requires a powerful host to nourish it and can only take hold in creatures that are worth experience and that are not summoned demons.
		The chance for the seed to take hold is based on the creatures rank:
		%sNormal#LAST#:  5%%
		%sElite#LAST#:  20%%
		%sRare#LAST# or %sUnique#LAST#:  50%%
		%sBoss#LAST#:  100%%
		When the host dies the seed fills with the vim of the dying creature and turns into a specific demon seed that can be used to summon that demon.
		If you already have a seed of the same time in your inventory or equipment it will instead increase its level if the host was of higher level than the seed and the demon inside will regenerate %d%% health and resurrect if it was dead.

		Higher talent levels allow for more powerful demon types.
		Implanting a seed into unique demons, if successful, will always try to grant a seed of that type, if available.]])
		:tformat(weapon * 100, shield * 100, t.getDazeDuration(self, t), color_normal, color_elite, color_rare, color_unique, color_boss, t:_getHeal(self))
	end,
}

local function listPopup(title, text, list, w, h, fct)
	local chars = {}
	for i = 1, #list do list[i].name = Dialog:makeKeyChar(i)..") "..list[i].name chars[Dialog:makeKeyChar(i)] = i end

	local d = Dialog.new(title, 1, 1)
	local desc = require("engine.ui.Textzone").new{width=w, auto_height=true, text=text, scrollbar=true}
	local l = require("engine.ui.List").new{width=w, height=h-16 - desc.h, list=list, fct=function() d.key:triggerVirtual("ACCEPT") end}
	d:loadUI{
		{left = 3, top = 3, ui=desc},
		{left = 3, top = 3 + desc.h + 3, ui=require("engine.ui.Separator").new{dir="vertical", size=w - 12}},
		{left = 3, bottom = 3, ui=l},
	}
	d.key:addBind("EXIT", function() if fct then fct() end game:unregisterDialog(d) end)
	d.key:addBind("ACCEPT", function() if list[l.sel].fct then list[l.sel].fct(list[l.sel]) return end if fct then fct(list[l.sel]) end game:unregisterDialog(d) end)
	d.key:addCommands{
		__TEXTINPUT = function(c)
			if chars[c] then
				l.sel = chars[c]
				d.key:triggerVirtual("ACCEPT")
			end
		end,
	}
	d.on_register = function(self) game:onTickEnd(function() self.key:unicodeInput(true) end) end
	d:setFocus(l)
	d:setupUI(true, true)
	game:registerDialog(d)
	return d
end


newTalent{
	name = "Bind Demon",
	type = {"corruption/demonic-pact", 2},
	require = corrs_req2,
	no_unlearn_last = true,
	points = 5,
	vim = 25,
	cooldown = 30,
	getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 4, 12)) end,
	on_learn = function(self, t)
		local lvl = self:getTalentLevelRaw(t)
		if lvl == 1 then
			-- self.tinker_restrict_slots = {MAINHAND = 1}
			if not self.tinker_restrict_slots then self.tinker_restrict_slots = {} end
		elseif lvl == 2 then
			self.tinker_restrict_slots.FINGER = 1
		elseif lvl == 3 then
			self.tinker_restrict_slots.OFFHAND = 1
		elseif lvl == 4 then
			self.tinker_restrict_slots.FINGER = 2
		elseif lvl == 5 then
			self.tinker_restrict_slots.BODY = 1
		end
	end,
	on_unlearn = function(self, t)
		local lvl = self:getTalentLevelRaw(t)
		if lvl == 0 then
			-- self.tinker_restrict_slots = {}
			if table.keys(self.tinker_restrict_slots) == 0 then self.tinker_restrict_slots = nil end
		elseif lvl == 1 then
			self.tinker_restrict_slots.FINGER = nil
		elseif lvl == 2 then
			self.tinker_restrict_slots.OFFHAND = nil
		elseif lvl == 3 then
			self.tinker_restrict_slots.FINGER = 1
		elseif lvl == 4 then
			self.tinker_restrict_slots.BODY = nil
		end
	end,
	on_pre_use = function(self, t) return availableDemonSeed(self, t, true) end,
	action = function(self, t)
		local _, list = availableDemonSeed(self, t, true)
		if #list == 0 then return nil end
		local seeds = {}
		for tier, demons in pairs(demon_seeds_tiers) do for _, demon in ipairs(demons) do seeds[demon] = tier end end
		table.sort(list, function(a, b)
			local at = a.demon.unique and 7 or seeds[a.demon.name] or 0
			local bt = b.demon.unique and 7 or seeds[b.demon.name] or 0
			if at == bt then return a.demon.level > b.demon.level
			else return at > bt end
		end)

		local demon
		if #list == 1 then
			demon = list[1].demon
		else
			demon = self:talentDialog(listPopup(_t"Summon demon", _t"Which seed to use:", list, 500, 400, function(d)
				if not d then return end
				self:talentDialogReturn(d.demon)
			end))
			if not demon then return nil end
		end

		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		demon.summon_time = t.getDur(self, t)
		demon.ai_target = {actor=target}

		setupDemonSummon(self, demon, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Your knowledge of demonic forces grows, allowing you to bind more seeds to you and to summon demons.
		You channel your arcane corruption through a demon seed to temporarily summon the corresponding demon for %d turns.
		Summoned demons can regen their life and resummoning them keeps the life they had when they were last used.
		If the demon dies it will not be available for summoning anymore until resurrected.
		This spell can summon demons from any seeds available in either your equipment or inventory.

		As you learn to bind more easily you can also use more seeds:
		At level 2 it lets you bind a seed to your first ring.
		At level 3 it lets you bind a seed to your shield.
		At level 4 it lets you bind a seed to your second ring.
		At level 5 it lets you bind a seed to your main body armour.
		]]):
		tformat(t.getDur(self, t))
	end,
}

newTalent{
	name = "Twisted Portal",
	type = {"corruption/demonic-pact", 3},
	require = corrs_req3,
	points = 5,
	vim = 15,
	cooldown = 9,
	getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 5)) end,
	tactical = { ESCAPE = 2 },
	requires_target = function(self, t) return self:getTalentLevel(t) >= 4 end,
	getRange = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 10, 15), 40, 4, 0, 13.4, 9.4) end, -- Limit to range 40
	getRadius = function(self, t) return math.floor(self:combatTalentLimit(t, 0, 7, 3)) end, -- Limit to radius 0	
	is_teleport = true,
	on_pre_use = function(self, t) return availableDemonSeed(self, t, false) end,
	action = function(self, t)
		local _, list = availableDemonSeed(self, t, false)
		if #list == 0 then return nil end

		local x, y = self.x, self.y
		local rad = t.getRange(self, t)
		local radius = t.getRadius(self, t)
		game.logPlayer(self, "Select a teleport location...")
		local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=rad, radius=radius, requires_knowledge=false}
		x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code does not restrict the self coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)
		rad = radius

		-- Check LOS
		if not self:hasLOS(x, y) and rng.percent(35 + (game.level.map.attrs(self.x, self.y, "control_teleport_fizzle") or 0)) then
			game.logPlayer(self, "The targetted phase door fizzles and works randomly!")
			x, y = self.x, self.y
			rad = t.getRange(self, t)
		end

		local ox, oy = self.x, self.y
		game.level.map:particleEmitter(self.x, self.y, 1, "demon_teleport")
		self:teleportRandom(x, y, rad)
		game.level.map:particleEmitter(self.x, self.y, 1, "demon_teleport")

		if not game.level.map(ox, oy, Map.ACTOR) then
			local demon = rng.table(list).demon
			demon.summon_time = t.getDur(self, t)
			demon.ai_target = {}
			setupDemonSummon(self, demon, ox, oy)
		end

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local range = t.getRange(self, t)
		return ([[Teleports you randomly within a small range of up to %d grids with %d precision.
		In the spot you left you will summon a random demon from your seeds for %d turns.
		If the target area is not in line of sight, there is a chance the spell will fizzle.
		This spell requires an unsummoned, alive, demon seed equiped in a worn equipment to work.
		The range will increase with your Spellpower.]]):tformat(range, radius, t.getDur(self, t))
	end,
}

newTalent{
	name = "Doom Concordat", short_name = "SUFFUSE_LIFE",
	type = {"corruption/demonic-pact", 4},
	require = corrs_req4,
	points = 5,
	mode = "passive",
	getDemonHeal = function(self, t) return	self:combatTalentScale(t, 2, 10) end,
	getHeal = function(self, t) return 15 + self:combatTalentSpellDamage(t, 10, 150) end,
	getDur = function(self, t) return math.ceil(self:combatTalentScale(t, 3, 8)) end,
	callbackOnKill = function(self, t, target)
		local healpct = t.getDemonHeal(self, t)

		-- Heal
		local list = {}
		self:inventoryApplyAll(function(inven, item, o) if o.tinker and o.tinker.is_tinker == "demon-seed" then
			if (not o.tinker.demon.dead or o.tinker.demon.dead_by_unsummon) and o.tinker.demon.life < o.tinker.demon.max_life then
				list[#list+1] = {name=o.tinker:getName{do_color=true}:toString(), demon=o.tinker.demon}
			end
		end end)
		if #list > 0 then
			local demon = rng.table(list).demon
			demon:heal(demon.max_life * healpct / 100)
			game.logPlayer(self, "#CRIMSON#Your %s is healed!", _t(demon.name, "entity name"))
		end

		-- Rez
		if target.rank >= 3 then
			local list = {}
			self:inventoryApplyAll(function(inven, item, o) print("====", o.name, o.tinker) if o.tinker and o.tinker.is_tinker == "demon-seed" then
				print(" =>?", o.tinker.demon.dead, o.tinker.demon.dead_by_unsummon)
				if o.tinker.demon.dead and not o.tinker.demon.dead_by_unsummon then
				print(" => ok")
					list[#list+1] = {name=o.tinker:getName{do_color=true}:toString(), demon=o.tinker.demon}
				end
			end end)
			if #list > 0 then
				local demon = rng.table(list).demon
				demon.dead = nil
				demon.life = demon.max_life * 0.15
				game.logPlayer(self, "#CRIMSON#Your %s is brought back to life!", _t(demon.name, "entity name"))
				game.level.map:particleEmitter(self.x, self.y, 1, "circle", {oversize=1.3, a=230, grow=true, limit_life=22, y=-0.2, speed=0, base_rot=0, img="suffuse_life", radius=0})
			end
		end
	end,
	callbackOnCombat = function(self, t, state)
		if not state then return end

		if not game.party or not game.party:hasMember(self) then
			for _, act in pairs(game.level.entities) do if act.summoner == self and act.demonic_summon and act.from_doom_concordat then
				return
			end end
		else
			for act, _ in pairs(game.party.members) do if act.summoner == self and act.demonic_summon and act.from_doom_concordat then
				return
			end end
		end

		local _, list = availableDemonSeed(self, t, false, function(demon) return demon.life > demon.max_life * 0.7 end)
		if #list == 0 then return nil end

		local demon = rng.table(list).demon
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end
		demon.summon_time = t:_getDur(self)
		setupDemonSummon(self, demon, x, y)

		-- This is autocleaned by setupDemonSummon
		demon.from_doom_concordat = true
	end,
	onDemonHeal = function(self, t, demon)
		self:heal(t:_getHeal(self), demon)
	end,
	info = function(self, t)
		local healpct = t.getDemonHeal(self, t)
		return ([[You use your demon seeds to the fullest of their potential.
		Each time you enter combat you automatically summon a random demon from your worn seeds for %d turns. Demons are only summoned if their life is over 70%% and only if not other summoned demon is from Doom Concordat.
		Each time you kill a creature a random worn demon seed with less than 100%% life will be healed for %d%% life and resurrected if it was dead and the target was an elite or more.
		In addition you feed of the arrival, departure or death of your demons, each time healing yourself for %d life.
		The healing is based on your Spellpower.]]):
		tformat(t:_getDur(self), healpct, t:_getHeal(self))
	end,
}
