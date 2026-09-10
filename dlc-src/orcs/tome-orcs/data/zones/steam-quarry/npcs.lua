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

load("/data-orcs/general/npcs/steam-giant-warrior.lua", rarity(0))
load("/data-orcs/general/npcs/steam-giant-gunner.lua", rarity(0))
load("/data-orcs/general/npcs/steam-giant-arcane.lua", rarity(0))
load("/data-orcs/general/npcs/steam-spiders.lua", rarity(0))
load("/data-orcs/general/npcs/hethugoroth.lua", rarity(0))

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")


newEntity{ define_as = "BASE_AUTOMATED_DEFENCE_SYSTEM", base = "BASE_STEAM_SPIDER",
	name = "Automated Defense System", color=colors.PURPLE,
	desc = _t[[This heavily armored mecharachnid looks extremely dangerous and well equipped to defend the quarry.]],
	level_range = {38, nil}, exp_worth = 0.8, -- Low exp multiplier because you kill them a lot
	rarity = false, rank = 4,
	max_life = 200, life_rating = 15, fixed_rating = true,
	combat_armor = 50, combat_def = 30,
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.sustains_at_birth(),
	steam_regen = 30,
	is_ads = true,

	on_die = function(self, src)
		-- game.player:resolveSource():setQuestStatus("orcs+quarry", engine.Quest.COMPLETED, self.quest_objective_name)
		game.party:collectIngredient("MECHANICAL_CORE")

		-- Annihilator unlock
		if profile.mod.allow_build.tinker_annihilator then return end
		if src.resolveSource then src = src:resolveSource() end
		if not src.player then return end
		if not src:knowTalent(src.T_CREATE_TINKER) then return end

		src:grantQuest("orcs+annihilator")
		src:setQuestStatus("orcs+annihilator", engine.Quest.COMPLETED, "ads")
	end,

	onTakeHit = function(self, value, src)
		value = mod.class.Actor.onTakeHit(self, value, src)
		if value <= 0 then return value end
		for uid, e in pairs(game.level.entities) do if e.is_ads then
			local o = e.onTakeHit
			e.onTakeHit = nil
			e:takeHit(value, src)
			e.onTakeHit = o
		end end
		return value
	end,
}

newEntity{ define_as = "AUTOMATED_DEFENCE_SYSTEM1", base = "BASE_AUTOMATED_DEFENCE_SYSTEM",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/mechanical_arachnid_automated_defense_system_one.png", display_h=2, display_y=-1}}},
	autolevel = "warrior",
	quest_objective_name = "valve1",

	resolvers.auto_equip_filters("Sawbutcher"),
	resolvers.equip{
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="weapon", subtype="steamsaw", autoreq=true},
		{type="armor", subtype="cloak", autoreq=true},
	},
	combat_armor_hardiness = 30,
	resolvers.talents{ 
		[Talents.T_MASSIVE_BLOW]=1,
		[Talents.T_WEAPON_COMBAT]={base=2, every=5, max=5},
		[Talents.T_UNSTOPPABLE]={base=5, every=7, max=10},
		[Talents.T_BLOODBATH]={base=5, every=7, max=10},
		[Talents.T_MORTAL_TERROR]={base=5, every=7, max=10},
		[Talents.T_FLURRY]={base=5, every=7, max=10},
		[Talents.T_DUAL_STRIKE]={base=5, every=7, max=10},
		[Talents.T_PRECISION]={base=5, every=7, max=10},
		[Talents.T_DUAL_WEAPON_DEFENSE]={base=5, every=7, max=10},
		[Talents.T_RUSH]={base=5, every=7, max=10},
		[Talents.T_TINKER_ROCKET_BOOTS]={base=5, every=7, max=10},
		[Talents.T_LAST_ENGINEER_STANDING]={base=5, every=7, max=10},
		[Talents.T_TREMOR_ENGINE]={base=5, every=7, max=10},
		[Talents.T_SPINAL_BREAK]={base=5, every=7, max=10},
		[Talents.T_EXPLOSIVE_SAW]={base=5, every=7, max=10},
		[Talents.T_STEAMSAW_MASTERY]={base=5, every=7, max=10}, 
	},
}

newEntity{ define_as = "AUTOMATED_DEFENCE_SYSTEM2", base = "BASE_AUTOMATED_DEFENCE_SYSTEM",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/mechanical_arachnid_automated_defense_system_two.png", display_h=2, display_y=-1}}},
	autolevel = "slinger",
	quest_objective_name = "valve2",

	resolvers.auto_equip_filters("Gunslinger"),
	resolvers.equip{
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="weapon", subtype="steamgun", autoreq=true},
		{type="ammo", subtype="shot", autoreq=true},
		{type="armor", subtype="cloak", autoreq=true},
	},
	
	resolvers.talents{ 
		[Talents.T_SHOOT]=1,
		[Talents.T_ROLL_WITH_IT]=1,
		[Talents.T_WEAPON_COMBAT]={base=2, every=5, max=5},
		[Talents.T_NET_PROJECTOR]={base=5, every=7, max=10}, 
		[Talents.T_CLOAK]={base=5, every=7, max=10}, 
		[Talents.T_OVERHEAT_BULLETS]={base=5, every=7, max=10}, 
		[Talents.T_PERCUSSIVE_BULLETS]={base=5, every=7, max=10}, 
		[Talents.T_STARTLING_SHOT]={base=5, every=7, max=10}, 
		[Talents.T_DOUBLE_SHOTS]={base=5, every=7, max=10}, 
		[Talents.T_STATIC_SHOT]={base=5, every=7, max=10}, 
		[Talents.T_MASS_REPAIR]={base=5, every=7, max=10}, 
		[Talents.T_STEAMGUN_MASTERY]={base=5, every=7, max=10}, 
	},
}

newEntity{ define_as = "AUTOMATED_DEFENCE_SYSTEM3", base = "BASE_AUTOMATED_DEFENCE_SYSTEM",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/mechanical_arachnid_automated_defense_system_three.png", display_h=2, display_y=-1}}},
	autolevel = "caster",
	quest_objective_name = "valve3",

	mana_regen = 10,

	resolvers.auto_equip_filters("Archmage"),
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloak", autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="LIQUID_METAL_CLOAK", random_art_replace={chance=65}} },
	
	resolvers.talents{ 
		[Talents.T_CAUTERIZE]=1,
		[Talents.T_STAFF_MASTERY] = {base=5, every=5, max=10},
		[Talents.T_LIGHTNING]={base=5, every=7, max=10}, 
		[Talents.T_SHOCK]={base=5, every=7, max=10}, 
		[Talents.T_HURRICANE]={base=5, every=7, max=10}, 
		[Talents.T_THUNDERSTORM]={base=5, every=7, max=10}, 
		[Talents.T_BLASTWAVE]={base=5, every=7, max=10}, 
		[Talents.T_BODY_OF_FIRE]={base=5, every=7, max=10}, 
		[Talents.T_TINKER_TOXIC_CANNISTER_LAUNCHER]={base=5, every=7, max=10},
		[Talents.T_SUMMON]=1,
	},

	summon = {
		{type="mechanical", subtype="arachnid", name="mecharachnid repairbot", number=1, hasxp=false, no_subescort=true},
	}
}
