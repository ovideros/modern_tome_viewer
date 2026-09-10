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
local Orcs = require("mod.class.OrcCampaign")

class:bindHook("ToME:load", Orcs.hookLoad)
class:bindHook("GameOptions:UIs", Orcs.hookGameOptionsUIs)
class:bindHook("MapGeneratorStatic:subgenRegister", Orcs.hookMapGeneratorStaticSubgenRegister)
class:bindHook("UISet:Minimalist:Load", Orcs.hookMinimalistLoad)
class:bindHook("CharacterSheet:Attack:power", Orcs.hookCharacterSheetAttackPower)
class:bindHook("Object:descPowerSource", Orcs.hookObjectDescPowerSource)
class:bindHook("Object:descWielder", Orcs.hookObjectDescWielder)
class:bindHook("Entity:loadList", Orcs.hookEntityLoadList)
class:bindHook("Actor:updateModdableTile:weapon", Orcs.hookupdateModdableTileWeapon)
class:bindHook("Actor:updateModdableTile:back", Orcs.hookupdateModdableTileBack)
class:bindHook("Actor:updateModdableTile:middle", Orcs.hookupdateModdableTileMiddle)
class:bindHook("Actor:updateModdableTile:front", Orcs.hookupdateModdableTileFront)
class:bindHook("Actor:actBase:Effects", Orcs.hookActorActBase)
class:bindHook("Actor:preUseTalent", Orcs.hookActorPreUseTalent)
class:bindHook("Actor:postUseTalent", Orcs.hookActorPostUseTalent)
class:bindHook("DamageProjector:base", Orcs.hookDamageProjectorBase)
class:bindHook("DamageProjector:final", Orcs.hookDamageProjectorFinal)
class:bindHook("Faction:setReaction", Orcs.hookFactionSetReaction)
class:bindHook("Inventory:makeTabs", Orcs.hookInventoryMakeTabs)
class:bindHook("Zone:loadEvents", Orcs.hookZoneLoadEvents)
class:bindHook("EscortRewards:givers", Orcs.hookEscortAssign)
class:bindHook("EscortRewards:rewards", Orcs.hookEscortReward)
class:bindHook("Chat:load", Orcs.hookChatLoad)
class:bindHook("Birther:donatorTiles", Orcs.hookBirtherDonatorTiles)
class:bindHook("InfiniteDungeon:getGrids", Orcs.hookInfiniteDungeonGetGrids)
class:bindHook("Possessor:birthBodies", Orcs.hookPossessorBirthBodies)
class:bindHook("Possessor:bodySnatcher:setupBody", Orcs.hookPossessorBodySnatcherSetupBody)

class:bindHook("TilesAttacher:list", function(self, data)
	data.list[#data.list+1] = {kind="dolls_race_orc_male", name="player/orc_male/base_01.png"}
	data.list[#data.list+1] = {kind="dolls_race_orc_female", name="player/orc_female/base_01.png"}
	data.list[#data.list+1] = {kind="dolls_race_yeti_all", name="player/yeti/base_01.png"}
	data.list[#data.list+1] = {kind="dolls_race_whitehoof_all", name="player/whitehoof/base_01.png"}
end)
