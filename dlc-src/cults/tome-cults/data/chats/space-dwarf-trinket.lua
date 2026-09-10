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

local FontPackage = require "engine.FontPackage"
local fontfile, fontsize = FontPackage:getFont("space_trinket")
setTextFont(fontfile, fontsize)

local jump = "default"
if player:attr("undead") then jump = "undead"
elseif player.descriptor and player.descriptor.subrace == "Dwarf" then jump = "dwarf"
elseif player.descriptor and player.descriptor.subrace == "Drem" then jump = "drem"
end
local hd = {"Chat:SpaceDwarfTrinket", jump=jump}
if cur_chat:triggerHook(hd) then jump = hd.jump end

newChat{ id="welcome",
	text = _t[[#YELLOW_GREEN##{bold}#Suddenly the strange metallic device emits some beeps and starts to speak. Somehow.#{normal}##LAST#
Uplink established with remote satellite. Activating emergency communication array.
Current user does not match with previous user records. Performing scan.]],
	answers = {
		{_t"..what?", jump=jump},
	}
}

newChat{ id="dwarf",
	text = _t[[#YELLOW_GREEN##{bold}#The device beeps again and speaks.#{normal}##LAST#
User's biological signature matches expected species, but does not match any identity records in database. Sending information for further analysis.

User added to database. I am now your personal assistant and will help you survive until further assistance can arrive. Enabling protective electromagnetic barrier and real time health monitoring.]],
	answers = {
		{_t"Expected species?", jump="end", action=function(npc, player)
			local _, item, inven_id = player:findInAllWornInventoriesByObject(true, npc)
			if inven_id then player:onTakeoff(npc, inven_id, true, true) end
			npc.helper_mode = true
			if inven_id then player:onWear(npc, inven_id, true, true) end
		end},
	}
}

newChat{ id="drem",
	text = _t[[#YELLOW_GREEN##{bold}#The device beeps again and speaks.#{normal}##LAST#
User's biological signature indicates dangerous degeneration of genome due to unknown factors. Sending information for further analysis.]],
	answers = {
		{_t"Genome?", jump="end"},
	}
}

newChat{ id="undead",
	text = _t[[#YELLOW_GREEN##{bold}#The device beeps again and speaks.#{normal}##LAST#
No signs of life detected. User appears to be still moving despite absence of living tissue. Sending information for further analysis.]],
	answers = {
		{_t"Never seen an undead have you?", jump="end"},
	}
}

newChat{ id="default",
	text = _t[[#YELLOW_GREEN##{bold}#The device beeps again and speaks.#{normal}##LAST#
User's biological signature does not match any currently known species in database. Sending information for further analysis.]],
	answers = {
		{_t"Database?", jump="end"},
	}
}

newChat{ id="end",
	text = _t[[#YELLOW_GREEN##{bold}#The machine beeps twice, then goes completely silent. Any further attempts to get it to speak prove futile.#{normal}##LAST#]],
	answers = {
		{_t"That was weird...", action=function(npc, player) world:gainAchievement("CULTS_DWARVEN_ORIGIN", game:getPlayer(true), "spacesuit") end},
	}
}

return "welcome"
