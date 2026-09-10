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

-- Find a random spot
local list = game.state:findEventGridRadius(level, 1, 9)
if not list then return false end

local kind = rng.table{
	{ store="ORC_AAA_WEAPONS", name=_t"steamtech weaponry" },
	{ store="ORC_AAA_ARMORS", name=_t"defensive items" },
	{ store="ORC_AAA_TINKER", name=_t"tinkers" },
	{ store="ORC_AAA_ARCANE_PSI", name=_t"arcane and psi" },
	{ store="ORC_AAA_INSCRIPTIONS", name=_t"runes and infusions" },
	{ store="ORC_AAA_LITEDIGSTORE", name=_t"tools" },
}

local m = mod.class.NPC.new{
	define_as = "BASE_STEAM_DRONE",
	type = "construct", subtype = "mechanical",
	display = "A", color=colors.UMBER, image = "npc/construct_mechanical_ancient_automated_archive.png",
	name = ("Ancient Automated Archive (%s)"):tformat(kind.name),
	desc = _t[[An ancient archive of knowledge! You've heard tales of those triangular store devices, holding items and restoring them. For a price.]],
	level_range = {50, nil}, exp_worth = 0,
	faction = "unaligned",
	repairable = 1,
	never_anger = true,

	combat = { dam=1, atk=1, apr=1 },

	life_rating = 0, max_life = 1500,
	rank = 3,
	size_category = 3,
	power_source = {steamtech=true},
	can_talk = "orcs+aaa",
}
m:resolve()
m:resolve(nil, true)

m.store = game:getStore(kind.store)
m.store.faction = m.faction
m.store.store.sell_percent = rng.range(100, 220)
m.store.onBuy_real = m.store.onBuy
m.store.onBuy = function(self, ...)
	world:gainAchievement("ORCS_AAA_BUY", game.player)
	local inven = self:getInven("INVEN")
	if #inven == 0 then
		world:gainAchievement("ORCS_AAA_BUY_ALL", game.player)
	end
	return self:onBuy_real(...)
end

local x, y = list.center_x, list.center_y
game.zone:addEntity(game.level, m, "actor", x, y)

-- Grab items
for i = game.level.map:getObjectTotal(x, y), 1, -1 do
	local o = game.level.map:getObject(x, y, i)
	game.level.map:removeObject(x, y, i)

	o:identify(true)
	m.store:addObject(m.store.INVEN_INVEN, o)
end

return true
