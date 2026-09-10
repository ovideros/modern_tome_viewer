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
	name = "Arcane Amplification Drone Effect", image = "talents/arcane_amplification_drone.png",
	type = {"spell/other", 1},
	mode = "passive",
	points = 1,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp)
		if dam <= 0 or src ~= self.summoner then return {dam=0} end

		local source_talent = src.__projecting_for and src.__projecting_for.project_type and (src.__projecting_for.project_type.talent_id or src.__projecting_for.project_type.talent) and src.getTalentFromId and src:getTalentFromId(src.__projecting_for.project_type.talent or src.__projecting_for.project_type.talent_id)
		if not source_talent or not source_talent.is_spell then return {dam=0} end

		self:project({type="ball", range=0, radius=4}, self.x, self.y, function(px, py)
			local a = game.level.map(px, py, Map.ACTOR)
			if a and a ~= self and a ~= src then
				DamageType:get(DamageType.ARCANE).projector(self, a.x, a.y, DamageType.ARCANE, dam * 1.3)
			end
		end)
		game.level.map:particleEmitter(self.x, self.y, 4, "generic_sploom", {rm=150, rM=180, gm=20, gM=60, bm=180, bM=200, am=80, aM=150, radius=2, basenb=120})
		return {dam=0}
	end,
	info = function(self, t)
		return (_t[[Spell damage done to it ripples in radius 4 doing 130% arcane damage.]])
	end,
}

uberTalent{
	name = "Arcane Amplification Drone",
	require = { special={desc=_t"Have gained the #{italic}#Tales of the Spellblaze#{normal}# achievement with this or any previous character for the current difficulty & permadeath settings.", fct=function(self)
		local id = world:getCurrentAchievementDifficultyId(game, "SPELLBLAZE_LORE")
		return world:hasAchievement(id)
	end} },
	cooldown = 10,
	no_npc_use = true,
	no_energy = true,
	range = 7,
	callbackOnChangeLevel = function(self, t, mode, zone, level)
		if not level or mode ~= "leave" then return end
		for uid, e in pairs(level.entities) do
			if e.is_amplification_drone and e.summoner == self then e:disappear() end
		end
	end,	
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
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

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "construct", subtype = "mechanical",
			display = "*", color=colors.UMBER,
			name = _t"arcane amplification drone", faction = self.faction, image = "npc/construct_mechanical_arcane_amplification_drone.png",
			resolvers.nice_tile{tall=1},
			desc = _t[[Any spell damage you deal to it will ripple around in radius 4 as 160% arcane damage.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented", ai_state = { talent_in=1, },
			level_range = {1, 1}, exp_worth = 0,

			max_life = 100, life_regen = 100,
			hated_by_summoner = 1,
			life_rating = 0,
			never_move = 1,
			never_act = 1,
			combat_armor = 0, combat_def = 0,
			is_amplification_drone = true,

			resolvers.talents{
				[self.T_ARCANE_AMPLIFICATION_DRONE_EFFECT] = 1,
			},

			summoner = self, summoner_gain_exp=true,
			summon_time = 3,
			resists_pen = table.clone(self.resists_pen or {}, true),
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		-- if core.shader.active(4) then m:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, rotation=0, radius=2, img="arcanegeneric", a=0.7}, {type="sunaura", time_factor=5000}))
		-- else m:addParticles(Particles.new("ultrashield", 1, {rm=180, rM=220, gm=10, gM=50, bm=190, bM=220, am=120, aM=200, radius=0.4, density=100, life=8, instop=20}))
		-- end

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")
		return true
	end,
	info = function(self, t)
		return ([[You create an Arcane Amplification Drone at the selected location for 3 turns.
		When you cast a spell that damages the drone it will ripple the damage as 130%% arcane damage of the initial hit in radius 4.]])
		:tformat()
	end,
}

