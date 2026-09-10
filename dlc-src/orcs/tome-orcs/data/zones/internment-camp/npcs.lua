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

local alterorc = function(e)
	if e.rarity then
		e.faction = "sunwall"
		e.subdued_orc = true
		e.name = ("%s (subdued)"):tformat(_t(e.name))
		e.inc_damage = e.inc_damage or {}
		e.inc_damage.all = (e.inc_damage.all or 0) - 60
		e[#e+1] = resolvers.genericlast(function(e) e.max_life = e.max_life * 0.75 end)
		e.emote_random = resolvers.emote_random{ chance=1,
			_t"This body is fun!",
			_t"I present you my latest orc-toy!",
			_t"Crush this body, crush it!",
			_t"I am everywhere, you can't defeat me!",
		}
		e.on_die = function(self, src)
			if src and game.party:hasMember(src) then
				game.zone.orcs_killed_by_player = true
			end
		end
	end
end
local guard = function(e)
	if e.rarity then
		e.faction = "sunwall"
	end
end

load("/data/general/npcs/orc-rak-shor.lua", alterorc)
load("/data/general/npcs/orc-vor.lua", alterorc)
load("/data/general/npcs/orc-gorbat.lua", alterorc)
load("/data/general/npcs/orc-grushnak.lua", alterorc)
load("/data/general/npcs/ogre.lua", guard)

--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "MINDWALL",
	type = "humanoid", subtype = "halfling",
	display = "p",
	faction = "sunwall", unique = true,
	name = "Mindwall", color=colors.PURPLE,
	desc = _t[[.]],
	level_range = {25, nil}, exp_worth = 2,
	rarity = false, rank = 5,
	max_life = 225, life_rating = 17, fixed_rating = true,
	open_door = true,
	infravision = 10,
	psi_regen = 60,
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1, NECK=1, FINGER=2 },
	
	stats = { str=10, dex=8, mag=6, con=16, wil=30, cun=20 },
	resolvers.auto_equip_filters{
		MAINHAND = {type="weapon", subtype="mindstar"},
		OFFHAND = {type="weapon", subtype="mindstar"},
	},
	equipment = resolvers.equip{
		{type="weapon", subtype="mindstar", defined="OVERSEER", random_art_replace={chance=75}, autoreq=true},
		{type="weapon", subtype="mindstar", autoreq=true},
		{type="jewelry", subtype="amulet", autoreq=true},
		{type="jewelry", subtype="ring", autoreq=true},
		{type="jewelry", subtype="ring", autoreq=true},
		{type="armor", subtype="light", autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	combat_armor = 12, combat_def = 8,
	autolevel = "wildcaster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	
	resolvers.talents{
		[Talents.T_FORGE_BELLOWS]={base=2, every=4, max=7},
		[Talents.T_DREAM_HAMMER]={base=2, every=4, max=8},
		[Talents.T_HAMMER_TOSS]={base=3, every=4, max=8},
		[Talents.T_DREAM_CRUSHER]={base=3, every=4, max=8},
		[Talents.T_FORGE_ECHOES]={base=3, every=4, max=8},
		[Talents.T_SOLIPSISM]={base=5, every=4, max=8},
		[Talents.T_FEEDBACK_LOOP]={base=2, every=4, max=7},
		[Talents.T_BACKLASH]={base=2, every=4, max=7},
		[Talents.T_FORGE_SHIELD]={base=3, every=4, max=7},
		[Talents.T_FORGE_ARMOR]={base=2, every=4, max=7},
		[Talents.T_BIOFEEDBACK]={base=3, every=4, max=7},
		[Talents.T_RESONANCE_FIELD]={base=2, every=4, max=7},
		[Talents.T_AMPLIFICATION]={base=1, every=4, max=7},
		[Talents.T_CONVERSION]={base=1, every=4, max=7},
		[Talents.T_WAKING_NIGHTMARE]={base=1, every=4, max=7},
	},
	resolvers.inscriptions(2, "infusion"),
	
	resolvers.sustains_at_birth(),

	emote_random = resolvers.emote_random{ chance=5,
		_t"You should be parked with the others!",
		_t"You have no place in this new world!",
		_t"Your mind looks delicious...",
		_t"I hunger for more brains...",
	},

	mindwall_will_confuse = 0,
	on_act = function(self)
		local x, y, target = self:getTarget()
		if not target or target == self then return end
		if target:attr("mindwall_immune") then return end

		if self.mindwall_will_confuse <= 0 then
			game.logPlayer(target, "#YELLOW#Mindwall focuses his thoughts on your mind.  You feel extremely confused.")
			target:setEffect(target.EFF_MINDWALL_CONFUSED, 1, {power=100})
			self.mindwall_will_confuse = rng.range(4, 8)
		end
		self.mindwall_will_confuse = self.mindwall_will_confuse - 1
	end,

	on_die = function(self, who)
		if self.x then game.level.map:particleEmitter(self.x, self.y, 1, "rewrite_universe", {rm=20, rM=60, gm=180, gM=230, bm=180, bM=230}) end
		game.zone.reveal_truth()
		game.player:resolveSource():grantQuest("orcs+free-prides")
		game.player:resolveSource():setQuestStatus("orcs+free-prides", engine.Quest.COMPLETED, "mindwall")
	end,
}

newEntity{
	define_as = "MINDCONTROL_PILLAR",
	type = "immovable", subtype = "pillar",
	display = "#", color=colors.WHITE,
	name = "Mindcontrol Pillar", color=colors.VIOLET,
	desc = _t"A glass pillar containing a still living brain.",
	level_range = {25, nil}, exp_worth = 1,
	blood_color = colors.WHITE,
	body = { INVEN = 10 },
	autolevel = "wildcaster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { wil=30, con=50 },
	infravision = 10,
	psi_regen = 10,
	combat_armor = 20, combat_def = 0,
	rank = 4,
	never_move = 1,
	size_category = 4,
	negative_status_effect_immune = 1,
	faction = "sunwall",
	pillar_rarity = 1,
	max_life = 1000,
	inc_damage = {all=-25},
	talent_cd_reduction={[Talents.T_MINDWAVE]=10, [Talents.T_HAMMER_TOSS]=6, [Talents.T_DREAM_HAMMER]=5},
	resolvers.talents{
		[Talents.T_MINDWAVE]=15,
		[Talents.T_DREAM_HAMMER]={base=4, every=4, max=8},
		[Talents.T_HAMMER_TOSS]={base=4, every=4, max=8},
		[Talents.T_SOLIPSISM]={base=3, every=5, max=6},
	},
	on_die = function(self, who)
		game.zone.free_orcs()
		game.player:resolveSource():setQuestStatus("orcs+free-prides", engine.Quest.COMPLETED, game.level.data.camp)
		game.party:collectIngredient("BRAIN_JAR")
	end,
}
