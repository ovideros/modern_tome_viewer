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

local _M = loadPrevious(...)
local Particles = require "engine.Particles"

local die = _M.die
function _M:die(src, ...)
	local ret = die(self, src, ...)

	if src and ((src.resolveSource and src:resolveSource().player) or src.player) then
		if self.type == "demon" then
			local p = game.party:findMember{main=true}
			world:gainAchievement("ASHES_DEMO", p, self)
			world:gainAchievement("ASHES_OLD_ONES", p, self)
		end
	end
	if self.name == "Ukllmswwik the Wise" then
		game.state.walrog_wanna_pop = game.state.walrog_wanna_pop or {}
		game.state.walrog_wanna_pop.ukllmswwik = true
	end
	if self.name == "Slasul" then
		game.state.walrog_wanna_pop = game.state.walrog_wanna_pop or {}
		game.state.walrog_wanna_pop.slasul = true
	end
	if game.state.walrog_wanna_pop and game.state.walrog_wanna_pop.slasul and game.state.walrog_wanna_pop.ukllmswwik then
		local Map = require "engine.Map"
		local Chat = require "engine.Chat"
		local npc = game.zone:makeEntityByName(game.level, "actor", "WALROG")
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if npc and x and y then
			game.zone:addEntity(game.level, npc, "actor", x, y)
			local chat = Chat.new("ashes-urhrok-walrog-pop", npc, game:getPlayer(true), {kind=self.name == "Slasul" and _t"naga" or _t"dragon"})
			chat:invoke()
		end
	end

	return ret
end

local onTemporaryValueChange = _M.onTemporaryValueChange
function _M:onTemporaryValueChange(prop, v, base)
	onTemporaryValueChange(self, prop, v, base)

	if prop == "artifact_power_obsidian" and not self.artifact_power_obsidian_updating then game:onTickEnd(function()
		self.artifact_power_obsidian_updating = true
		local power = self.artifact_power_obsidian
		self:inventoryApplyAll(function(inven, item, o) if o.on_obsidian_power_update then
			if inven.worn then self:onTakeoff(o, inven.id, true) end
			o:on_obsidian_power_update(self, inven.id, item, power)
			if inven.worn then self:onWear(o, inven.id, true) end
		end end)
		self.artifact_power_obsidian_updating = nil

		if power > 0 then
			self:removeParticles(self.artifact_power_obsidian_particle) self.artifact_power_obsidian_particle = nil
			if core.shader.allow("adv") then
				self.artifact_power_obsidian_particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.5, rotation=3.5, radius=1.5, img="black_treasures_boneshield"}, {type="black_artifacts", charges=math.ceil(power / 5)}))
			end
		else
			self:removeParticles(self.artifact_power_obsidian_particle) self.artifact_power_obsidian_particle = nil			
		end
	end) end
end

return _M
