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

name = _t"The Dead God Awaits"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = _t"Deep within Eyal you found a huge cavern containing some of the remains of the great dead god Amakthel..."
	desc[#desc+1] = _t"Along with what appears to be a living Sher'tul that seems to be trying to resurrect him."
	desc[#desc+1] = _t"It must be stopped at all cost, the Prides only just got their freedom back, you can not allow anything to take it away again!"
	if self:isStatus(self.DONE) then
		desc[#desc+1] = _t""
		desc[#desc+1] = _t"The Sher'tul Priest has been taken care of, Amakthel will keep on sleeping forever now. The Prides and the world are safe."
		desc[#desc+1] = _t"#LIGHT_GREEN#You have won the game!.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		self.use_ui = "quest-win"
		who:setQuestStatus(self.id, engine.Quest.DONE)
		game.level.data.no_worldport = nil
		game.log("#CRIMSON#You feel as if your Rod of Recall is working again in this area.")
		self:win("full")

		game:onLevelLoad("wilderness-1", function(zone, level)
			local spot = level:pickSpot{type="questpop", subtype="destructicus"}
			local g = zone:makeEntityByName(level, "terrain", "DESTRUCTICUS")
			if g and spot then
				zone:addEntity(level, g, "terrain", spot.x, spot.y)
				game.nicer_tiles:updateAround(level, spot.x, spot.y)

				local npc = mod.class.NPC.new{name=_t"Orc Warrior", image="npc/humanoid_orc_orc_elite_fighter.png"}
				local chat = require("engine.Chat").new("orcs+destructicus-lead", npc, game.player)
				chat:invoke()
			end
		end)
	end
end

function win(self, how)
	game:playAndStopMusic("Lords of the Sky.ogg")

	if game.state.orcs_nektosh_power_all_used then
		world:gainAchievement("ORCS_WIN_NEKTOSH", game.player)
	end
	world:gainAchievement("ORCS_DONE_AMAKTHEL", game.player)

	game:setAllowedBuild("adventurer", true)
	if game.difficulty == game.DIFFICULTY_NIGHTMARE then game:setAllowedBuild("difficulty_insane", true) end
	if game.difficulty == game.DIFFICULTY_INSANE then game:setAllowedBuild("difficulty_madness", true) end

	local p = game:getPlayer(true)
	p:inventoryApplyAll(function(inven, item, o) o:check("on_win") end)
	self:triggerHook{"Winner", how=how, kind="amakthel"}
	p.winner = how
	game:registerDialog(require("engine.dialogs.ShowText").new(_t"Winner", "win", {playername=p.name, how=how}, game.w * 0.6))

	if not config.settings.cheat then game:saveGame() end
end

function onWin(self, who)
	local desc = {}

	local seen_weissi = false
	if who:isQuestStatus("orcs+weissi", engine.Quest.DONE) then seen_weissi = true end

	desc[#desc+1] = _t"#GOLD#Well done! You have won the Tales of Maj'Eyal: Embers of Rage!#WHITE#"
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"You have thwarted the Steam Giants' genocidal plans, and avenged those killed in the attack on Kruk Pride.  Their desperate pact with the High Priest did nothing to stop you; the priest and his god lay dead at your feet, and you have ensured they will #{italic}#stay#{normal}# dead for the foreseeable future."
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"The humans, elves, and halflings will not be able to hurt your people again.  By destroying the farportal and denying King Tolak's army its glorious battle, you have ensured the safety of your people from the Allied Kingdoms, and by storming the Gates of Morning you have eliminated the last bearers of the West's hateful aggression in Var'Eyal."
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"For now, peace reigns.  You know that this will not last forever.  You may have repelled its vanguard, but the Kar'Haïb Dominion bides its time waiting for a weakness it can exploit; the smugglers' portals from Maj'Eyal remain undiscovered, and while neither you nor King Tolak has any remaining desire to take the other's continent, the fear of invasion will linger in the backs of your minds."..(seen_weissi and _t"  The messages of the Lost City give you cause to remain ever vigilant for the threats they warned of, including their authors, and you wonder what your people will do now that their struggle to escape eradication, one that has defined them for their entire recorded history, has ceased to be a concern." or "")
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"Regardless...  You just killed a god and gave your people the first chance to relax in thousands of years.  It's been a pretty good day."
	desc[#desc+1] = _t""
	desc[#desc+1] = _t"You may continue playing and enjoy the rest of the world.  Your soldiers may want to speak with you outside..."

	return 0, desc
end
