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

-- Defines AIs that can heal


-- check if the target can/should be healed
-- calls self.ai_state.heal_target_filter(self, target) if present
-- uses self.ai_state.healing_threshold = min %max life to heal (default 90)
local heal_filter = function(self, target)
	if not target or target.dead then return end
	if self.ai_state.heal_target_filter and not self.ai_state.heal_target_filter(self, target) then return false end
	if target.life > target.max_life*((self.ai_state.healing_threshold or 90)/100) then return false end
	return true
end

-- Find a friendly target that needs healing
-- this requires the ActorFOV interface, or an interface that provides self.fov.actors*
newAI("special_target_heal", function(self)
--game.log("%s running special target heal", self.name)
	local act = self.ai_target.actor
	if act and not act.dead and self:reactionToward(act) >= 0 and (heal_filter(self, act) and rng.percent(90)) then return act end -- keep same healing target

	-- Find closest ally that needs healing and target it
	-- Get list of actors ordered by distance
	local arr = self.fov.actors_dist
	for i = 1, #arr do
		act = self.fov.actors_dist[i]

		if act and not act.dead and self:reactionToward(act) >= 0 and heal_filter(self, act) then
			self.ai_target.actor = act
			print("AI found new healing target", self.uid, self.name, "::", act.uid, act.name, self.fov.actors[act].sqdist)
--game.log("%s found new healing target %s", self.name, act.name)
			return act
		end
	end
end)


-- Randomly use (healing) talents
-- Note: t.heal_check(self, t, ai_target) = talent-defined check for target healable by talent
newAI("special_dumb_heal", function(self)
--game.log("%s running special dumb heal", self.name)

	-- Find available healing talents that can be used on others
	local avail = {}
	local aitarget = self.ai_target.actor
--	local tx, ty =  aitarget.x, aitarget.y
	local target_dist = core.fov.distance(self.x, self.y, aitarget.x, aitarget.y)
	print("[AI] dumb heal checking healing talents for", aitarget.name, aitarget.uid)
	for tid, _ in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
		local tactical = t.tactical
		if type(tactical) == "function" then tactical = tactical(self, t, aitarget) end
--		if t.is_heal or (type(tactical) == "table" and tactical.heal) then
		if t.is_heal or (type(tactical) == "table" and tactical.heal and not (tactical.attack or tactical.attackarea or tactical.areaattack or tactical.disable)) then -- only uses direct healing spells
			local t_range = (t.range and self:getTalentRange(t) or 0) + (self:getTalentRadius(t) or 0)
--game.log("%s checking healing talent %s on target %s (%s, %s)", self.name, t.name, aitarget.name, aitarget.x, aitarget.y)
			local tg = self:getTalentTarget(t) or {type="bolt"}

--NOTE: Bug in ActorProject:canProject only counts tg.range and ignores tg.radius
			tg.range = t_range

--table.print(tg)
			if t.mode == "activated" and not self:isTalentCoolingDown(t) and target_dist <= t_range and self:preUseTalent(t, true) and self:canProject(tg, aitarget.x, aitarget.y) and (not t.heal_check or t.heal_check(self, t, aitarget)) then
--game.log("heal check: %s", t.heal_check and t.heal_check(self, t, aitarget))
				avail[#avail+1] = tid
				print(self.name, self.uid, "dumb ai can use healing talent", t.name, tid)
--			elseif t.mode == "sustained" and not self:isTalentCoolingDown(t) and not self:isTalentActive(t) and self:preUseTalent(t, true) then
--				avail[#avail+1] = tid
--				print(self.name, self.uid, "dumb ai talents can activate", t.name, tid)
			end
		end
	end
	if #avail > 0 then
		local tid = avail[rng.range(1, #avail)]
		print("dumb ai uses healing talent", tid, "on ", aitarget.name)
		if self:useTalent(tid, self, nil, nil, aitarget) then return tid end
	end
end)

newAI("special_dumb_heal_simple", function(self)
--game.log("%s running special dumb heal_simple", self.name)
	local ai_target = table.clone(self.ai_target) --save target
	local used_talent

	if rng.chance(self.ai_state.talent_in or 6) then -- One in "talent_in" chance of using a talent
		-- check for healing chance? self.ai_state.heal_chance
--game.log("#PINK#%s[%s] trying to heal allies", self.name, self.uid)
print(("[dumb_heal_simple]#PINK#%s[%s] trying to heal allies"):format(self.name, self.uid))
		if self:runAI("special_target_heal") then -- found an ally to heal
			used_talent = self:runAI("special_dumb_heal") -- heal them if possible
		end
--table.print(self.energy)
--		if not self.energy_used and ai_target and self:reactionToward(ai_target) < 0 then -- no healing done, try to take other actions against hostile targets
		if not self.energy.used then -- no healing done, try to take other actions against hostile targets
--game.log("#PINK#%s trying non-healing actions", self.name)
			if ai_target.actor and self:reactionToward(ai_target.actor) < 0 then
				self.ai_target = ai_target --no heals, stay with previous target
			end
			used_talent = self:runAI(self.ai_state.non_heal_ai or "dumb_talented_simple")
		end
	end
print(("[dumb_heal_simple] #PINK# healer %s[%s] used talent %s"):format(self.name, self.uid, used_talent))
--table.print(self.energy)
	if not self.energy.used then
		self:runAI(self.ai_state.ai_move or "move_simple")
	end
--game.log("#PINK# %s used talent %s", self.name, used_talent)
	if used_talent then self.energy.used = true end -- make sure NPC can use another talent after instant talents
	return true

end)
