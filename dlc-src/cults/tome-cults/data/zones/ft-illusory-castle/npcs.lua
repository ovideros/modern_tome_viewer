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

local Talents = require("engine.interface.ActorTalents")

load("/data/general/npcs/minotaur.lua")
load("/data/general/npcs/construct.lua")
-- MOAR minotaurs, undead ones even!
if game:isAddonActive("orcs") then load("/data-orcs/general/npcs/whitehooves.lua") end


newEntity{ base = "BASE_NPC_MINOTAUR",
	name = "minotaur mindscrew", color=colors.YELLOW,
	resolvers.nice_tile{tall=1},
	desc = _t[[A belligerent minotaur with a frightening amount of mind powers, and armed with a hammer and a pack of huge rocks.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 3,
	combat_armor = 15, combat_def = 7,
	-- resolvers.auto_equip_filters{MAINHAND = {type="weapon", subtype="greatmaul"}, },
	resolvers.equip{ {type="weapon", subtype="greatmaul", forbid_power_source={antimagic=true}, autoreq=true} },
	rank = 3,

	autolevel = "drake",
	resists = { [DamageType.MIND] = 100 },
	resolvers.talents{
		[Talents.T_THROW_BOULDER]={base=3, every=8},
		[Talents.T_FORGE_SHIELD]={base=3, every=7},
		[Talents.T_FORGE_BELLOWS]={base=3, every=7},
		[Talents.T_DREAMFORGE]={base=3, every=7},
	},
}


-- Possibly limit max number of healing so it can still be done wrong eventually?
newEntity{ base = "BASE_NPC_CONSTRUCT", define_as = "GLASS_GOLEM",
	unique = true, color=colors.VIOLET,
	name = "The Glass Golem",
	desc = _t[[A huge golem-like construct made entirely out of glass. It seems to be the custodian of the whole castle and likely the key to those nice looking chests around the throne.]],
	killer_message = _t"and turned into glass",

	image = "player/glass_golem/base_01.png",
	moddable_tile = "glass_golem",
	moddable_tile_base = "base_01.png",

	level_range = {30, nil}, exp_worth = 1,
	max_life = 330, life_rating = 20, fixed_rating = true,
	stats = { str=30, dex=10, cun=18, mag=30, wil=30, con=30 },
	rank = 4,
	size_category = 3,
	infravision = 20,
	instakill_immune = 1,
	mana_regen = 2,
	no_difficulty_random_class = 1,
	resists = {all = 20},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, FEET=1, HEAD=1, HANDS=1 },
	resolvers.equip{
		{defined="HARDENED_GLASS_SWORD", random_art_replace={chance=100}},
		{defined="HELM_OF_KNOWLEDGE"},
		{type="armor", subtype="massive", forbid_power_source={antimagic=true}, autoreq=true, ego_chance=1000},
		{type="armor", subtype="hands", properties={"metallic"}, forbid_power_source={antimagic=true}, autoreq=true, ego_chance=1000},
		{type="armor", subtype="feet", properties={"metallic"}, forbid_power_source={antimagic=true}, autoreq=true, ego_chance=1000},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	ai_talents = { -- It has flame & lightning for arcane combat procs, not for casting
		[Talents.T_FLAME]=0,
		[Talents.T_LIGHTNING]=0,
	},
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=4, every=6},
		[Talents.T_THROW_BOULDER]={base=4, every=6},
		[Talents.T_FORGE_SHIELD]={base=3, every=7},
		[Talents.T_FORGE_BELLOWS]={base=3, every=7},
		[Talents.T_DREAMFORGE]={base=3, every=7},
		[Talents.T_ARCANE_COMBAT]={base=3, every=7},
		[Talents.T_FLAME]={base=3, every=7},
		[Talents.T_LIGHTNING]={base=3, every=7},
		[Talents.T_ARCANE_FEED]={base=3, every=7},
		[Talents.T_ARCANE_DESTRUCTION]={base=3, every=7},
		[Talents.T_GLASS_SPLINTERS]={base=4, every=7},
	},
	resolvers.sustains_at_birth(),

	autolevel = "drake",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(4, "rune"),

	throne_heals = 0,

	on_die = function(self, who)
		who:setQuestStatus("cults+illusory-castle", engine.Quest.COMPLETED, "kill")
		if who.descriptor and who.descriptor.subclass == "Alchemist" then
			game:setAllowedBuild("cosmetic_class_alchemist_glass_golem", true)
		end
		if self.throne_heals == 0 then
			world:gainAchievement("CULTS_GLASS_GOLEM_NO_HEAL", who)
		end
	end,

	on_act = function(self)
		if self.life < self.max_life * 0.35 then
			local throne = game.level:pickSpot{type="throne", subtype="glass"}
			if not throne then return end
			if not self:hasLOS(throne.x, throne.y, "block_sight", 20) then
				game.bignews:say(120, "#AQUAMARINE#As the Glass Golem's life dwindles too low it teleports to its throne to heal!")
				self:teleportRandom(throne.x, throne.y, 3)
				self:heal(self.max_life, self)
				return
			end

			local done_knockback = {}
			local recursive = function(target)
				if not done_knockback[target] then done_knockback[target] = true return true end
			end

			self:pull(throne.x, throne.y, core.fov.distance(self.x, self.y, throne.x, throne.y), recursive)
			if core.fov.distance(self.x, self.y, throne.x, throne.y) <= 1 then
				game.bignews:say(120, "#AQUAMARINE#As the Glass Golem's life dwindles too low it rushes toward its throne to heal!")
				self:heal(self.max_life, self)
				self.throne_heals = self.throne_heals + 1
			else
				game.bignews:say(120, "#AQUAMARINE#As the Glass Golem's life dwindles too low it rushes toward its throne but hits a glass wall instead!")
				game:shakeScreen(20, 3)
				self:setEffect(self.EFF_STUNNED, 3, {})
			end
		end
	end
}

-- Switch everybody to Astar pathing because of how the zone is laid out
for _, e in pairs(loading_list) do
	e.ai_state = e.ai_state or {}
	e.ai_state.ai_move = "move_astar"
end
