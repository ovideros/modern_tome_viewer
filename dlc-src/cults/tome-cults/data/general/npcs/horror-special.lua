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

-- last updated:  10:46 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_HORROR",
	type = "horror", subtype = "eldritch",
	display = "h", color=colors.WHITE,
	blood_color = colors.BLUE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	faction = "horrors",

	stats = { str=20, dex=20, wil=20, mag=20, con=20, cun=20 },
	combat_armor = 5, combat_def = 10,
	combat = { dam=5, atk=10, apr=5, dammod={str=0.6} },
	infravision = 10,
	max_life = resolvers.rngavg(10,20),
	rank = 2,
	size_category = 3,

	no_breath = 1,
	fear_immune = 1,
}

newEntity{ base = "BASE_NPC_HORROR", define_as = "THE_ONE_THAT_HUNTS",
	name = "The One That Hunts", color=colors.GREEN,
	desc = _t"The relentless hunter. It never gives up, never surrenders.",
	level_range = {1, nil}, exp_worth = 0,
	rank = 3,
	autolevel = "caster",
	max_life = 400, life_rating = 25,
	combat = { dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 1.5), apr=0, dammod={mag=0.7} },
	combat_atk = 500,
	combat_dam = resolvers.levelup(1, 1, 3),
	ai = "tactical", ai_state = { ai_target="target_simple", ai_move="move_astar", talent_in=1, },
	ai_tactic = {safe_range = 3, closein = 0, go_melee = 0, escape=0, attack = 1, buff = 1},
	force_tentacle_hand = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1 }, -- We needs hands for the left one to be free for tentacle combat to work

	mana_regen = 20, insanity_regen = 20,
	max_mana = 500,

	combat_spellpower = resolvers.levelup(1, 1, 4),

	-- Lots of complexity here already, lets minimize player interaction beyond dealing with the obstruction/attacks
	invulnerable = 1,
	negative_status_effect_immune = 1,

	see_invisible = 20,
	ignore_from_combat_compute = true, -- Otherwise we cant ever leave combat to despawn it lol ;)
	timeout = 5,  -- Hidden counter for despawning that the ring item resets to 5 each turn, failsafe

	resolvers.talents{
		[Talents.T_MUTATED_HAND]={base=1, every=10},
		[Talents.T_CRUMBLE]={base=1, every=10},
		[Talents.T_TENDRILS_ERUPTION]={base=1, every=7},
		[Talents.T_TWISTED_EVOLUTION]={base=1, every=10},
		[Talents.T_BLIGHTLASH]={base=1, every=10},  -- We don't want the horror at melee so we give it a short CD ranged "autoattack" instead to put some damage pressure
	},
	
	resolvers.sustains_at_birth(),

	-- Removes the Hunter from whatever level it exists on, in theory redundant, theory sucks
	removeHunter = function(self)
		if self.summoned_level and self.summoned_level:hasEntity(self) then self.summoned_level:removeEntity(self) end
		if game.level:hasEntity(self) then game.level:removeEntity(self) end
		self.dead = true
		self.changed = true
	end,

	-- Treat any enemy of the ring wearer as an ally so Twisted Evolution always effects them
	reactionToward = function(self, target, no_reflection)
		if not self.ring_actor then return 100 end
		return -(self.ring_actor:reactionToward(target))
	end,
	
	-- Can't ever loose it!
	on_act = function(self)
		if not self.ring_actor or not self.ring_actor.x or not self.x then return end

		self.timeout = self.timeout - 1
		if self.timeout <= 0 or self.ring_actor.dead then
			self:disappear()
			return
		end
		
		if core.fov.distance(self.x, self.y, self.ring_actor.x, self.ring_actor.y) >= 10 then self:teleportRandom(self.ring_actor.x, self.ring_actor.y, 5) end
		self:setTarget(self.ring_actor)

		-- Grab nearby "allies" so we can evaluate whether to buff them yet
		local grids = core.fov.circle_grids(self.x, self.y, 10)
		local targets = {}
		local elite_near = false
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local target = game.level.map(x, y, engine.Map.ACTOR)
				if target and target.ai_target and target.ai_target.actor == self then target:setTarget(nil) end  -- Don't let things waste time targeting us
				if target and target ~= self and (target.ai_target and target.ai_target.actor == self.ring_actor) and self.ring_actor:reactionToward(target) < 0 then
					targets[#targets+1] = target
					if target.rank >= 3 then elite_near = true end
				end
			end
		end

		-- Are they in a tunnel we can blow up?
		local blocked_spaces = 0
		for dir, coord in pairs(util.adjacentCoords(self.ring_actor.x, self.ring_actor.y)) do
			if game.level.map:checkEntity(coord[1], coord[2], engine.Map.TERRAIN, "block_move") then
				blocked_spaces = blocked_spaces + 1
				if blocked_spaces >= 2 then break end
			end
		end

		-- If were adjacent to the player try to move to a not-adjacent space so were not acting as a shield for them
		if core.fov.distance(self.x, self.y, self.ring_actor.x, self.ring_actor.y) == 1 then
			local coords = {}
			for dir, coord in pairs(util.adjacentCoords(self.x, self.y)) do
				if core.fov.distance(self.ring_actor.x, self.ring_actor.y, coord[1], coord[2]) > 1 and not game.level.map:checkEntity(coord[1], coord[2], engine.Map.TERRAIN, "block_move") then
					coords[#coords+1] = {coord[1], coord[2]}
				end
			end
			local spot = rng.table(coords)
			if spot then
				self:move(spot[1], spot[2])
			end
		end

		if blocked_spaces >= 2 and not self:isTalentCoolingDown(self.T_CRUMBLE) then
			self:forceUseTalent(self.T_CRUMBLE, {ignore_energy = true})
			self.energy.value = 0
		elseif (#targets >= 3 or elite_near) and not self:isTalentCoolingDown(self.T_TWISTED_EVOLUTION) then
			self:forceUseTalent(self.T_TWISTED_EVOLUTION, {ignore_energy = true})
			self.energy.value = 0
		elseif rng.percent(20) and not self:isTalentCoolingDown(self.T_TENDRILS_ERUPTION) then  -- Essentially just biasing towards this, the normal AI will likely use it
			self:forceUseTalent(self.T_TENDRILS_ERUPTION, {ignore_energy = true, force_target=self.ring_actor})
			self.energy.value = 0
		elseif not self:isTalentCoolingDown(self.T_BLIGHTLASH) then
			self:forceUseTalent(self.T_BLIGHTLASH, {ignore_energy=true, force_target=self.ring_actor})
			self.energy.value = 0
		end
		-- There isn't much relevant AI behavior left except movement but fall through anyway
	end,
}
