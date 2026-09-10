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

load("/data/general/npcs/minor-demon.lua", function(e)
	-- Let's be kind
	if e.name == "wretchling" and e.make_escort then
		e.make_escort[1].number = 1
	end
end)
load("/data/general/npcs/major-demon.lua")
load("/data/general/npcs/minotaur.lua", function(e) if e.name and e.rarity then e.name = ("enthralled %s"):tformat(e:getName()) e.faction = "fearscape" e.maulotaur_rarity, e.rarity = e.rarity, nil end end)

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_DEMON",
	name = "quasit squad leader", color=colors.GREY,
	desc = _t"A small, heavily armoured demon, rushing toward you.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 1,
	rank = 3,
	size_category = 1,
	autolevel = "warrior",
	combat_armor = 1, combat_def = 0,
	vim_regen = 3,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=2, every=10, max=5},
		[Talents.T_SHIELD_PUMMEL]={base=2, every=6, max=5},
		[Talents.T_RIPOSTE]={base=3, every=6, max=6},
		[Talents.T_OVERPOWER]={base=1, every=6, max=5},
		[Talents.T_RUSH]=6,
		[Talents.T_BLIGHTED_SHIELD]={base=1, every=6, max=5},
		[Talents.T_OSMOSIS_SHIELD]={base=4, every=6, max=5},
	},
	resolvers.auto_equip_filters("Bulwark"),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true}
	},
	on_die = function(self, src)
		if not self.x or not game.zone or not game.level then return end

		local id = "LORE_FAILED"
		-- OMFG such an easter egg!
		if src and self.EFF_AWED_BY_BADASSERY and self:hasEffect(self.EFF_AWED_BY_BADASSERY) and src == self:hasEffect(self.EFF_AWED_BY_BADASSERY).src then id = "LORE_FAILED_BADASS" end
		local o = game.zone:makeEntityByName(game.level, "object", id)
		if o then
			game.zone:addEntity(game.level, o, "object", self.x, self.y)
		end
	end,
}


-- OMFG, the first time we do a drop based on the player! ewww
local lore_note = "LORE_DOOM"
local p = game:getPlayer(true)
if p.descriptor and p.descriptor.subclass == "Demonologist" then lore_note = "LORE_DEMO" end
if p.descriptor and p.descriptor.subrace == "Doomelf" then lore_note = "LORE_ELF" end

newEntity{ base = "BASE_NPC_DEMON", define_as = "ROGROTH",
	name = "Rogroth, Eater of Souls", color=colors.VIOLET, unique = true, subtype = "major",
	desc = _t"Fire and blight arcane surges randomly appear on this spider-like dark metallic skin. There are no definite head but a single huge mouth onto its body.",
	killer_message = _t"and raised as a demonic husk",
	resolvers.nice_tile{tall=1},
	level_range = {17, nil}, exp_worth = 2,
	max_life = 250, life_rating = 22, fixed_rating = true,
	rank = 4,
	size_category = 3,
	autolevel = "warriormage",
	combat_armor = 18, combat_def = 18, combat_armor_hardiness = 100,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,
	vim_regen = 3,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, BELT=1 },
	combat = { dam=resolvers.mbonus(46, 20), atk=15, apr=7, dammod={str=0.7} },

	resolvers.equip{ {defined="ROGROTH_JAW", random_art_replace={chance=70}, autoreq=true}, },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined=lore_note} },
	resolvers.talents{
		[Talents.T_DEMON_SOUL_EATER]=1,
		[Talents.T_WEAPON_COMBAT]={base=1, every=3, max=8},
	},

	make_escort = {
		{type="demon", subtype="minor", number=5},
	},

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("ashes-urhrok+re-abducted", engine.Quest.COMPLETED, "boss")
	end,
}
