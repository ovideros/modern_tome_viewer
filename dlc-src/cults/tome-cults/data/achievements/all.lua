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

--[=[
newAchievement{
	name = "First Rule of Entropic Wormholes", id = "CULTS_ENTROPIC_HANDICAP_200", category = "Forbidden Cults",
	show = "full",
	desc = _t[[Triumphed over an entropic clone with handicap 200%, a level over 30 and equal or over your own.]],
	mode = "player",
}

newAchievement{
	name = "Second Rule of Entropic Wormholes", id = "CULTS_ENTROPIC_HANDICAP_400", category = "Forbidden Cults",
	show = "full",
	desc = _t[[Triumphed over an entropic clone with handicap 400%, a level over 40 and equal or over your own.]],
	mode = "player",
}

newAchievement{
	name = "King of the Entropic Wormholes", id = "CULTS_ENTROPIC_HANDICAP_800", category = "Forbidden Cults",
	show = "full", huge = true,
	desc = _t[[Triumphed over an entropic clone with handicap 800%, a level over 50 and equal or over your own.]],
	mode = "player",
}
--]=]

newAchievement{
	name = "You were not supposed to see that!", id = "CULTS_READ_FORBIDDEN_TOME", category = "Forbidden Cults",
	show = "full",
	desc = _t[[Read a Forbidden Tome.]],
	mode = "player",
}

newAchievement{
	name = "Bookception!", id = "CULTS_BOOKCEPTION", category = "Forbidden Cults",
	show = "name",
	desc = _t[[Found the Forbidden Tome reward inside the Forbidden Tome: "Of Knowledge And Horrors".]],
	mode = "player",
}

newAchievement{
	name = "Recursive Home of Recursion", id = "CULTS_HOME_RECURSIVE", category = "Forbidden Cults",
	show = "name",
	desc = _t[[Left the Forbidden Tome: "Home, Horrific Home" on the floor of The Home Which Is Not.]],
	mode = "player",
}

newAchievement{
	name = "They Came From Outer Space!", id = "CULTS_DWARVEN_ORIGIN", category = "Forbidden Cults",
	show = "none",
	desc = _t[[Discovered the true origin of dwarves and drems.]],
	mode = "player",
	can_gain = function(self, who, which)
		self.conds = self.conds or {}
		self.conds[which] = true
		if self.conds.dremshor and self.conds.spacesuit and self.conds.shipyard then return true end
	end,
}

newAchievement{
	name = "The True Coward", id = "CULTS_TRUE_COWARD", category = "Forbidden Cults",
	show = "full",
	desc = _t[[Win without having saved Kroshkkur, Derth, the lost merchant, Melinda and lady Aeryn.]],
	mode = "player",
}
-- Yes addon author that reads this, you can bind hooks in many places ;)
class:bindHook("Winner", function(self, data)
	if data.kind ~= "sorcerers" then return end
	local p = game:getPlayer(true)
	-- Kroshkkur is cults only
	if not p:hasQuest("cults+start-cults") then return end

	-------------------------- Aeryn ------------------------
	-- We are on the end level so we can check that easily
	local aeryn = game.level:findEntity{define_as="HIGH_SUN_PALADIN_AERYN"}
	if aeryn and not aeryn.dead then print("True Coward check: aeryn is alive. FAILED!") return
	else print("True Coward check: aeryn is dead. GOOD!") end

	-------------------------- Melinda ------------------------
	if p:hasQuest("kryl-feijan-escape") then
		if p:hasQuest("kryl-feijan-escape"):isSuccess() then
			if not p:hasQuest("love-melinda") then
				print("True Coward check: melinda not in love but alive! FAILED!") return
			else
				if p:hasQuest("love-melinda"):isCompleted("death-beach") then
					print("True Coward check: melinda in love but died at the beach! GOOD!")
				else
					print("True Coward check: melinda in love and alive! FAILED!") return
				end
			end
		else
			print("True Coward check: melinda died in the crypt! GOOD!")
		end
	else
		print("True Coward check: melinda died in the crypt (no entered)! GOOD!")
	end

	-------------------------- Derth ------------------------
	if not p:hasQuest("lightning-overload") then
		print("True Coward check: Derth was never in danger! FAILED (and not possible?)!") return
	else
		if p:hasQuest("lightning-overload"):isSuccess() then
			print("True Coward check: Derth was saved! FAILED!") return
		else
			print("True Coward check: Derth was left to its troubles! GOOD!")
		end
	end

	-------------------------- Merchant ------------------------
	if p:hasQuest("lost-merchant") then
		if p:hasQuest("lost-merchant"):isCompleted("evil") then
			print("True Coward check: merchant was left to his own fate! GOOD!")
		else
			print("True Coward check: merchant was saved! FAILED!") return
		end
	else
		print("True Coward check: merchant died (no entered)! GOOD!")
	end

	-------------------------- Kroshkkur ------------------------
	if game.state.cults_kroshkkur_destroyed then
		print("True Coward check: Kroshkkur was left to be destroyed! GOOD!")
	else
		print("True Coward check: Kroshkkur was saved! FAILED!") return
	end

	-- Ok we are a true coward!
	world:gainAchievement("CULTS_TRUE_COWARD", p)
end)

