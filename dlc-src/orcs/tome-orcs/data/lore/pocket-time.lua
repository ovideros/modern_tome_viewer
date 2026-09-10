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

Lore.init_pocket_time_data = function()
	Lore.pocket_time_winner = {
		name = _t"Maltoth", race = _t"a human", class = _t"paradox mage",
		himher = _t"him", heshe = _t"he", HeShe = _t"He", hisher = _t"his",
		sacrifice = false, is_yeek = false,
	}

	if world.majeyal_campaign_last_winner then
		local pwinner = world.majeyal_campaign_last_winner
		if pwinner.version[1] == game.__mod_info.version[1] and	pwinner.version[2] == game.__mod_info.version[2] and pwinner.version[3] == game.__mod_info.version[3] and table.same_values(pwinner.addons or {}, table.keys(game.__mod_info.addons)) then
			Lore.pocket_time_winner.name = pwinner.name
			Lore.pocket_time_winner.race = _t(pwinner.descriptor.subrace, "birth descriptor name"):lower():a_an()
			Lore.pocket_time_winner.class = _t(pwinner.descriptor.subclass, "birth descriptor name"):lower()
			Lore.pocket_time_winner.is_yeek = pwinner.descriptor.subrace == "Yeek"
			Lore.pocket_time_winner.sacrifice = pwinner.winner == "self-sacrifice"
			Lore.pocket_time_winner.himher = pwinner.female and _t"her" or _t"him"
			Lore.pocket_time_winner.heshe = pwinner.female and _t"she" or _t"he"
			Lore.pocket_time_winner.HeShe = pwinner.female and _t"She" or _t"He"
			Lore.pocket_time_winner.hisher = pwinner.female and _t"her" or _t"his"
		end
	end
end

