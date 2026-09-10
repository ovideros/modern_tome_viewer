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

setDialogWidth(800)

local visual_destructicus = engine.Entity.new{name=_t"DESTRUCTICUS!", image="terrain/worldmap/destructicus.png"}
local npc_destructicus = npc
local npc_imp = mod.class.NPC.new{name=_t"Fire Imp", image="npc/demon_minor_fire_imp.png"}
local npc_giant = mod.class.NPC.new{name=_t"Steam Giant Airship", image="npc/giant_steam_steam_giant_gunner.png", resolvers.nice_tile{tall=1}}
npc_giant:resolve()
npc_giant:resolve(nil, true)

newChat{ id="welcome",
	text = _t[[#LIGHT_GREEN#*#{bold}#DESTRUCTICUS, IMPOLITE PENETRATOR OF THE SKY#{normal}# stands before you, and as much as it pains you to admit it, Kaltor's advertisement wasn't flattering enough.  This may be the most unreasonably lethal device you've ever seen.  The sunlight, gleaming off its voratun body, seems dull compared to the intensely glowing mass of unstable runes on its tip; its surface has the ornate grooves of a metal that has been psionically reforged through hours of migraine-inducing concentration.  The bayonet mounted on the launching tube just seems like gloating.  This particular model appears to be equipped with an enclosed, fireproof booth around its control panel, and a built-in tea dispenser in said booth, which your fellow orcs have already taken the liberty of filling with looted Dwarven ale.  It is truly a thing of beauty.*#WHITE#]],
	answers = {
		{_t"[continue]", jump="welcome2"},
	}
}

newChat{ id="welcome2",
	text = _t[[#LIGHT_GREEN#*You enter the booth, sit down, and insert the key.  #{bold}#DESTRUCTICUS, IMPOLITE PENETRATOR OF THE SKY#{normal}# whirrs to life, its base slightly rotating underneath you.  A strange beaded panel slides in front of you, pins pushing out and pulling back by magnetic force to display the outline of an airship (and a tiny speck), and the words #{italic}#"AERIAL TARGETS FOUND: 2."#{normal}#*#WHITE#]],
	answers = {
		{_t"[continue]", jump="next"},
	}
}

newChat{ id="next",
	text = _t[[#LIGHT_GREEN#*#{italic}#"OBTAINING SCRYING LOCK...  OBTAINED."#{normal}#
 
The beaded panel is suddenly awash with colors, showing the colossal interior of the airship.  Steam Giant families huddle and weep, sorting through the few belongings they could take with them when fleeing; a guard sits on a pile of luggage and storage crates, head in her hands.  The view pans around the cabin, and you see a few crew members hurrying between the captain's quarters and the engine room, pausing to take worried glances out the window - at you.
 
This airship appears to be evacuating what's left of the Atmos Tribe.  With the press of a single button, you could eradicate the Steam Giant species forever.
 
You press a button labelled #{italic}#"SELECT NEXT TARGET"#{normal}#, and the panel shifts to show a very lost and very confused Fire Imp, flying in the air near nothing of importance.  Firing on it would have little effect whatsoever, aside from showing off DESTRUCTICUS's power in the most harmless way possible.*#WHITE#]],
	answers = {
		{_t"[shoot down the airship]", jump="airship", switch_npc=npc_giant},
		{_t"[shoot down the imp]", jump="imp", switch_npc=npc_imp},
	}
}

newChat{ id="airship",
	text = _t[[#LIGHT_GREEN#*Are you SURE you want to ERADICATE THE STEAM GIANTS?*#WHITE#]],
	answers = {
		{_t"[shoot down the airship]", jump="shoot_airship"},
		{_t"[back]", jump="next", switch_npc=visual_destructicus},
	}
}

newChat{ id="imp",
	text = _t[[#LIGHT_GREEN#*Are you SURE you want to WASTE YOUR SHOT?*#WHITE#]],
	answers = {
		{_t"[shoot down the imp]", jump="shoot_imp"},
		{_t"[back]", jump="next", switch_npc=visual_destructicus},
	}
}

newChat{ id="shoot_airship",
	text = _t[[#LIGHT_GREEN#*The Steam Giants are too great a threat to allow their escape - you will not have them simply return someday to finish what they attempted, and wipe out your Pride.  You press the #{italic}#"PREVIOUS TARGET"#{normal}# button, and fire on the airship.  There is a great roar and a flash of flame; you see its missile flying away from you through the window, as you see it racing towards your view, and the terrified passengers, on the scrying panel.

It reaches its mark, and the panel goes dark as a tremendous, multicolored blast fills your vision through the window.
 
The Steam Giants are no more.
 
The secondary charges from the warhead detonate, as burning debris falls into the sea, and the ongoing display serves as a signal to all the Orcs of Var'Eyal, and anyone else who may be watching: This is the fate of all who would try to eradicate the Orcs.  The previous millennia of oppression, genocide, and bullying are over: your people will never be pushed around like this again.
 
A nagging thought in the back of your head insists that you now know how the Sun Paladins felt, how King Toknor felt, how the halflings felt, how everyone that has always committed such atrocities against the Orcs felt.  It can keep whining all it wants - your people are finally safe.*#WHITE#]],
	answers = {
		{_t"[leave]", action=function(npc, player)
			npc_destructicus.add_displays[3] = nil
			npc_destructicus:removeAllMOs()
			npc_destructicus:altered()
			game.level.map:updateMap(dx, dy)
			npc_destructicus.block_move = true
			world:gainAchievement("ORCS_DESTRUCTICUS_AIRSHIP", player)
		end},
	}
}

newChat{ id="shoot_imp",
	text = _t[[#LIGHT_GREEN#*No...  you will not sink to the depths that King Toknor did, that the Sun Paladins did, that so many others have sunk to.  These refugees are not a threat, and could not possibly become one for quite some time...  but it might be for the best that they're made fully aware of what you're capable of, the fate you could've given them through so little effort, and given a display that'll make sure they remember that they owe their lives to your mercy.
 
You target the Fire Imp, and fire the weapon.  With a great roar and a flash of flame, #{bold}#DESTRUCTICUS, IMPOLITE PENETRATOR OF THE SKY#{normal}# races towards the increasingly distressed imp.  It panics, flitting to the side evasively as #{bold}#DESTRUCTICUS, IMPOLITE PENETRATOR OF THE SKY#{normal}# corrects its course to compensate, until it gives up and shrugs dejectedly; you can't hear the scrying panel over the missile's roaring, but you're fairly sure you can see the imp mouthing "this is 'blazing ridiculous."
 
It impacts, and your vision is filled with an enormous, multicolored explosion.  Shrapnel and debris falls harmlessly into a barren mountaintop, and a great booming noise can be heard across the continent.  
 
Taking a swig from a freshly-dispensed mug of ale, you switch the now-empty #{bold}#DESTRUCTICUS, IMPOLITE PENETRATOR OF THE SKY#{normal}#'s targeting controls over to the airship, and you see the giants cheering and hugging, crying in joy and relief.  A few wonder aloud if you meant to do that, but most recognize it as the display of mercy that it is.
 
As the secondary charges go off, the ongoing pyrotechnic display acts as a celebratory signal to the Steam Giants, the Orcs, and anyone else who may be watching: The war is over.  Var'Eyal, and the Orcs who now own it, will know peace for the first time in millennia.*#WHITE#]],
	answers = {
		{_t"[leave]", action=function(npc, player)
			npc_destructicus.add_displays[3] = nil
			npc_destructicus:removeAllMOs()
			npc_destructicus:altered()
			game.level.map:updateMap(dx, dy)
			npc_destructicus.block_move = true
			world:gainAchievement("ORCS_DESTRUCTICUS_IMP", player)
		end},
	}
}

return "welcome"
