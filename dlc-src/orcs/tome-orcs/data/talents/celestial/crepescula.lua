

newTalent{
	name = "Twilit Echoes",
	type = {"celestial/crepescula", 2},
	require = divi_req_high2,
	range = 7,
	positive = 20,
	negative = 20,
	points = 5,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getEchoDur = function(self, t) return 3 end,
	getDarkEcho = function(self, t) return self:combatTalentScale(t, 0.075, 0.15) end,
	getSlowPer = function(self, t) return 0.001 end,
	getSlowMax = function(self, t) return t.getSlowPer(self, t) * self:combatTalentSpellDamage(t, 150, 400) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then return nil end
		target:setEffect(target.EFF_TWILIT_ECHOES, t.getDuration(self, t), {echo_dur = 3, dam_factor = t.getDarkEcho(self,t), slow_per = t.getSlowPer(self, t), slow_max = t.getSlowMax(self, t)})
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local echo_dur = t.getEchoDur(self, t)
		local slow_per = t.getSlowPer(self, t)
		local slow_max = t.getSlowMax(self, t)
		local echo_factor = t.getDarkEcho(self, t)
		return ([[The target feels the echoes of all your light and dark damage for %d turns. 

Light damage slows the target by %0.2f%% per point of damage dealt for %d turns, up to a maximum of %d%% at %d damage.
Dark damage creates an effect at the tile for %d turns which deals %d%% of the damage dealt each turn. It will be refreshed as long as the target continues taking damage from it or another source while Twilit Echoes is active, dealing its remaining damage over the new duration as well as the new damage.]])
		:tformat(duration, slow_per * 100, echo_dur, slow_max * 100, slow_max/slow_per, echo_dur, 100 * echo_factor)
	end,
}