newLore{
	id = "pocket-time-1",
	category = "pocket of distorted time",
	name = _t"a telepathic message <Rough Drafts>",
	template = true, lore = _t[[<? Lore.init_pocket_time_data() ?>Once upon a time, there was a Halfling alchemist by the name of <?=Lore.pocket_time_winner.name?>.  Alongside her trusty golem, she marched into the Trollmire, disposing of all foes in her path; when she encountered Prox, though, and he bent down to roar mere inches from her face, well inside a bomb's blast radius, she panicked and pulled a vial off her belt--

Once upon a time, there was a Dwarven berserker by the name of <?=Lore.pocket_time_winner.name?>.  Fleeing through the halls of Reknor as his friend was cut down by Orcish warriors, he ran face-first into a couple of them and--

Once upon a time, there was a Cornac rogue by the name of <?=Lore.pocket_time_winner.name?>.  His traps made short work of Prox, but when Bill the Stone Troll tossed him around his lair, he lost his bearings and stepped on--

Once upon a time--

Once upon a time, there was a great hero, a Dwarven Stone-Warden by the name of <?=Lore.pocket_time_winner.name?>, who began her adventure swearing incomprehensibly about unfairness before shrugging and continuing onward.  She escaped from Reknor with her closest companion, used her natural powers to purge the Deep Bellow and The Maze of the corrupting forces therein, rescued a strange new creature called a "yeek" from the clutches of the murderous Subject Z, and even shrugged off boulders thrown at her by the giants of Daikara as she inexorably pushed forward, slaying so many threats that had harmed so many people before her.  She uncovered the long-lost Conclave Vault and put the last of the original Ogres to rest, rescued a damsel from the clutches of the Sect of Kryl-Feijan, and finally found herself standing at the gates of the tower of Dreadfell, her skills honed by her trials and laden with exotic equipment found in her travels.  Climbing through the waves of shambling undead, she finally faced The Master head-on, when a skeletal warrior struck her from behind.  A stunning blow from its warhammer struck her right where she'd applied a wild infusion, the only one she had.  Dazed and stumbling, trying to invoke its power, she only became lucid when a terrible cold crept up her limbs, encasing her in ice--

Once upon a time, there was a Thalore summoner by the name of <?=Lore.pocket_time_winner.name?>, who began her adventure right next to a snake that was unnaturally skilled with temporal magic--

Once upon a time, there was a terrible villain, an Ogre reaver by the name of <?=Lore.pocket_time_winner.name?>, who found himself fascinated by the corrupted crystalline structures of the Spellblaze Caverns.  He first drowned a Last Hope guard in the dead of night to steal her enchanted ring, then began to leave a trail of destruction throughout the land, feeding on the strength of those hewn with his battleaxe or impaled with his longsword, and growing ever more powerful with every death he caused.  He joined the cause of the Grand Corruptor in an assault on Zigur to ensure that nothing could stop his arcane plagues from spreading, then took the Heart of the Sandworm Queen to Spellblaze-tainted lands to pervert its natural blessing into a blighted font of suffering.  He sat and watched as a cult sacrificed a maiden to summon their demonic master just so he could kill it himself, and salivated at the prospect of traveling to the Far East and seeing four armies' worth of Orcs broken and bleeding, tumors and boils spreading across their skin as the life slowly left their eyes.  The finest soldiers of Vor Pride could do nothing to prevent him from raiding their armory, but one crippled and diseased Orc pulled himself up against its sealed doors and begged him not to open them; he simply laughed before crushing his skull under his boot as he walked toward it, then kicked the door down, only to feel his bone armor disintegrate under a storm of breath attacks from an army of unspeakably powerful multi-hued wyrms.  Even <?=Lore.pocket_time_winner.name?> knew when he had to flee from a fight, and clenched his fist as he charged his Phase Door rune; when the blinding flash of light cleared, he found himself mere inches from--

Once upon a time, there was a Doomelf by the name of <?=Lore.pocket_time_winner.name?>, freed from demonic mind-control by a lucky meteor strike, who set out to use her new-found powers to escape the orbital hell on which she was trapped.  Investigators and mutilators, designed for torturing captives but far too frail for direct combat, fell under her infernal blade nearly as easily as the unaltered Children of Ruby who had few skills outside clerical work, and soon she began to feel that the demonic magic she had been imbued with may have made her nearly unstoppable.  When a demonic statue called out to her, she thought nothing of trying to absorb more of its power, barely even noticing when the statue called forth a Champion of Urh'Rok--

Once upon a time, there was a Shalore Adventurer by the name of <?=Lore.pocket_time_winner.name?>, who was quite certain of what he was doing.  He'd learned an extremely uncommon set of abilities - great talent with unarmed martial arts, some psychic potential to swing a staff in the air while leaving his hands free, stone magic that used his punches as a focus to blast foes with a hailstorm of earthen missiles - and once he had enough practice to master a few of these, he started effortlessly destroying any foe he faced... until he encountered the Weirdling Beast.  The battle was intense, and soon, both were on the verge of death, on opposite sides of the fortress's foyer; the Adventurer knew he couldn't afford to rush in close to finish the beast off, so he launched a pair of earthen missiles at it instead.  However, the moment they left his hands, he felt the grip of hard bone around his waist, legs, and back, pulling him at an incomprehensible speed into the Weirdling Beast's grasp.  Perhaps <?=Lore.pocket_time_winner.name?> could have survived an ensuing fistfight, but he had been pulled faster than his own missiles could fly, and now he found himself between the stony projectiles and their original target--

Once upon a time, a great spirit put down its pen and closed its notebook, sighing in frustration.]],
}

