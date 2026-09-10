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

load("/data-orcs/general/npcs/sunwall-warrior.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_SHADOW",
	type = "undead", subtype = "shadow",
	display = 'b', color=colors.BLACK,
	faction = "enemies",

	level_range = {30, 40}, exp_worth = 1,
	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	infravision = 10,
	lite = 1,

	life_rating = 15,
	rank = 3.5,
	size_category = 2,

	open_door = true,

	undead = 1,
	no_breath = 1,
	stone_immune = 1,
	confusion_immune = 1,
	fear_immune = 1,
	teleport_immune = 1,
	disease_immune = 1,
	poison_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	see_invisible = 80,
	resists = { [DamageType.LIGHT] = -100, [DamageType.DARKNESS] = 100 },
	resists_pen = { all=25 },

	max_life = 300, life_rating = 14,
	stats = { str=15, dex=20, con=8, wil=34, cun=24 },
	combat_armor = 0, combat_def = 10,
	combat = {
		dam=resolvers.levelup(45, 1, 1.2),
		atk=resolvers.levelup(45, 1, 1),
		apr=40,
		dammod={str=0.5,dex=0.5},
	},
	combat_physcrit = 40,

	all_damage_convert = DamageType.MIND,
	all_damage_convert_percent = 100,
	
	talent_cd_reduction = {all=-30},
	resolvers.racial(),
	resolvers.talents{ [Talents.T_ARMOUR_TRAINING]=2, [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, [Talents.T_WEAPONS_MASTERY]={base=1, every=10, max=5} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },

	on_die = function(self)
		game.zone:on_shadow_kill()
	end
}

newEntity{ base = "BASE_SHADOW", define_as = "SHADOW_PAIN",
	name = "shadow of pain", image="npc/shadow-claw.png",
	desc = _t[[A shadowy embodiment of pain.]],
	
	resolvers.talents{
		[Talents.T_SAVAGE_HUNTER]={base=3, every=5, max=10},
		[Talents.T_SHROUDED_HUNTER]={base=3, every=5, max=10},
		[Talents.T_PREDATOR]={base=3, every=5, max=10},
		[Talents.T_MADNESS]={base=3, every=5, max=10},
	},
	on_death_lore = "caves-hatred-3",
}

newEntity{ base = "BASE_SHADOW", define_as = "SHADOW_HATE",
	name = "shadow of hate", image="npc/shadow-claw.png",
	desc = _t[[A shadowy embodiment of hate.]],
	
	resolvers.talents{
		[Talents.T_HATEFUL_WHISPER]={base=3, every=5, max=10},
		[Talents.T_STALK]={base=3, every=5, max=10},
		[Talents.T_BECKON]={base=3, every=5, max=10},
		[Talents.T_HARASS_PREY]={base=3, every=5, max=10},
		[Talents.T_MADNESS]={base=3, every=5, max=10},
	},
	on_death_lore = "caves-hatred-1",
}

newEntity{ base = "BASE_SHADOW", define_as = "SHADOW_DESPAIR",
	name = "shadow of despair", image="npc/shadow-claw.png",
	desc = _t[[A shadowy embodiment of despair.]],
	
	resolvers.talents{
		[Talents.T_INSTILL_FEAR]={base=3, every=5, max=10},
		[Talents.T_HEIGHTEN_FEAR]={base=3, every=5, max=10},
		[Talents.T_TYRANT]={base=3, every=5, max=10},
		[Talents.T_MINDLASH]={base=3, every=5, max=10},
		[Talents.T_MADNESS]={base=3, every=5, max=10},
	},
	on_death_lore = "caves-hatred-2",
}

newEntity{ base = "BASE_SHADOW", define_as = "SHADOW_REMORSE",
	name = "shadow of remorse", image="npc/shadow-claw.png",
	desc = _t[[A shadowy embodiment of remorse.]],
	
	negative_regen = 10,

	resolvers.talents{
		[Talents.T_MOONLIGHT_RAY]={base=3, every=5, max=10},
		[Talents.T_MADNESS]={base=3, every=5, max=10},
		[Talents.T_STARFALL]={base=3, every=5, max=10},
		[Talents.T_CIRCLE_OF_WARDING]={base=3, every=5, max=10},
	},
}

newEntity{ base = "BASE_SHADOW", define_as = "SHADOW_GUILT",
	name = "shadow of guilt", image="npc/shadow-claw.png",
	desc = _t[[A shadowy embodiment of guilt.]],
	
	resolvers.talents{
		[Talents.T_MADNESS]={base=3, every=5, max=10},
		[Talents.T_GLOOM]={base=3, every=5, max=10},
		[Talents.T_DISMAY]={base=3, every=5, max=10},
		[Talents.T_WEAKNESS]={base=3, every=5, max=10},
		[Talents.T_SANCTUARY]={base=3, every=5, max=10},
	},
}

newEntity{ base = "BASE_SHADOW", define_as = "SHADOW_ANGER",
	name = "shadow of anger", image="npc/shadow-claw.png",
	desc = _t[[A shadowy embodiment of anger.]],
	
	resolvers.talents{
		[Talents.T_MADNESS]={base=3, every=5, max=10},
		[Talents.T_CALL_SHADOWS]={base=3, every=5, max=10},
		[Talents.T_SHADOW_WARRIORS]={base=3, every=5, max=10},
		[Talents.T_SHADOW_MAGES]={base=3, every=5, max=10},
		[Talents.T_FOCUS_SHADOWS]={base=3, every=5, max=10},
	},
}

newEntity{ define_as = "JOHN",
	subtype = "human",
	base = "BASE_SUNWALL_WARRIOR",
	name = "Crimson Templar John", color=colors.PURPLE, unique = true,
	resolvers.nice_tile{tall=1},
	desc = _t[[Where you once saw a warrior bathed in light, whom in an other life you could have even respected, you now see only hatred.
This warrior's once glowing armor now emits a sinister crimson light. As he marches towards you can see his eyes, they are empty.]],
	level_range = {30, 40}, exp_worth = 1,
	rarity = false, rank = 4,
	max_life = 225, life_rating = 18, fixed_rating = true,
	positive_regen = 3, negative_regen = 3, hate_regen = 9,
	resolvers.auto_equip_filters("Sun Paladin", true),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true, forbid_power_source={antimagic=true}},
		{type="armor", subtype="shield", autoreq=true, forbid_power_source={antimagic=true}},
		{type="armor", subtype="heavy", autoreq=true, forbid_power_source={antimagic=true}}
	},
	combat_armor = 12, combat_def = 8,
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING] = {base=3, every=5, max=10},
		[Talents.T_SHIELD_PUMMEL]={base=3, every=5, max=10},
		[Talents.T_CHANT_OF_FORTRESS]={base=3, every=5, max=10},
		[Talents.T_SEARING_LIGHT]={base=3, every=5, max=10},
		[Talents.T_WEAPON_OF_LIGHT]={base=3, every=5, max=10},
		[Talents.T_HEALING_LIGHT]={base=3, every=5, max=10},
		[Talents.T_SOLAR_ORB]={base=3, every=5, max=10},
		[Talents.T_ASTRAL_PATH]={base=3, every=5, max=10},
		[Talents.T_CALL_SHADOWS]={base=3, every=5, max=10},
		[Talents.T_SHADOW_WARRIORS]={base=3, every=5, max=10},
		[Talents.T_SHADOW_MAGES]={base=3, every=5, max=10},
		[Talents.T_FOCUS_SHADOWS]={base=3, every=5, max=10},
	},
	
	resolvers.sustains_at_birth(),
	resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	is_talking = false,
	on_takehit = function(self, value, src, death_note)
		if value > self.life then
			value = 0
			if not self.is_talking then
				self.is_talking = true
				local Chat = require "engine.Chat"
				local chat = Chat.new("orcs+john-surrender", self, game:getPlayer(true))
				chat:invoke()
			end
		end
		return value
	end,
}

