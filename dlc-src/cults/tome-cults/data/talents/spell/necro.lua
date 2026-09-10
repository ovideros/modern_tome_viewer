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

local bone_horror = {
	type = "undead", subtype = "horror",
	blood_color = colors.BLUE,
	display = "h",
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	ai = "dumb_talented_simple", ai_state = { talent_in=2, },
	stats = { str=20, dex=20, wil=20, mag=20, con=20, cun=20 },
	infravision = 10,
	size_category = 3,

	blind_immune = 1,
	fear_immune = 1,
	see_invisible = 2,
	undead = 1,
	resolvers.sustains_at_birth(),

	name = "bone horror", color=colors.WHITE, image="npc/dread.png",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_horror_bone_horror.png", display_h=2, display_y=-1}}},
	desc =_t"The massive ribcage in the middle beats with loud, audible cracks, as many a skeletal hand protrude forth, entwining, fusing, forming long skeletal appendages to support itself, while others crumble and collapse inward. During all this, somehow, it seems they grasp for you.",
	level_range = {30, nil}, exp_worth = 0,
	rank = 3,
	size_category = 4,
	combat_armor = 15, combat_def = 0,
	max_life=300, life_rating = 11,
	disease_immune = 1,
	cut_immune = 1,

	is_bone_horror = true,
	
	combat = {
		dam=resolvers.levelup(resolvers.rngavg(60,70), 1, 1.2),
		atk=resolvers.rngavg(60,80), apr=40,
		dammod={mag=1, str=0.5}, physcrit = 12,
		damtype=engine.DamageType.PHYSICALBLEED,
	},
	
	autolevel = "warriormage",
	
	resolvers.talents{
		[Talents.T_BONE_GRAB]={base=4, every=8, max=10},
		[Talents.T_BONE_NOVA]={base=2, every=8, max=8},
		[Talents.T_BONE_SPEAR]={base=4, every=5, max=12},
		
		[Talents.T_SKULLCRACKER]={base=5, every=15, max=10},
		[Talents.T_THROW_BONES]={base=4, every=10, max=8},
		
		[Talents.T_BONE_SHIELD]={base=4, every=30, max=11},
	},
	
	on_die = function(self, who)
		if not self.summoner or not self.summoner:knowTalent(self.summoner.T_CALL_OF_THE_CRYPT) then return end

		game.logSeen(self.summoner, "#VIOLET#As the bone horror is destroyed you see the remaining bones reassembling in the form of new skeletons!")

		local ActorTalents = require "engine.interface.ActorTalents"
		local t_call = self.summoner:getTalentFromId(self.summoner.T_CALL_OF_THE_CRYPT)
		local lev = t_call:_getLevel(self.summoner)

		-- Summon minions around
		local possible_spots = {}
		self:project({type="ball", radius=4}, self.x, self.y, function(px, py)
			if not game.level.map:checkAllEntities(px, py, "block_move") then
				possible_spots[#possible_spots+1] = {x=px, y=py}
			end
		end)
		for i = 1, 3 do
			local skel = self.summoner:getTalentLevel(t_call) >= 3 and t_call.minions_list.a_skel_warrior or t_call.minions_list.skel_warrior
			local pos = rng.tableRemove(possible_spots)
			if pos then
				ActorTalents.main_env.necroSetupSummon(self.summoner, skel, pos.x, pos.y, lev, 10, true)
			end
		end
		game:playSoundNear(self, "creatures/skeletons/skell_die")
	end,
}

class:bindHook("Necromancer:NecroSetupSummon", function (self, data)
	if self:attr("can_summon_necrotic_bone_horror") and data.def.skeleton_minion and not data.turns then
		local has_bone_horror = false
		for i, actor in ipairs(game.party.m_list) do
			if actor.is_bone_horror then has_bone_horror = true break end
		end

		if not has_bone_horror then
			data.new_def = bone_horror
			return true
		end
	end
end)

class:bindHook("Necromancer:SoulLeech:GainSoul", function (self, data)
	-- Only for player party
	if not game.party:hasMember(self) then return end
	local weapon = self:hasStaffWeapon()
	if not weapon or not weapon.is_bonestaff then return end

	weapon.captured_souls = (weapon.captured_souls or 0) + 1

	if weapon.captured_souls >= 100 and not weapon.captured_souls_goal then
		weapon.captured_souls_goal = true
		game:onTickEnd(function()
			self.is_first_time_souls = true
			self:forceUseTalent(self.T_COMMAND_STAFF, {ignore_cooldown=true, ignore_energy=true})
			self.is_first_time_souls = nil
		end)
	end
end)