newLore{
	id = "pocket-time-2",
	category = "pocket of distorted time",
	name = _t"a telepathic message <The Tale of Maj'Eyal>",
	template = true, lore = _t[[<? Lore.init_pocket_time_data() ?>Once upon a time, there was <?=Lore.pocket_time_winner.race?> <?=Lore.pocket_time_winner.class?> by the name of <?=Lore.pocket_time_winner.name?>.  <?=Lore.pocket_time_winner.HeShe?> came from humble beginnings, dealing with minor threats like the mad nature-guardian Norgos or yet another reincarnation of Kor'Pul, but as <?=Lore.pocket_time_winner.heshe?> traveled throughout the land, <?=Lore.pocket_time_winner.heshe?> grew stronger and more skilled, and began to take on ever more fearsome opponents.  <?=Lore.pocket_time_winner.HeShe?> purged the corrupted horrors of Yiikgur and claimed the long-forgotten flying fortress for <?=Lore.pocket_time_winner.himher?>self, but even this was a mere stepping stone on the way to the tower of Dreadfell.  The Master, a necromancer of terrible power and even more terrible sadism, waited for <?=Lore.pocket_time_winner.himher?> there with an army of the undead, clutching an ancient weapon of incredible power...  but <?=Lore.pocket_time_winner.name?> bravely pressed on, cutting through the hordes of skeletons and ghouls, prevailing where so many others had failed.  Eventually, <?=Lore.pocket_time_winner.heshe?> stood victorious over the vampire's body, and took the Staff of Absorption with <?=Lore.pocket_time_winner.himher?>, safely away from undead hands.  Maj'Eyal was safe once more.

Unfortunately, what awaited <?=Lore.pocket_time_winner.himher?> next was a quest with even greater stakes.  Orcs, a once-thought-vanquished threat, had reappeared in force in Maj'Eyal!  Despite <?=Lore.pocket_time_winner.name?>'s best efforts to store the staff in a safe place, the orcs stole it, and <?=Lore.pocket_time_winner.name?> was forced to follow them all the way through an ancient, impossibly advanced Farportal to get it back.  The portal crackled and whirled as <?=Lore.pocket_time_winner.name?> held up the Orb of Many Ways to activate it; <?=Lore.pocket_time_winner.heshe?> took a deep breath, closed <?=Lore.pocket_time_winner.hisher?> eyes, and a moment later, <?=Lore.pocket_time_winner.heshe?> became the first person to go from Maj'Eyal to Var'Eyal, the distant continent of the Far East, in centuries.

A long-lost band of allies, the people of Sunwall, awaited <?=Lore.pocket_time_winner.himher?> there - as did four armies of orcs!  Once again, though, <?=Lore.pocket_time_winner.name?> refused to back down when the fate of the world was in <?=Lore.pocket_time_winner.hisher?> hands.  Blessed by High Paladin Aeryn, <?=Lore.pocket_time_winner.heshe?> set out to reclaim the Staff of Absorption from the Orcish Prides.  Storms of fire and ice assaulted <?=Lore.pocket_time_winner.himher?> on <?=Lore.pocket_time_winner.hisher?> way to challenge the grand magus Vor, a foe who could call forth the heavens themselves to pulverize <?=Lore.pocket_time_winner.himher?>, but his meteors weren't enough to stop <?=Lore.pocket_time_winner.himher?>; the dragon-tamers of Gorbat Pride, master wyrmics with unparalleled control over the forces of Nature, merely gave <?=Lore.pocket_time_winner.name?> the opportunity to become the world's most accomplished dragonslayer.  The bone fortress of Rak'Shor Pride crumbled as <?=Lore.pocket_time_winner.heshe?> put its inhabitants to rest, and even when orcs stood in <?=Lore.pocket_time_winner.hisher?> way to do what orcs are best known for at Grushnak Pride, their brute force with strength and steel was simply not strong enough.
<? if not Lore.pocket_time_winner.sacrifice then ?>
But right as <?=Lore.pocket_time_winner.heshe?> set out to climb the tower, <?=Lore.pocket_time_winner.heshe?> got an urgent message from High Paladin Aeryn!  <?=Lore.pocket_time_winner.HeShe?> journeyed across the wastes of Eruan with haste, arriving at another farportal.  Without a thought to where it led, <?=Lore.pocket_time_winner.name?> rushed in at her orders; <?=Lore.pocket_time_winner.heshe?> found <?=Lore.pocket_time_winner.himher?>self in a vast plain of fire and magma, with a narrow stretch of land leading far into the distance.  Behind <?=Lore.pocket_time_winner.himher?>, <?=Lore.pocket_time_winner.heshe?> heard clanging and crashing - the orcs were after <?=Lore.pocket_time_winner.himher?> even here, and the Sun Paladins were valiantly holding the line to keep them away.  They told <?=Lore.pocket_time_winner.himher?> to do one thing: run!  And run <?=Lore.pocket_time_winner.heshe?> did, cutting through and sidestepping countless great red drakes in the process, the glowing magma spitting and bubbling on either side of the perilous stony bridge.  At the end, <?=Lore.pocket_time_winner.heshe?> caught the sight of the Staff for the first time since Maj'Eyal - and the culprits were, surprisingly, a human and an elf!  These two sorcerers, driven by a combination of good intentions, sheer madness, and tragic love, had manipulated the Orc Prides into stealing the staff for them - to what end, <?=Lore.pocket_time_winner.heshe?> still did not know.  Nonetheless, the spell they were channeling was thwarted, and <?=Lore.pocket_time_winner.heshe?> returned to the East victorious, ready to assault the sorcerers' lair of the High Peak.

Threats even greater than any <?=Lore.pocket_time_winner.heshe?> had faced before awaited <?=Lore.pocket_time_winner.himher?>.  The tower itself was trying to stop <?=Lore.pocket_time_winner.himher?>, changing conditions assaulting <?=Lore.pocket_time_winner.hisher?> defenses on each floor, combined with an army of every foe imaginable, but <?=Lore.pocket_time_winner.heshe?> would not be hindered, and pushed past everything on <?=Lore.pocket_time_winner.hisher?> final ascent.  On the top floor, <?=Lore.pocket_time_winner.heshe?> was finally met with the sorcerers, Argoniel and Elandar, face-to-face.  They told <?=Lore.pocket_time_winner.himher?> of their plans with the staff, ones far more dangerous than mere global domination - no, they sought to bring back a threat that only the long-gone Sher'Tul could have dealt with.  A threat long forgotten, lost and tumbling between the stars: Gerlyk, a god driven mad from isolation.  They had to be stopped!

Fortunately, <?=Lore.pocket_time_winner.name?> did not go into this battle alone.  High Paladin Aeryn arrived to fight by <?=Lore.pocket_time_winner.hisher?> side, and the four of them clashed in a fight for the fate of Eyal.  Even with Argoniel's fearsome bone-armor whirling around her, even with Elandar's impressive spells flying through the air, even with the portals summoning foes of all sorts to join the battle...  in the end, the forces of good prevailed.  The sorcerers were defeated, and the portal was sealed, forever.

Eyal had been saved, thanks to <?=Lore.pocket_time_winner.name?>.  Most of the world may not have known what happened at the top of High Peak, but they were in the grips of peril, and were now free of it.  None can say what our champion did after that...  but whatever it was, <?=Lore.pocket_time_winner.heshe?>, and all life on Eyal, lived happily ever after.
<? else ?>
Threats even greater than any <?=Lore.pocket_time_winner.heshe?> had faced before awaited <?=Lore.pocket_time_winner.himher?> in the tower of High Peak.  The tower itself was trying to stop <?=Lore.pocket_time_winner.himher?>, changing conditions assaulting <?=Lore.pocket_time_winner.hisher?> defenses on each floor, combined with an army of every foe imaginable, but <?=Lore.pocket_time_winner.heshe?> would not be hindered, and pushed past everything on <?=Lore.pocket_time_winner.hisher?> final ascent.  Alas, the most trying challenge of these was on the penultimate floor: High Paladin Aeryn.  The Gates of Morning had been destroyed, because <?=Lore.pocket_time_winner.name?> didn't manage to stop the ritual of the Charred Scar, despite the calls to help <?=Lore.pocket_time_winner.heshe?> heard.  She blamed <?=Lore.pocket_time_winner.name?> for this, and the two fought...  but Aeryn relented once <?=Lore.pocket_time_winner.heshe?> realized <?=Lore.pocket_time_winner.heshe?> had been beaten.

On the top floor, <?=Lore.pocket_time_winner.heshe?> was finally met with the sorcerers, Argoniel and Elandar, face-to-face.  They told <?=Lore.pocket_time_winner.himher?> of their plans with the staff, ones far more dangerous than mere global domination - no, they sought to bring back a threat that only the long-gone Sher'Tul could have dealt with.  A threat long forgotten, lost and tumbling between the stars: Gerlyk, a god driven mad from isolation.  They had to be stopped!

The three of them clashed in a fight for the fate of Eyal.  Even with Argoniel's fearsome bone-armor whirling around her, even with Elandar's impressive spells flying through the air, even with the portals summoning foes of all sorts to join the battle...  in the end, the forces of good prevailed.  The sorcerers were defeated, and the portal was sealed, forever...  but at a terrible cost.  <?=Lore.pocket_time_winner.name?> had seen the farportal - the sorcerers had managed to charge it with too much energy, and the Staff alone was not enough to stop it.  <?=Lore.pocket_time_winner.HeShe?> selflessly made the ultimate sacrifice, using <?=Lore.pocket_time_winner.hisher?> life to destroy the portal.

None on Eyal would ever know of <?=Lore.pocket_time_winner.hisher?> sacrifice, or that they were ever in danger...  but thanks to our champion, they could live happily ever after.
<? end ?>
<? if Lore.pocket_time_winner.is_yeek then ?>[i]...Well, let's just assume that's how it went, anyway.  The alternative would make it quite difficult to tell the next story.[/i]<? end ?>
]],
}

