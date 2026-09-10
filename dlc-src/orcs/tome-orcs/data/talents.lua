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

local oldNewTalent = Talents.newTalent
Talents.newTalent = function(self, t)
	local tt = engine.interface.ActorTalents.talents_types_def[t.type[1]]
	assert(tt, "No talent category "..tostring(t.type[1]).." for talent "..t.name)

	if tt.is_steam then t.is_steam = true end

	return oldNewTalent(self, t)
end

Talents.is_a_type.is_steam = _t"a steamtech power"
Talents.is_a_type.is_technomancy = _t"a technomancy spell"

damDesc = Talents.main_env.damDesc
divi_req1 = Talents.main_env.divi_req1
divi_req2 = Talents.main_env.divi_req2
divi_req3 = Talents.main_env.divi_req3
divi_req4 = Talents.main_env.divi_req4
divi_req5 = Talents.main_env.divi_req5
divi_req_high1 = Talents.main_env.divi_req_high1
divi_req_high2 = Talents.main_env.divi_req_high2
divi_req_high3 = Talents.main_env.divi_req_high3
divi_req_high4 = Talents.main_env.divi_req_high4
divi_req_high5 = Talents.main_env.divi_req_high5

gifts_req1 = Talents.main_env.gifts_req1
gifts_req2 = Talents.main_env.gifts_req2
gifts_req3 = Talents.main_env.gifts_req3
gifts_req4 = Talents.main_env.gifts_req4
gifts_req5 = Talents.main_env.gifts_req5
gifts_req_high1 = Talents.main_env.gifts_req_high1
gifts_req_high2 = Talents.main_env.gifts_req_high2
gifts_req_high3 = Talents.main_env.gifts_req_high3
gifts_req_high4 = Talents.main_env.gifts_req_high4
gifts_req_high5 = Talents.main_env.gifts_req_high5

spells_req1 = Talents.main_env.spells_req1
spells_req2 = Talents.main_env.spells_req2
spells_req3 = Talents.main_env.spells_req3
spells_req4 = Talents.main_env.spells_req4
spells_req5 = Talents.main_env.spells_req5
spells_req_high1 = Talents.main_env.spells_req_high1
spells_req_high2 = Talents.main_env.spells_req_high2
spells_req_high3 = Talents.main_env.spells_req_high3
spells_req_high4 = Talents.main_env.spells_req_high4
spells_req_high5 = Talents.main_env.spells_req_high5

psi_wil_req1 = Talents.main_env.psi_wil_req1
psi_wil_req2 = Talents.main_env.psi_wil_req2
psi_wil_req3 = Talents.main_env.psi_wil_req3
psi_wil_req4 = Talents.main_env.psi_wil_req4
psi_wil_req5 = Talents.main_env.psi_wil_req5
psi_wil_req_high1 = Talents.main_env.psi_wil_req_high1
psi_wil_req_high2 = Talents.main_env.psi_wil_req_high2
psi_wil_req_high3 = Talents.main_env.psi_wil_req_high3
psi_wil_req_high4 = Talents.main_env.psi_wil_req_high4
psi_wil_req_high5 = Talents.main_env.psi_wil_req_high5

psi_cun_req1 = Talents.main_env.psi_cun_req1
psi_cun_req2 = Talents.main_env.psi_cun_req2
psi_cun_req3 = Talents.main_env.psi_cun_req3
psi_cun_req4 = Talents.main_env.psi_cun_req4
psi_cun_req5 = Talents.main_env.psi_cun_req5
psi_cun_req_high1 = Talents.main_env.psi_cun_req_high1
psi_cun_req_high2 = Talents.main_env.psi_cun_req_high2
psi_cun_req_high3 = Talents.main_env.psi_cun_req_high3
psi_cun_req_high4 = Talents.main_env.psi_cun_req_high4
psi_cun_req_high5 = Talents.main_env.psi_cun_req_high5

racial_req1 = Talents.main_env.racial_req1
racial_req2 = Talents.main_env.racial_req2
racial_req3 = Talents.main_env.racial_req3
racial_req4 = Talents.main_env.racial_req4

load("/data-orcs/talents/steam/steam.lua")
load("/data-orcs/talents/steam/inscriptions.lua")
load("/data-orcs/talents/misc/npcs.lua")
load("/data-orcs/talents/misc/races.lua")
load("/data-orcs/talents/misc/objects.lua")
load("/data-orcs/talents/celestial/celestial-empyreal.lua")
load("/data-orcs/talents/spells/spells.lua")
load("/data-orcs/talents/psionic/psionic.lua")
load("/data-orcs/talents/uber/uber.lua")
