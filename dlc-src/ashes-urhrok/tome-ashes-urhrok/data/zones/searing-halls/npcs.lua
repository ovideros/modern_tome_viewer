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

load("/data/general/npcs/losgoroth.lua", function(e) e.crash_rarity, e.rarity = e.rarity, nil; e.combat_def = 0; e.inc_damage = {all=-70} end)

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_DEMON",
	type = "demon", subtype = "minor",
	display = "u", color=colors.WHITE,
	blood_color = colors.GREEN,
	faction = "fearscape",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	life_rating = 7,
	combat_armor = 1, combat_def = 1,
	combat = { dam=resolvers.mbonus(46, 20), atk=15, apr=7, dammod={str=0.7} },
	max_life = resolvers.rngavg(70,90),
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	infravision = 10,
	open_door = true,
	rank = 2,
	size_category = 3,
	no_breath = 1,
	demon = 1,
	random_name_def = "demon",
	resolvers.drops{chance=100, nb=2, {type="money"} },
}

newEntity{ base = "BASE_NPC_DEMON",
	name = "demonic clerk", color=colors.BLUE,
	desc = _t"A small demon, he looks alarmed at your seeming freedom.",
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(40,60),
	rarity = 2,
	rank = 2,
	size_category = 1,
	autolevel = "caster",
	combat_armor = 1, combat_def = 0,
	combat = {damtype=DamageType.FIRE},

	inc_damage = { all = -50 },
	slow_projectiles_outgoing = 50, -- Makes them much less annoying when poking at range and being able to dodge projectiles is satisfying and fun


	resolvers.talents{
		-- [Talents.T_FLAME]={base=1, every=3, max=8},
		[Talents.T_FLAME]=1,
		[Talents.T_PHASE_DOOR]=2,
	},
}

newEntity{ base = "BASE_NPC_DEMON",
	name = "mutilator", color=colors.UMBER,
	desc = _t"A demon with 3 arms, ready to mutilate you. For experiment. Not for fun. Nope.",
	resolvers.nice_tile{tall=1},
	level_range = {1, nil}, exp_worth = 1,
	rarity = 2,
	rank = 2,
	size_category = 3,
	autolevel = "warrior",
	combat_armor = 1, combat_def = 0,

	resolvers.equip{
		{type="weapon", subtype="greatmaul", autoreq=true},
	},

	-- This is mostly for the first zone, where fighting in the open can be a really bad idea since retreating is hard.  Reduces incentive to pull 1 by 1.
	movement_speed = 0.8,

	resolvers.talents{
		[Talents.T_RECKLESS_STRIKE]=1,
		[Talents.T_RUSH]=1,
		-- [Talents.T_RECKLESS_STRIKE]={base=1, every=3, max=8},
		-- [Talents.T_RUSH]={base=1, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_DEMON",
	name = "investigator", color=colors.DARK_UMBER,
	desc = _t"This demon is dedicated to #{italic}#extracting#{normal}# information from #{italic}#willing#{normal}# subjects.",
	resolvers.nice_tile{tall=1},
	level_range = {1, nil}, exp_worth = 1,
	rarity = 2,
	rank = 2,
	size_category = 3,
	autolevel = "warrior",
	combat_armor = 1, combat_def = 0,
	resolvers.equip{
		{type="weapon", subtype="greatmaul", autoreq=true},
	},

	inc_damage = {all = -30},

	-- This is mostly for the first zone, where fighting in the open can be a really bad idea since retreating is hard.  Reduces incentive to pull 1 by 1.
	movement_speed = 0.8,

	resolvers.talents{
		-- [Talents.T_ABDUCTION]={base=1, every=5, max=8},
		-- [Talents.T_WEAPONS_MASTERY]={base=1, every=3, max=8},
		[Talents.T_ABDUCTION]=1,
		[Talents.T_WEAPONS_MASTERY]=1,
	},
}

newEntity{ base = "BASE_NPC_DEMON", define_as = "PLANAR_CONTROLLER",
	name = "Planar Controller", color=colors.VIOLET, unique = true, subtype = "major",
	desc = _t"A huge demon towers above you, it is obviously in control of all the portals in the nearby Fearscape area.",
	killer_message = _t"and teleported to Mal'Rok for more experiments",
	on_added = function(self, level, x, y)
		if engine.Map.tiles.nicer_tiles then
			local ps = self:addParticles(require("engine.Particles").new("farportal_vortex", 1, {rot=3, size=40, vortex="shockbolt/terrain/planar_demon_vortex"}))
			ps.dy = -0.35
			ps.dx = -0.07
		end
	end,
	resolvers.nice_tile{tall=1},
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, LITE=1 },
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 12, fixed_rating = true,
	rank = 4,
	size_category = 4,
	autolevel = "warriormage",
	combat_armor = 3, combat_def = 0,
	infravision = 10,
	instakill_immune = 1,
	tier1 = true,
	move_others=true,
	vim_regen = 3,

	inc_damage = {all=-50},

	resolvers.auto_equip_filters{MAINHAND = {type="weapon", not_properties={"command_staff"}, properties={"twohanded"}}},
	resolvers.equip{
		{type="weapon", subtype="greatmaul", autoreq=true},
	},
	resolvers.equip{ {defined="PLANAR_BEACON", random_art_replace={chance=70}, autoreq=true}, },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_FEARSCAPE_SHIFT]=1,
		[Talents.T_FEARSCAPE_AURA]=1,
		[Talents.T_WEAPONS_MASTERY]=1,
		[Talents.T_WEAPON_COMBAT]=1,
		-- [Talents.T_FEARSCAPE_SHIFT]={base=1, every=3, max=8},
		-- [Talents.T_FEARSCAPE_AURA]={base=1, every=3, max=8},
		-- [Talents.T_WEAPONS_MASTERY]={base=1, every=3, max=8},
		-- [Talents.T_WEAPON_COMBAT]={base=1, every=3, max=8},
	},

	-- Override the recalculated AI tactics to avoid problematic kiting in the early game
	low_level_tactics_override = {escape=0},

	on_die = function(self, who)
		local g = game.zone:makeEntityByName(game.level, "terrain", "PORTAL_EYAL", true)
		if g then
			game.zone:addEntity(game.level, g, "terrain", self.x, self.y)
			if core.shader.active(4) then
				game.level.map:particleEmitter(self.x, self.y, 2, "shader_ring_rotating", {rotation=0, radius=2, life=30, img="flamesgeneric"}, {type="firesurge", renderArcs=0})
			else
				game.level.map:particleEmitter(self.x, self.y, 1, "demon_teleport")
			end
		end

		game.player:resolveSource():setQuestStatus("ashes-urhrok+start-ashes", engine.Quest.COMPLETED, "planar-walker")
	end,
}
