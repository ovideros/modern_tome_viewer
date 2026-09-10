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

local DeathDialog = require("mod.dialogs.DeathDialog")

newChat{ id="welcome",
	text = _t[[#{italic}##GREY#You feel the creeping blackness of oblivion overtaking you. Somehow, the darkness does not completely enclose around you. Something else is here with you. You feel as though it wishes to help you. Wordlessly, it reassures you that everything will be fine and that it can help you escape your fate. You only have to say yes.#{normal}#]],
	answers = {
		{_t"Silently you agree. You want to live!", jump="accept"},
		{_t"Silently you refuse, the presence creeps you out too much.", jump="die"},
	}
}

newChat{ id="die",
	text = _t[[#{italic}##GREY#The presence shirks back sadly, but you feel like it has respected your decision. It allows you to find the peace that only death can give.#{normal}#]],
	answers = {
		{_t"[die]", action=function(o, player)
			local d = DeathDialog.new(player)
			if not d.dont_show then game:registerDialog(d) end
		end},
	}
}

newChat{ id="accept",
	text = _t[[#{italic}##GREY#You do not want to die. Without a second thought, you accept its offer. Happily, the presence begins to do... something. You start to wake up and you feel life returning to your limbs. However, you have a splitting headache and your neck won't stop hurting. Just what did the presence do to bring you back from the brink?#{normal}#]],
	answers = {
		{_t"...", action=function(o, player)
			DeathDialog:cleanActor(player)
			DeathDialog:resurrectBasic(player, "fanged_collar")
			DeathDialog:restoreResources(player)

			player.equipdoll = "cults_beheaded"

			local _, item, inven_id = player:findInAllWornInventoriesByObject(true, o)
			if inven_id then player:onTakeoff(o, inven_id, true, true) end
			o.wielder.death_dialog = nil
			o.on_cantakeoff = function(self, who) return true end
			if inven_id then player:onWear(o, inven_id, true, true) end

			local base_list = require("mod.class.Object"):loadList("/data-cults/general/objects/special-misc.lua")
			base_list.__real_type = "object"
			local fakehead = game.zone:makeEntityByName(game.level, base_list, "FANGED_COLLAR_HEAD")
			if not fakehead then return end
			fakehead:identify(true)
			player:wearObject(fakehead, true, true)

			for tt, v in pairs(player.talents_types) do
				if tt:find("^race/") then
					player.talents_types[tt] = nil
					break
				end
			end

			player:learnTalentType("race/parasite", true)
			player:learnTalent(player.T_TAKE_A_BITE, true)
			player.cults_fanged_parasite = true

			game.log("#CRIMSON#Strange... You're pretty sure you died, but you're still here. It does feel like something important is missing, however. Your neck also feels incredibly sore and you have a splitting headache. Somehow, you get the subtle impression that you shouldn't look in a mirror anytime soon.")
		end},
	}
}

return "welcome"
