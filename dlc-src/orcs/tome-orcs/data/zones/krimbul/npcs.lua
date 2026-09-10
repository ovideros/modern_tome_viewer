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

load("/data/general/npcs/ghoul.lua", rarity(5))
load("/data-orcs/general/npcs/whitehooves.lua", rarity(0))
load("/data/general/npcs/ghost.lua", rarity(20))
load("/data/general/npcs/aquatic_critter.lua", switchRarity"water_rarity")

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_MINOTAUR_UNDEAD", define_as = "NEKTOSH",
	name = "Nektosh the One-Horned", color=colors.PURPLE, unique = true,
	resolvers.nice_tile{tall=1},
	desc = _t[[A withered Whitehoof, with two horns that curve over his head and spiral into a cone.  The tip of his "horn" glows intensely, but is slowly fading; he acts confident, but his darting, wild eyes reveal panic behind them.]],
	resolvers.equip{ {type="weapon", subtype="staff", autoreq=true}, },
	level_range = {18, nil}, exp_worth = 2,
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	rank = 4,
	max_life = 300, life_rating = 16, fixed_rating = true,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1 },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="NEKTOSH_HELM"} },
	resolvers.drops{chance=100, nb=1, {defined="NOTE3"} },

	combat_armor = 15, combat_def = 25,
	resolvers.talents{
		[Talents.T_BLURRED_MORTALITY]={base=2, every=10, max=6},
		[Talents.T_ICE_SHARDS]={base=1, every=10, max=5},
		[Talents.T_GLOOM]={base=2, every=5, max = 12},
		[Talents.T_ARMOUR_TRAINING]=1,
		[Talents.T_WEAKNESS]={base=2, every=5, max = 10},
		[Talents.T_WILLFUL_STRIKE]={base=2, every=5, max = 10},
		[Talents.T_BLOOD_SPRAY]={base=2, every=5, max = 10},
		[Talents.T_BLOOD_BOIL]={base=2, every=5, max = 10},
	},

	next_wand = 1,
	on_act = function(self)
		if self:attr("never_act") then return end
		local x, y, target = self:getTarget()
		if not target or target == self then return end
		if not rng.chance(3) then return end

		local a = math.atan2(y - self.y, x - self.x)
		local tx, ty = x + math.cos(a) * 10, y + math.sin(a) * 10

		if self.next_wand == 1 then
			self:doEmote(_t"KNOW MY POWER, FOOLISH MORTAL!", 120)
			self:setEffect(self.EFF_NEKTOSH_WAND, 3, {x=tx, y=ty, power=5000, dig=true})
		elseif self.next_wand == 2 then
			self:doEmote(_t"Stop--  stop moving and this will be over before you can feel pain!  STOP!", 120)
			self:setEffect(self.EFF_NEKTOSH_WAND, 3, {x=tx, y=ty, power=500})			
		elseif self.next_wand == 3 then
			self:doEmote(_t"No...  come on, come on, there has to be something left...", 120)
			self:setEffect(self.EFF_NEKTOSH_WAND, 3, {x=tx, y=ty, power=100})
		elseif self.next_wand == 4 then
			self:doEmote(_t"...it's gone...  FINE!  I don't need that power to destroy you!", 120)
			self:setEffect(self.EFF_NEKTOSH_WAND, 3, {x=tx, y=ty, power=50})
			game.state.orcs_nektosh_power_all_used = true			
		end
		self.next_wand = self.next_wand + 1
	end,

	on_die = function(self)
		game.state.orcs_nektosh_power_all_used = nil
		game:setAllowedBuild("race_whitehooves", true)
		game.player:setQuestStatus("orcs+krimbul", engine.Quest.COMPLETED)
	end,

	-- No summon talent, this is forced on wand effect end
	summon = {
		{type="undead", subtype="minotaur", number=2, hasexp=false},
	},

	make_escort = {
		{type="undead", subtype="minotaur", number=1, hasexp=false},
	},
}