newLore{
	id = "pocket-time-3",
	category = "pocket of distorted time",
	name = _t"a telepathic message <The Eidolon>",
	template = true, lore = _t[[<? Lore.init_pocket_time_data() ?>Once upon a time, there was a spirit known as the Eidolon, older than anything on Eyal.  Some called it a savior, a bringer of order and justice; others, a dark god, spreading terror for its own amusement.  Such mortal classifications are hopelessly inadequate to describe the incomprehensibly far-sighted motivations of a being nearly as old as time itself...  but if you were to ask the Eidolon, it would call itself a storyteller.

Whether the story exists only in its own head or is reflected across the Shandral system, none can say - but the Eidolon needed heroes for its story, as it always has.  Today, the hero it needed was a master of battle, the likes of which had not been seen since the age of Garkul the Devourer.  It considered a few different options, deeming many failures, some potentially adequate with a few mistakes forgiven, and only one to be finally chosen.  Its chosen protagonist met every challenge put before <?=Lore.pocket_time_winner.himher?>, sometimes with ease, often with difficulty, occasionally escaping through luck alone, but eventually stood atop the High Peak, having saved Eyal from the greatest threat it had ever faced<? if Lore.pocket_time_winner.sacrifice then ?> by sacrificing <?=Lore.pocket_time_winner.himher?>self to shut down the Sorcerers' farportal<? end ?>.
<? if not Lore.pocket_time_winner.sacrifice then ?>
And what then?  A master of battle has nothing to do once the battle is won.  <?=Lore.pocket_time_winner.HeShe?> could've sought out harder foes, but the only ones <?=Lore.pocket_time_winner.heshe?> would be likely to find would either be pointless to face, or outright harmful to the citizens of Eyal; they would add nothing to the story.  The Eidolon could have introduced a foe strong enough to finally destroy <?=Lore.pocket_time_winner.himher?>, but what kind of ending would that be?  Instead, the Eidolon decided to let its protagonist retire as <?=Lore.pocket_time_winner.heshe?> wished...  whether <?=Lore.pocket_time_winner.heshe?> chose to descend to inevitable doom in the Infinite Dungeon, to attempt to slay impossible foes like Atamathon and Linaniil, or to simply retire and live out the rest of <?=Lore.pocket_time_winner.hisher?> days in the reclaimed Sher'Tul fortress.  In any case, the story was over; there wasn't any room left for the rest of <?=Lore.pocket_time_winner.name?>'s life.<? end ?>

Of course, a character like that can't simply be thrown away.  The story may be over, but it can be told again and again, and as such there would be as many Heroes of Maj'Eyal as there were people who'd listen to the story, each hearing it and imagining it slightly differently from the next.  Even the storyteller would dream up more situations for the Hero of Maj'Eyal, always wondering - what if I found an even match for this first warrior?  Don't I owe <?=Lore.pocket_time_winner.himher?> the reward of a fight <?=Lore.pocket_time_winner.heshe?> would be eager to participate in, and one that would give <?=Lore.pocket_time_winner.himher?> the challenge <?=Lore.pocket_time_winner.heshe?> craved so dearly?  Wouldn't such a duel be worth writing about?  And so, it kept <?=Lore.pocket_time_winner.name?> in mind, promising to remember <?=Lore.pocket_time_winner.himher?> whenever it found or created a threat worthy of <?=Lore.pocket_time_winner.himher?>.

[b]<?=player.name?>[/b], you crave the thrill and tension of a close fight as much as <?=Lore.pocket_time_winner.heshe?> does.  I owe this opportunity to you in life, and the Scourge from the West in <?=Lore.pocket_time_winner.hisher?> legend; all I ask in return is that the two of you give me a battle that the people of Eyal will sing songs about.]],
}
