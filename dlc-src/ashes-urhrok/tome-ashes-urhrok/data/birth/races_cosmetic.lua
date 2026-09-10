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

for _, nrace in ipairs{"Human", "Elf", "Halfling", {"Dwarf","Dwarf"}, "Yeek", "Orc", "Yeti", {"Giant", "Ogre"}, {"Undead", "Ghoul"}, {"Undead", "Skeleton"}} do
	local nsubrace = nil
	if type(nrace) == "table" then nrace, nsubrace = unpack(nrace) end
	local race = getBirthDescriptor("race", nrace)
	local subrace = nil
	if nsubrace then subrace = getBirthDescriptor("subrace", nsubrace) end
	if race and (not nsubrace or subrace) then
		local item = subrace or race

		item.cosmetic_options = item.cosmetic_options or {}
		item.cosmetic_options.skin = item.cosmetic_options.skin or {}
		table.insert(item.cosmetic_options.skin, {name=_t"Demonic Red Skin", file="demonic_01", unlock="cosmetic_red_skin"})

		item.cosmetic_options.horns = item.cosmetic_options.horns or {}
		table.insert(item.cosmetic_options.horns, {name=_t"Demonic Horns 1", file="horns_01", unlock="cosmetic_doomhorns"})
		table.insert(item.cosmetic_options.horns, {name=_t"Demonic Horns 2", file="horns_02", unlock="cosmetic_doomhorns"})
		table.insert(item.cosmetic_options.horns, {name=_t"Demonic Horns 3", file="horns_03", unlock="cosmetic_doomhorns"})
		table.insert(item.cosmetic_options.horns, {name=_t"Demonic Horns 4", file="horns_04", unlock="cosmetic_doomhorns"})
		table.insert(item.cosmetic_options.horns, {name=_t"Demonic Horns 5", file="horns_05", unlock="cosmetic_doomhorns"})
		table.insert(item.cosmetic_options.horns, {name=_t"Demonic Horns 6", file="horns_06", unlock="cosmetic_doomhorns"})
		table.insert(item.cosmetic_options.horns, {name=_t"Demonic Horns 7", file="horns_07", unlock="cosmetic_doomhorns"})
		table.insert(item.cosmetic_options.horns, {name=_t"Demonic Horns 8", file="horns_08", unlock="cosmetic_doomhorns"})

		if item.name == "Ogre" then
			table.insert(item.cosmetic_options.tatoos, {name=_t"Demonic Tatoos 1", file="tattoo_demonic_01", unlock="cosmetic_doomhorns"})
			table.insert(item.cosmetic_options.tatoos, {name=_t"Demonic Tatoos 2", file="tattoo_demonic_02", unlock="cosmetic_doomhorns"})
			table.insert(item.cosmetic_options.tatoos, {name=_t"Demonic Tatoos 3", file="tattoo_demonic_03", unlock="cosmetic_doomhorns"})
			table.insert(item.cosmetic_options.tatoos, {name=_t"Demonic Tatoos 4", file="tattoo_demonic_04", unlock="cosmetic_doomhorns"})
			table.insert(item.cosmetic_options.tatoos, {name=_t"Demonic Tatoos 5", file="tattoo_demonic_05", unlock="cosmetic_doomhorns"})
			table.insert(item.cosmetic_options.tatoos, {name=_t"Demonic Tatoos 6", file="tattoo_demonic_06", unlock="cosmetic_doomhorns"})
			table.insert(item.cosmetic_options.tatoos, {name=_t"Demonic Tatoos 7", file="tattoo_demonic_07", unlock="cosmetic_doomhorns"})
			table.insert(item.cosmetic_options.tatoos, {name=_t"Demonic Tatoos 8", file="tattoo_demonic_08", unlock="cosmetic_doomhorns"})
		end
	end
end
