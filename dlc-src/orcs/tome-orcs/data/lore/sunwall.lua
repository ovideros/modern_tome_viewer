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

--------------------------------------------------------------------------
-- Sunwall Outpost
--------------------------------------------------------------------------

newLore{
	id = "sunwall-outpost-1",
	category = "sunwall",
	name = _t"a page from Commander Trelle's journal",
	lore = function()
		local male = false
		if world and world.majeyal_campaign_last_winner then male = not world.majeyal_campaign_last_winner.female end
		return ([[We've done it... we've finally done it. Well, granted, our %s did much of the work, but the result is the same: neither the East nor the West will ever need to fear Orcish rule again. The Prides have been crushed, the survivors have been contained, and our patrols are mopping up the few remaining bands of futile stragglers. Our long-lost allies from the West have come to support us with materials and manpower, and we can finally turn this entire continent into something beautiful. For the first time, Sunwall will not be the solitary bastion of civilization on Var'Eyal.

And yet...

There is one group that remains.  A tiny Orcish pride, really more of a small town, managed to evade our savior's wrath...  a single weed on the edges of our pristine garden, a troubling ember threatening to set the whole continent aflame.  King Tolak has noble aims in trying to set a better example than his vengeful father, but I doubt he'd risk redeeming the Orcs if he'd been through what we have.  The Allied Kingdoms don't know what it's like to live in fear of the Prides, knowing that at any moment they could overrun the Sunwall and take our heads as trophies.  They've got a farportal to hide behind, and don't have to think about their homes and families falling to the same horror that we've been struggling against for our entire lives.  If they did...  suffice to say, they wouldn't have bothered putting up a comfortable camp for the surviving Orcs until the continent was truly safe.

By the Sun...  why would our High Paladin agree to this treaty?  After what we've all been through...

The Orcish scouts are getting bolder.  They've been approaching closer before fleeing, and coming more frequently.  They haven't engaged us yet, but it's only a matter of time...  and all I'm allowed to do is sit and wait on this ugly little bridge, as the West watches from a continent away.  Staring at an open wound, waiting for it to become infected, because they'd rather make a pretty little bow out of the bandages.]]):tformat(male and _t"hero" or _t"heroine") end,
}

newLore{
	id = "sunwall-outpost-2",
	category = "sunwall",
	name = _t"a letter addressed to Outpost Leader John",
	lore = _t[[Sir,

The Orcs grow more impudent every day.  Surely you've noticed too - their scouts growing closer, the smoke of their forges drifting over the mountains alongside the clanging of metal being pounded into weaponry, the guttural shouts of their training drills...  Are you really going to obey this suicidal treaty, and keep us from acting until their swords are already through our throats?
If you were to... [i]see[/i] an approaching assault force, I would verify your report. Legally, we would be untouchable for defending ourselves.  Please, ensure that this inevitable conflict is at least one that gives us the tactical advantage of surprise, not them.

-Cmdr. Trelle]],
}

newLore{
	id = "sunwall-outpost-3",
	category = "sunwall",
	name = _t"a letter addressed to Commander Trelle",
	lore = _t[[Trelle,

I respect your intentions and your dedication to our safety, which is the only reason I'm not handing this letter over to Aeryn right this second.  Do you have the faintest clue what this treaty is buying us?  Do you really think we could have kept the Prides' remnants from banding together and becoming, at a minimum, a massive thorn in our side for the next few decades without King Tolak's help? Even if I disagreed with Aeryn that the Orcs deserve a chance of redemption, this treaty is ensuring an [i]extraordinary[/i] amount of help from a nation that, last year, still tolerated roving gangs of mage-lynchers.

I'll spare you the speech about insubordination, lying, and bypassing the chain of command, because a: technically you were "only" asking me to commit those crimes, and b: I've got better things to do than write up a full-blown reprimand for someone who I'm [i]certain[/i] knows exactly what they're doing wrong.  Instead, I'll cut to the chase: Never even think of pulling something like this again.  I'm saving your letter, and if you're ever involved in a questionable use of force, I'm submitting it as evidence.  I thought you were better than this.

-Outpost Leader John]],
}

newLore{
	id = "sunwall-outpost-4",
	category = "sunwall",
	name = _t"a large, embossed envelope",
	lore = _t[[#{bold}#TO WHOM IT MAY CONCERN:#{normal}#

Whereas, it can be assumed with 100% certainty that the individual reading this note is the most esteemed authority of the group residing on the bridge connecting Var'Eyal and the Clork Peninsula, as the construct trusted to deliver this message cannot be coerced to decode it;
and whereas, our observation balloons tell us that this organization is one of high culture and civilization, one comprised of several different species, and would be open to friendly negotiation;
and whereas, the Orcs have none of the aforementioned qualities, and their continued presence on the Clork Peninsula either directly causes or can lead to countless difficulties and unpleasant situations for both of our groups;
and whereas, cooperation in the immediate future would be beneficial to both of us, as would a longer period of peace between our two cultures;
it is therefore imperative that I, and the rest of our species, introduce ourselves.

I am Chief Councillor Tantalos, and I represent the people of #{bold}#Atmos#{normal}#; the orcs call us "Steam Giants" when not using a slew of impolite pejoratives, and we find the name amusing enough to accept it.  The Clork Peninsula is our land, as we have resided here in peace for many thousands of years, before becoming overrun with these distasteful ruffians.  We have been content to let them roam in the undesirable backwater territories of this peninsula, while we looked down from our rightfully elevated places, but various unfortunate circumstances have forced our hand.

We have invented technology #{bold}#far#{normal}# more impressive than yours, or that of any of the remaining miniature races.  Our plebeian citizens are accustomed to luxurious appliances which even your king lacks; our military has abominable weaponry which puts an untrained commoner on even footing with a skilled archer, and lets a moderately experienced marksman kill with range and precision that all but the most powerful archmages would be envious of.  Our people are strong, stronger than any of yours even on a per-pound basis, let alone the advantages of towering over you child-like creatures.  We have countless valuable natural resources, and our many, talented artisans will quickly become accustomed to making smaller garments, jewelry, and bottles of fine spirits for export (among many other high-quality goods).  It should be clear that your diminutive people have much to gain from us; all we wish, for the time being, is for the Clork Peninsula to remain #{bold}#our#{normal}# land, and perhaps that you may grant us some martial or material assistance in #{italic}#addressing#{normal}# the Orcish inconvenience.

We should meet, and discuss this in more detail, or I can arrange to let you borrow an artifact that will allow us to communicate.  Please give your reply to this construct post-haste.

Regards,
#{italic}#-Tantalos#{normal}#]],
}

newLore{
	id = "sunwall-outpost-5",
	category = "sunwall",
	name = _t"a page from Commander Trelle's journal",
	lore = _t[[Well.  Turns out this peninsula's also home to an entire civilization of giants lurking in the mountains.  If we weren't so short on troops, my scouts would all be fired.  I appear to have accidentally deceived this construct into mistaking me for Aeryn, John, and King Tolak all at once, and while I am obligated to pass this letter on to them...  on further discussion with this Chief Councilor Tantalos, we have both realized that we can wait to inform them, as this presents an opportunity that neither of us can afford to waste.

Now, officially, both we and the Allied Kingdoms have a policy of capturing the remaining Orcs and taking them to the internment camp rather than killing them (when possible), which would require a far more decisive advantage than this outpost has.  Officially, we are to stay right where we are, containing the potential threat of the Kruk Pride rather than moving into their territory before they can amass their forces.  Officially, it would be forbidden for us to do anything about this problem until it's too late.  But...

#{italic}#Officially,#{normal}# the Atmos don't exist, and we have no knowledge of them whatsoever.  Officially, if a couple of Allied Kingdoms supply ships headed for the internment camp #{italic}#just happened#{normal}# to be waylaid by a hired band of pirates who #{italic}#got lucky#{normal}# and struck them just between their naval patrol routes, it'd be #{italic}#such a shame,#{normal}# and the Atmos couldn't be blamed if that armor and weaponry found itself in their hands.  Officially, we are not to leave our post under any circumstances, and if a mysterious band of giants descended from the mountains, crushed the Kruk Pride in their homeland, and forced them to flee, it would be against our orders to do anything about it, aside from eliminate any refugees who flee to our bridge; officially, this wouldn't impede the Atmos' negotiations with the Allied Kingdoms and Sunwall after this incident, because they couldn't have known we'd pursue a goal as naive as waiting to take the Orcs alive, and would grant them an uncontested claim to Kruk territory.

Unofficially?  I'm going to #{italic}#enjoy#{normal}# this.]],
}

newLore{
	id = "sunwall-outpost-6",
	category = "sunwall",
	name = _t"a torn page from John's journal",
	lore = _t[[Aeryn, my love...  I fear Trelle may be right, but I will hold this bridge without resorting to betraying you.  Still, though, I will remain vigilant of approaching attacks, and prepare to strike first if a battle really does seem inevitable.  As long as I stand, no Orc will ever harm you again.  We will have a bright and shining future ahead of us, walking hand in hand into the dawn of a new, peaceful age...  and while I hope the Kruk Pride has a place there, I will not let them put this new age in jeopardy.]],
}

--------------------------------------------------------------------------
-- Sunwall Outpost
--------------------------------------------------------------------------

newLore{
	id = "orcs-gates-morning-1",
	category = "sunwall",
	name = _t"King Tolak's Condemnation",
	always_pop = true,
	lore = function() return ([[(As you approach the farportal, a herald emerges, holding an envelope; he doesn't quite hand it to you as much as throw it at you from a safe distance, then salutes and retreats back into the swirling rift.  The letter bears the royal seal of the Allied Kingdoms.)

%s...  I think I'm beginning to understand why you have acted this way.  At first, I was...  well, not as much surprised as disappointed.  I'd thought that showing your people mercy was the right decision.  That my father had been too consumed by rage, that the Orcs could be truly be better people if we gave them a chance, and if you were shown how much of a better place Eyal could be if you were to cooperate with us.  That no matter what my father, my mother, and my allies had told me, the Orcish race contained, somewhere deep down, the same potential for learning, growth, and beauty present in Humans, Halflings, Elves, Dwarves, and Ogres.

But now...  I see no good in you.  So many are dead, because I couldn't bring myself to admit that some people are beyond redemption.  Because I thought all you needed was a second chance, that you had goals other than blind, bloody revenge, that you'd see that we had held you in the grip of our absolute mercy, and opted to offer you an open hand rather than crush you as easily as clenching our fist.

I will not make the same mistake again.

You've shown me that the Orcish heart is empty of everything but lust for death and destruction, that no matter how good a future is laid out in front of you, you will discard it simply for the thrill of battle against the reasonable people who want this better future to come.  You've shown me that the prejudices I've strived to transcend were right all along.  You've shown me that my father's only mistake was not going far enough - a continent free of Orcs is not enough to keep us safe.  Instead, your kind must be purged from all of Eyal - and the battle to make this happen is inevitable, for you will continue pushing for it no matter how much we try to make peace an option.  And yet...  you've made me understand the reason of this approach, of treating everyone else like an irrational threat to your existence, for it is the only proper way for us to treat you.

You won't get another second chance from us.  Instead, we'll give you the only thing you've ever wanted: a battle.  Through this portal waits the army of the Allied Kingdoms, once foes or begrudging co-inhabitants who have grown into true allies because we have a desire for peace and cooperation that your kind will never know.  We wait on an open battlefield, ready to demonstrate our combined might.  The Shaloren of Elvala prepare spells as the Ogres grip their clubs tighter; the Halflings and Humans of Derth and Last Hope have forgotten their age-old rivalry, working together to brew alchemical bombs and build great golems, or take up positions with a bow or sling; the Dwarves of Iron Throne and the Thaloren of Shatur, not even proper allies with us before now, realize you are too great a threat to go neglected, and now our ranks are lined with Wilders summoning countless beasts and treants, and fierce warriors who will #{italic}#not#{normal}# be moved.  Even the forces of the Sunwall have joined us, a contingent of their finest warriors sent to reinforce our lines and quickly train our soldiers in the magical techniques they've honed over the years, using you irredeemable savages as their sharpening stones.

I shall be waiting in the front line of this glorious alliance, sword in hand.  I, King Tolak the Fair, son of Toknor who once purged your people from Maj'Eyal, I who once fought to spare your kind from slavery or extinction, now eagerly await the opportunity to finish what he started.  If I die, Toknor's bloodline dies with me; this is a risk I am willing - no, #{italic}#excited#{normal}# to take, to settle the fate of all civilized peoples of Eyal, once and for all.

You want your revenge on my father's people, foul cur?  #{italic}#Come and get it.#{normal}#

(You admit, it is rather tempting...  but the guaranteed safety of your people takes priority, and besides, you wouldn't put it past the Allied Kingdoms to have a team of archers and slingers waiting to snipe everyone who came through, one by one.  You destroy the portal, eliminating King Tolak's army as a threat, and ensuring Sun Paladin Aeryn won't be getting any reinforcements.  Time to take advantage of your newfound privacy, and finish off the Sunwall forces, once and for all...)]]):tformat(game.player.name) end,
	on_learn = function(player)
		if game.zone and game.zone.short_name == "orcs+gates-of-morning" and game.level and game.level.level == 1 then
			local todel = {}
			for _, ps in ipairs(game.level.map.particles) do
				if ps.def and ps.def:find("^farportal") then
					todel[#todel+1] = ps
				end
			end
			for _, ps in ipairs(todel) do
				game.level.map:removeParticleEmitter(ps)
			end
		end
	end,
}

newLore{
	id = "orcs-gates-morning-2",
	category = "sunwall",
	name = _t"Sun Paladin report",
	lore = _t[[Lady Aeryn,

My apologies, but you're going to have to go back to King Tolak empty-handed - we still don't have any idea how the smugglers are getting through.  The best evidence we've got is some rumbling in the desert near the Dominion Port (which is still too heavily guarded for a direct attack before the Allied Kingdoms can grant us full assistance), suggesting geomantic tunnel formation, but that could just as easily be the few of Briagh's spawn that the Hero of Maj'Eyal didn't mop up.  Scrying spells aren't helping either - there's some sort of counter-scrying ward being applied, but it's so well-hidden that we can't tell where on the continent it's coming from or how many entities are being affected by it.  The only thing that seems certain is that they've got another farportal hacked together - the only one we know of is right in the middle of Gates of Morning, and I'd like to think that we're not so incompetent we wouldn't notice a steady stream of slavers and bootleggers strolling past 70% of us.  If they're actually using that one, then they're using the best invisibility spell we have ever seen.

...Haven't ever seen?  Whatever.

Anyway, my advice is to request permission to send a few Shining Inquisitors to King Tolak to assist in the investigations on his end.  However they're evading detection here in the East, they either can't use it in the West or simply let their guard down once they're back home, judging from the rising arrest rates - we can help the Allied Kingdoms hit the weak link of this chain, and have the Inquisitors keep an eye on things in Maj'Eyal while they're at it.  Not that I don't trust that King Tolak intends to honor his commitment to keep those foul Ziguranth from ever pulling off anything like the Sunset Massacre again, but...  well, if a farportal altar made it onto the black market under the Allied Kingdoms' watch, possibly courtesy of a mad alchemist who lived practically next door to the King, I don't have too much faith in their ability to drag a bunch of clandestine fanatics into the light, out from the cover of that supposedly-benign Menders group.  I'm sure they're trying their hardest; all I'm suggesting is that we do the same.]],
}

newLore{
	id = "orcs-gates-morning-3",
	category = "sunwall",
	name = _t"journal of High Sun Paladin Aeryn",
	lore = _t[[This is it...  the day I've dreaded for most of my life is here, and yet it still comes as a shock.  I expected it for almost every day of my life...  until last year.  The Scourge from the West defeated the Prides, raced down the Charred Scar, and stormed the tower of High Peak to fight by my side against a threat far greater than I dreamed possible.  We'd been reunited with a cooperative and nearly-unified Maj'Eyal, led by a king willing and able to help us in any way, armed with a plan to keep the orcs completely under control...  it's as if the Sun had begun to creep over the horizon to start the dawn of peace in Var'Eyal, right before going dark forever and taking the moons with it.  The love of my life is presumed dead; the candle in the night of the years before has been snuffed out. Nothing - no plan that hasn't been shattered, no inspiration that hasn't fallen, no hope that hasn't turned to despair - is left to guide me.

I must be that light for my allies' sake.  I must be strong, resolute, giving them whatever tiny amounts of hope I can.  Not only to keep their morale up and give us a chance of prevailing against the unstoppable menace which the Sunwall has stood against for ages...  but so that their last thoughts in death might be that their sacrifice has saved us all.  Maybe one of them will be right.

All I can hope is that King Tolak has learned something about the Orcs, before his kingdom falls as well.  I do not begrudge him, everything he did was rooted in wisdom and kindness...  and would have worked for any species but the Orcs.  They are the sole exception that deserves no mercy.]],
}

newLore{
	id = "caves-hatred-1",
	category = "sunwall",
	name = _t"kindness",
	lore = _t[[I stuck up for you. I wanted to forgive you, to give you time and safety to see we meant no harm.  I forgave you for the ages we spent in fear, the lives we lost, for I imagined I could have been tempted to do the same in your position.

Now I see where kindness and mercy get me.]],
}

newLore{
	id = "caves-hatred-2",
	category = "sunwall",
	name = _t"hope",
	lore = _t[[You took everything from me.  You took the dawn of a beautiful future, you took the fires of hope and happiness, you took the kind, guiding light of my love Aeryn and put out the glow of the life we deserved to have together.  The light is gone...  but you have given me darkness in return.  And you're about to know that darkness very, very well.  Embracing it fully rather than shutting it out...  It's so easy to use these powers now.  I've felt them before, but I had no hate to use as their inspiration, no true misery to pour into the minds deserving, no empty void inside me to drain your hopes and confidence into.  You've fixed that for me.

My heart still beats, but you have taken my life nonetheless.  You'll understand shortly.]],
}

newLore{
	id = "caves-hatred-3",
	category = "sunwall",
	name = _t"suffering",
	lore = _t[[Fall.  Suffer.  Lose the hope that drives you, or whatever brutish instinct suffices for it in your abominable mind.  Feel the pain you caused me, and know that it will never, ever stop...  you can feel it eroding your will to keep going, can't you?

When your shattered mind succumbs to the pain you gave me, I will take it for my own.  I'll give you back just a little of the hope and love I took, so when you're a mere passenger in your own body, I can watch that light grow dark, as you watch your own body finding everyone you love and killing them slowly and painfully.  Their last words will be cursing your name, and you will be both powerless to stop it, and all too aware that it's your own fault for not preventing it sooner.

Then, and only then, will you fully understand what you did to me.]],
}