newAchievement{
	name = "Sequence Master", id = "CULTS_EGRESS_MASTER", category = "Forbidden Cults",
	show = "full",
	desc = _t[[Use 5 different glyph sequences.]],
	mode = "player",
	can_gain = function(self, who, kind)
		self.kinds = self.kinds or {}
		if self.kinds[kind] then return end
		self.kinds[kind] = true
		self.nb = (self.nb or 0) + 1
		if self.nb >= 5 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 5"} end,
}

newAchievement{
	name = "Is that how it feels to be an escort quest?!", id = "CULTS_ESCORTED", category = "Forbidden Cults",
	show = "name",
	desc = _t[[Got saved from death in the Godfeaster by Malyu and managed to escape.]],
	mode = "player",
}

newAchievement{
	name = "Not Really Yourself", id = "CULTS_PARASITE", category = "Forbidden Cults",
	show = "name",
	desc = _t[[Let a parasitic horror take over your body and watch it grow in power.]],
	mode = "player",
}

newAchievement{
	name = "Myths of an age past", id = "CULTS_GODS",
	desc = _t[[Learned all there is to learn about the Gods and the Godslayers.]],
	show = "full",
	mode = "player",
	can_gain = function(self, who, obj)
		if not game.party:knownLore("cults-gods-0") then return false end
		if not game.party:knownLore("cults-gods-1") then return false end
		if not game.party:knownLore("cults-gods-2") then return false end
		if not game.party:knownLore("cults-gods-5") then return false end
		if not game.party:knownLore("cults-gods-8") then return false end
		if not game.party:knownLore("cults-gods-9") then return false end
		if not game.party:knownLore("cults-gods-12") then return false end
		if not game.party:knownLore("cults-gods-13") then return false end
		if not game.party:knownLore("cults-godslayers-0") then return false end
		if not game.party:knownLore("cults-godslayers-1") then return false end
		if not game.party:knownLore("cults-godslayers-2") then return false end
		if not game.party:knownLore("cults-godslayers-3") then return false end
		if not game.party:knownLore("cults-godslayers-4") then return false end
		if not game.party:knownLore("cults-godslayers-5") then return false end
		if not game.party:knownLore("cults-godslayers-6") then return false end
		if not game.party:knownLore("cults-godslayers-7") then return false end
		if not game.party:knownLore("cults-godslayers-8") then return false end
		if not game.party:knownLore("cults-godslayers-9") then return false end
		return true
	end,
}

newAchievement{
	name = "Dethroned", id = "CULTS_GLASS_GOLEM_NO_HEAL", category = "Forbidden Cults",
	show = "name",
	desc = _t[[Vanquished the Glass Golem without letting it use the glass throne to heal.]],
	mode = "player",
}

newAchievement{
	name = "A View From The Gallery", id = "CULTS_AGE_HAZE", category = "Forbidden Cults",
	show = "name",
	desc = _t[[Briefly lived as a lowly halfling during the time of the Sher'tuls.]],
	mode = "player",
}

newAchievement{
	name = "Entropy's End", id = "CULTS_ENTROPY_END", category = "Forbidden Cults",
	show = "full", huge=true,
	desc = _t[[Destroyed the Hypostasis of Entropy.]],
	mode = "player",
}
