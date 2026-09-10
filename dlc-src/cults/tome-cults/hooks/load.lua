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
local Cults = require("mod.class.CultsDLC")

class:bindHook("ToME:load", Cults.hookLoad)
class:bindHook("ToME:birthDone", Cults.hookBirthDone)
class:bindHook("ToME:runDone", Cults.hookRunDone)
class:bindHook("GameState:bonusZone", Cults.hookBonusZone)
class:bindHook("Entity:loadList", Cults.hookEntityLoadList)
class:bindHook("MapGeneratorStatic:subgenRegister", Cults.hookMapGeneratorStaticSubgenRegister)
class:bindHook("Zone:loadEvents", Cults.hookZoneLoadEvents)
class:bindHook("GameState:makeEventName", Cults.hookGameStateMakeEventName)
class:bindHook("Possessor:birthBodies", Cults.hookPossessorBirthBodies)
class:bindHook("Possessor:bodySnatcher:setupBody", Cults.hookPossessorBodySnatcherSetupBody)
class:bindHook("GameOptions:generateList", Cults.hookGameOptionsGenerateList)
class:bindHook("Chat:load", Cults.hookChatLoad)
class:bindHook("Birther:donatorTiles", Cults.hookBirtherDonatorTiles)

class:loadHooksFile("bonestaff.lua")
