-- ToME - Tales of Maj'Eyal:
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

local class = require"engine.class"

class:bindHook("CommandStaff:SentientOptions", function(self, data)
	if data.mode == "intro" then
		data.list.bonestaff = _t[[#GREY##{italic}#You feel the bones of the staff creeking and vibrating in your hand.#{normal}##LAST# Yes... #{italic}#"master"#{normal}#.]]
	elseif data.mode == "how_speak" then
		data.list.bonestaff = _t"#GREY##{italic}#The vibrations feel like a shrug.#{normal}##LAST# By magic #{bold}#obviously#{normal}#. What kind of necromancer might you be to ask such #{bold}#stupid#{normal}# questions?"
	elseif data.mode == "which_aspect" then
		data.list.bonestaff = _t"#GREY##{italic}#The vibrations intensify.#{normal}##LAST# As long as this means more deaths and bones, I will agree to change aspect. Which do you choose?"
	end
end)

class:bindHook("Chat:invoke", function(self, data)
	if self.name == "command-staff" and self.player.is_first_time_souls then
		data.id = "bone_horror_ready"
	end
end)

class:bindHook("CommandStaff:SentientChat", function(self, data)
	local o = data.o
	if not o.combat or o.combat.sentient ~= "bonestaff" then return end

	if not self.player:knowTalent(self.player.T_NECROTIC_AURA) or not self.player:knowTalent(self.player.T_CALL_OF_THE_CRYPT) then
		data.answers[#data.answers+1] = {_t"Is there anything else you can do?", jump="bone_horror_mock"}

		self:addChat{ id="bone_horror_mock",
			text = _t[[#GREY##{italic}#The staff shudders.#{normal}##LAST# My finest services are only available to real necromancers. Stop bothering me, inferior creature.]],
			answers = {
				{"...", jump="welcome"}
			},
		}
		return
	end

	o.captured_souls = o.captured_souls or 0
	
	if o.captured_souls < 100 then
		data.answers[#data.answers+1] = {_t"Is there anything else you can do?", jump="bone_horror_status"}
	elseif not o.unleashed_power then
		data.answers[#data.answers+1] = {_t"I am ready to use your powers!", jump="bone_horror_ready"}
	else
		if not o.wielder.can_summon_necrotic_bone_horror then
			data.answers[#data.answers+1] = {_t"I want you to start summoning the bone horror again.", jump="bone_horror_enabled"}
		else
			data.answers[#data.answers+1] = {_t"I want you to stop summoning the bone horror.", jump="bone_horror_disabled"}
		end
	end

	self:addChat{ id="bone_horror_status",
		text = ([[#GREY##{italic}#You feel the staff writhing in your hand with dark intents.#{normal}##LAST# Once you will have collected one hundred souls and one class talent point I will be able to enhance your pathetic summons with a mighty bone horror!
Anytime you use your Create Minions spell I will make sure one of them is a Bone Horror, if none are present.

#ANTIQUE_WHITE#The Bone Horror is a powerful undead bone construct with multiple bone-based attacks and a bone shield. Upon death it splits into 3 skeleton minions.
#GREY#You have captured %d souls out of the 100 needed.]]):tformat(o.captured_souls),
		answers = {
			{_t"That could be handy.", jump="welcome"},
		}
	}

	self:addChat{ id="bone_horror_ready",
		text = _t[[#GREY##{italic}#You feel the staff in your hand glowing with dark powers.#{normal}##LAST# At last! You sure took your sweet time #{italic}#"necromancer"#{normal}#!
Anyway, I have now enough souls to be able to summon the bone horror.
Do you wish to imbue me with a class talent point to finally become a real necromancer?

#ANTIQUE_WHITE#The Bone Horror is a powerful undead bone construct with multiple bone-based attacks and a bone shield. Upon death it splits into 3 skeleton minions.
]],
		answers = {
			{_t"I do. (#YELLOW#spend 1 class point#LAST#)", cond=function(npc, player) return player.unused_talents >= 1 end, action=function(npc, player) player.unused_talents = player.unused_talents - 1 o.unleashed_power = true end, jump="bone_horror_enabled"},
			{_t"I can't. (#LIGHT_RED#you need one class point#LAST#)", cond=function(npc, player) return player.unused_talents < 1 end, jump="bone_horror_mock"},
			{_t"Not now."},
		},
	}

	self:addChat{ id="bone_horror_mock",
		text = _t[[#GREY##{italic}#The staff shudders.#{normal}##LAST# Pathetic.]],
		answers = {
			{"..."}
		},
	}

	self:addChat{ id="bone_horror_enabled",
		text = _t[[#GREY##{italic}#The staff vibrates with great intensity.#{normal}##LAST# POWER! YES!
ALL SHALL BOW BEFORE MY MIGH... your might.]],
		answers = {
			{_t"Great!", action=function(npc, player)
				local o, item, inven_id = player:findInAllInventoriesBy("define_as", "BONESTAFF")
				if not o then return end

				player:onTakeoff(o, inven_id, true)
				o.wielder.can_summon_necrotic_bone_horror = 1
				player:onWear(o, inven_id, true)
			end}
		},
	}
	self:addChat{ id="bone_horror_disabled",
		text = _t[[#GREY##{italic}#The staff stays calm.#{normal}##LAST# Stupid useless pathetic excuse of a #{italic}#"necromancer"#{normal}#! Why refuse to use true power?!]],
		answers = {
			{_t"I have my reasons!", action=function(npc, player)
				local o, item, inven_id = player:findInAllInventoriesBy("define_as", "BONESTAFF")
				if not o then return end

				player:onTakeoff(o, inven_id, true)
				o.wielder.can_summon_necrotic_bone_horror = nil
				player:onWear(o, inven_id, true)
			end}
		},
	}
end)