uberTalent{
	name = "Technomancer",
	require = {
		birth_descriptors={{"subclass", "Archmage"}},
		special={desc=_t"Unlocked the Technomancer evolution", fct=function(self) return profile.mod.allow_build.mage_technomancer end},
		stat = {cun=25},
	},
	is_class_evolution = "Archmage", requires_unlock = "mage_technomancer",
	cant_steal = true,
	is_technomancy = true, is_steam = true, is_spell = true,
	mode = "passive",
	no_npc_use = true,
	on_learn = function(self, t)
		if not game.party:hasMember(self) then return end
		self.descriptor.class_evolution = _t"Technomancer"

		self:learnTalentType("spell/galvanic-technomancy", false)
		self:setTalentTypeMastery("spell/galvanic-technomancy", 1.3)

		self:learnTalentType("spell/terrene-technomancy", false)
		self:setTalentTypeMastery("spell/terrene-technomancy", 1.3)

		self:learnTalentType("spell/occult-technomancy", false)
		self:setTalentTypeMastery("spell/occult-technomancy", 1.3)

		self:learnTalentType("steamtech/physics", true)
		self:learnTalentType("steamtech/chemistry", false)
		self:learnTalent(self.T_SMITH, true)
		self:learnTalent(self.T_MECHANICAL, true, 2)
		self:learnTalent(self.T_ELECTRICITY, true, 2)
		self:incSteam(100)

		if self ~= game:getPlayer(true) then return end
		
		-- From now on, drop tinker stuff
		game.state.birth.merge_tinkers_data = true

		game.party:learnTinker("ARCANE_DYNAMO")

		local ape = self:findInAllInventoriesBy("define_as", "APE")
		if not ape then
			local base_list = require("mod.class.Object"):loadList("/data-orcs/general/objects/quest-artifacts.lua")
			base_list.__real_type = "object"
			local o = game.zone:makeEntityByName(game.level, base_list, "APE", true)
			if o then
				o.auto_hotkey = 1
				self:addObject(self.INVEN_INVEN, o)
				self:sortInven()
			end
		end

		local list = {
			{name=_t"Occult Technomancy", type="spell/occult-technomancy", talent=self.T_METATEMPORAL_SPINNER, desc=_t[[These talents focus on arcane and temporal damage, using a super-spinned steamsaw to rip holes in reality.]]},
			{name=_t"Galvanic Technomancy", type="spell/galvanic-technomancy", talent=self.T_GALVANIC_ROD, desc=_t[[These talents focus on fire and lightning damage, strategically placing galvanic rods to create fields of death and stuns.]]},
			{name=_t"Terrene Technomancy", type="spell/terrene-technomancy", talent=self.T_MICRO_SPIDERBOT, desc=_t[[These talents focus on cold and physical damage, summoning micro spiderbots to harass and pin their foes or protect themselves.]]},
		}
		local d = require("engine.ui.Dialog"):listPopup(_t"Technomancer", _t"Choose your free Technomancy unlock?", list, 400, 250, function(sel)
			if not sel then return end
			self:learnTalentType(sel.type)
			self:learnTalent(sel.talent, true)
		end, function(sel)
			game.tooltip_x, game.tooltip_y = 1, 1
			local talents = _t"Available talents:\n"
			for i, t in ipairs(game.player.talents_types_def[sel.type].talents) do
				talents = talents.."#AQUAMARINE#"..t.name.."\n"
			end
			game:tooltipDisplayAtMap(game.w, game.h, "#GOLD#"..sel.name.."#LAST#\n"..sel.desc..talents)
		end)
		d.key:addBind("EXIT", function() end)
	end,
	on_unlearn = function(self, t)
	end,
	info = function(self, t)
		return ([[Technomancers are Archmages that dabble in steam technology to enhance their already formidable arsenal of spells.
		Once this class evolution is taken, you gain the following:
		- Arcane Dynamo tinker schematic
		- Steamtech/Physics category (unlocked)
		- Steamtech/Chemistry category (locked)
		- An Automated Portable Extractor (A.P.E.)
		- One point in the Physics talent Smith and two in Mechanical and Electricity
		- Spell/Galvanic Technomancy category (locked) - deals with fire and lightning
		- Spell/Terrene Technomancy category (locked) - deals with earth and water
		- Spell/Occult Technomancy category (locked) - deals with time and arcane
		- The ability to unlock one of the three Technomancy categories for free

		Once put in a robe, the Arcane Dynamo will regenerate Steam each time mana is spent and increase Spellpower based on current steam level.

		#{bold}#As soon as this evolution is used you will need to craft the Arcane Dynamo to place in a robe to benefit from all the powers of the Technomancer.#{normal}#]])
		:tformat()
	end,
}