newEntity{ define_as = "JOHN_SUMMON",
	subtype = "human",
	base = "BASE_SUNWALL_WARRIOR",
	name = "Crimson Templar John", color=colors.PURPLE,
	resolvers.nice_tile{tall=1},
	desc = _t[[Where you once saw a warrior bathed in light, whom in an other life you could have even respected, you now see only hatred.
This warrior's once glowing armor now emits a sinister crimson light. As he marches towards your foes you can see his eyes, they are empty.]],
	level_range = {40, 40}, exp_worth = 1,
	rarity = false, rank = 3,
	max_life = 150, life_rating = 15, fixed_rating = true,
	positive_regen = 3, negative_regen = 3, hate_regen = 9,

	keep_inven_on_death = true,
	resolvers.auto_equip_filters("Sun Paladin", true),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true, forbid_power_source={antimagic=true}, not_properties={"unique"}},
		{type="armor", subtype="shield", autoreq=true, forbid_power_source={antimagic=true}, not_properties={"unique"}},
		{type="armor", subtype="heavy", autoreq=true, forbid_power_source={antimagic=true}, not_properties={"unique"}}
	},
	combat_armor = 12, combat_def = 8,
	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING] = {base=3, every=5, max=10},
		[Talents.T_SHIELD_PUMMEL]={base=3, every=5, max=10},
		[Talents.T_CHANT_OF_FORTRESS]={base=3, every=5, max=10},
		[Talents.T_SEARING_LIGHT]={base=3, every=5, max=10},
		[Talents.T_WEAPON_OF_LIGHT]={base=3, every=5, max=10},
		[Talents.T_HEALING_LIGHT]={base=3, every=5, max=10},
		[Talents.T_SOLAR_ORB]={base=3, every=5, max=10},
		[Talents.T_ASTRAL_PATH]={base=3, every=5, max=10},
		[Talents.T_CALL_SHADOWS]={base=3, every=5, max=10},
		[Talents.T_SHADOW_WARRIORS]={base=3, every=5, max=10},
		[Talents.T_SHADOW_MAGES]={base=3, every=5, max=10},
		[Talents.T_FOCUS_SHADOWS]={base=3, every=5, max=10},
	},
	
	resolvers.sustains_at_birth(),
}
