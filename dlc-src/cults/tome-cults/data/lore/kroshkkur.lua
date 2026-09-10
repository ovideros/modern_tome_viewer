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

local CultsDLC = require "mod.class.CultsDLC"

newLore{
	id = "cults-kroshkkur-history-1",
	category = "Forbidden Cults",
	name = _t"the history of Kroshkkur (1)",
	lore = _t[[The story of Kroshkkur is not a peaceful one. Those of us who gathered here know that we have no place anywhere else. The surface would never accept us, for our forms are terrible for them to behold. Even in the depths of Eyal, we have had to fight for our place in the world. These endless tunnels and the creatures within them have sought to destroy us. They hunger for our very souls.

When Kroshkkur was first discovered, it was infested with horrors. We cut them down and attempted to restore the strange arcane machines we found here. Alas, we found it to be damaged and could only partially restore it. But, even that small amount of power it held was enough to give us safety. Many followed us after that, outcasts who were looking for a haven in a hostile underground. Intelligent beings who do not belong anywhere else, seekers of forbidden knowledge and those who have seen too much for mortal eyes to bear are just a few who have made their homes here.

Since then, we have studied. We have divined this world's secrets and delved into the dark places which surface dwellers dare not look, out of fear of what might be looking back. We have no such fear, for we are the things looking back. In these places, we have found out many truths and discovered magic which will change the course of Eyal's history.

We will bide our time down here in the dark and turn this place into a beacon of knowledge. If this world will not give us a place in it, then we shall simply take one for ourselves. We shall make ourselves known to the surface when the time is right, and show them that we aren't just scattered, mindless beings for them to sweep aside.]],
}

newLore{
	id = "cults-kroshkkur-history-2",
	category = "Forbidden Cults",
	name = _t"the history of Kroshkkur (2)",
	lore = _t[[We were few once. Just outcasts from some crevices and dark places that everyone else forgot about long ago. When we claimed this fortress, more began to come. Not horrors, not surface dwellers, but those of us caught in between the two. Some of us were born this way while others were altered by forces beyond our understanding. The only thing that is common among all of us is that we simply don't belong anywhere. With conscious minds, we can plainly understand the horrors of Eyal's depths. With twisted and corrupted bodies, no 'civilised' people would tolerate our presence among them. When we reside in Kroshkurr, however, we are craftsmen, scholars, hermits, poets and warriors.

To that end, we all gather here. Are we spiteful for how this world openly rejects us? It would be a lie if we said no. To that end, we shall plunge head first into the places no one else dares look. We shall use the dark secrets of this world to carve out our own place in it. We shall create wonders while the world above us rests in fitful dreams.]],
}

newLore{
	id = "cults-kroshkkur-history-3",
	category = "Forbidden Cults",
	name = _t"the history of Kroshkkur (3)",
	lore = _t[[Why do we struggle on? What is Kroshkkur's plan? It is simple. We will take the knowledge other races have rejected and use it to transform ourselves. No more shall we be the wretches who hide away from the light. We will become the new gods, the ones to bask in the sun's embrace, proudly standing atop of the civilisation we built. We will surely find our answer among these ancient ruins, and when we do, we shall be as far from the surface dwellers as they are from worms.

It is this dream which keeps Kroshkkur alive. Even as our bodies continue to warp and decay, we hold onto the hope that we will find a way to reshape ourselves into something better. We will not need anyone's permission to exist on that day.]],
}

newLore{
	id = "cults-gods-0",
	category = "Forbidden Cults",
	name = _t"Researcher Dremnot's Demystification of the Gods: Prelude",
	lore = _t[[Gods are beings which have been frequently mentioned throughout Eyal's history. They are a foreign concept to most readers, since most Eyalites of the current age have not encountered them. The word god gives you the impression of some almighty and obscenely powerful being, which these beings most certainly are. But, there has been little scholarly work dedicated to defining what exactly a god is. Multiple cultures across Eyal's history all have varying descriptions of the gods, despite the same names frequently appearing among them. 

As a scholar of Kroshkkur, I spent much time wandering the surface of Eyal and learning from the surface races regarding the gods, including many famous places of learning such as Anglowen. It was a hard sell, but I even managed to [i]convince[/i] an imp to retrieve certain documentation on Urk'Rok as well. This series of documents has been written to catalogue information regarding the gods and to develop as accurate a picture of them as myth and history will allow and this preface is to give a general impression of what exactly a god is supposed to be.

There have been many powerful beings who have walked across the surface of Eyal. Being a god isn't simply a question of power, however, despite the enormous strength of these beings. What separates gods from other beings is their ability to reverse entropy. For future reference, we shall refer to this power as antropy. This power also allows them to reshape reality to their own whims and desires. Some gods made their own races, others merely altered beings living on Eyal, playing with their evolution and changing them in unfathomable ways. While some might attribute this behaviour to some greater purpose, there is more than enough evidence to suggest that the gods are fallible and motivated by things just as petty as we mere mortals. In my scholarly opinion, we were simply created for their amusement.

While this might drive some to despair and make them believe that mortal will is pointless, it is noted in ancient myth that the gods were slaughtered by the Sher'tul and driven away from our world. Whether or not their absence can be considered a good thing, it cannot be said. There are some surviving stories of the gods' blatant cruelty and complete disregard for the races they made as they squabbled among each other, wracking great scars across the surface of this world. It is also noteworthy that the gods, despite their impressive power, were not always intelligent beings. Some were believed to be barely sapient, or even sentient. One theory about this is that the gods were primitive beings living on Eyal's surface and just so happened to be infused with antropic energies, artificially elevating them above other primitive lifeforms.

With these things established, we will discuss the gods of Eyal and what influence their actions had, and continue to have, on our world. While I discovered many gods in my studies, it is entirely possible that Eyal had even more gods than what are documented in my findings, but their existence cannot be substantiated by existing scholarly texts.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-gods-1",
	category = "Forbidden Cults",
	name = _t"Researcher Dremnot's Demystification of the Gods: Chapter 1 - Amakthel",
	lore = _t[[Even among the gods, there was one that towered above them all. Its name was Amakthel, mightiest of Eyal's gods. It was said that it was the creator of the Sher'Tul, that ancient and mysterious race whose true nature is still unknown to this day. More than any other god, Amakthel appears as a creation figure in ancient myths, more readily interfering with mortal beings than any other god. Nearly every race has some myth of Amakthel coming into contact with them, some describing it as a glowing, divine being while others declared it as a bringer of ill omens. Its touch seemed to curse as readily as it blessed according to these different sources, altering beings in ways that only made sense to Amakthel itself. As such, it is difficult to get a clear picture of Amakthel's true personality and disposition towards mortals.

How exactly Amakthel's downfall came is not certain. Some myths say that the Sher'Thul were commanded by their creator to kill the gods, while others suggest that the Sher'Tul openly rebelled against them. ]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-gods-2",
	category = "Forbidden Cults",
	name = _t"Researcher Dremnot's Demystification of the Gods: Chapter 2 - Ralkur",
	lore = _t[[Ralkur, the god of illusions and deceit, was perhaps the most petty god of Eyal. The myths of Ralkur are often tragedies, describing the downfall of its titular character after trusting a mysterious stranger. Due to the consistency of these stories, it can be concluded that Ralkur did not care for meddling with things on a large scale, but preferred a much smaller one. It delighted in understanding what drove mortal races and how it could bring a single person to ruin with nothing but words and clever lies. It always revealed itself at the end of the tale, its hapless victim realising that they had been fooled all along. In this sense, Ralkur was cruel in a way that was distinct from the other gods.

When the god slayer Branzir came for it, Ralkur came to know fear and fled. The chase between god and god slayer was the stuff of legend, and many myths tell of the great trials which Branzir overcame in his pursuit of Ralkur. In the last moments of the chase, Ralkur was spared and told to leave Eyal by Branzir. However, Ralkur later returned and struck a terrible blow against Branzir's homestead, slaying his family and his servants. The already driven Branzir became obsessed with Ralkur and chased it across the entirety of Eyal. Having nowhere else to run after stumbling into a dungeon, Ralkur chose to go down into Eyal's depths, creating layer upon layer of illusions, creatures and distractions to prevent the relentless Branzir from catching it. Since no one can enter this dungeon without leaving, it can only be guessed at how deep the dungeon has become. Some say it is even infinite and that the chase between hunter and hunted continues to this day.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-gods-5",
	category = "Forbidden Cults",
	name = _t"Researcher Dremnot's Demystification of the Gods: Chapter 5 - Gerlyk",
	lore = _t[[Gerlyk, according to some ancient myths, is the creator of humanity and interacted the most with them during those times. Its contact with humanity seems dubious, however, when other sources are consulted. It interacted with mortals on its own whims and did not seem to particularly favour any species according to these stories. It seemed to be a more curious god than others, as a handful of myths mention it making contact with mortals so it could learn more about how they lived. The myths surrounding Gerlyk are noticeably less numerous than those of other gods and there appears to be large time gaps between them, suggesting that Gerlyk simply did not interact with Eyalites for the most part. For this reason, it is seen to be a god who observed, but didn't interfere.

During the Godhunt, there are no records indicating that any of the God Slayers slew Gerlyk or even found it. This suggests that the god hid somewhere even the Sher'tul could not find it.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-gods-8",
	category = "Forbidden Cults",
	name = _t"Researcher Dremnot's Demystification of the Gods: Chapter 8 - Quekorja",
	lore = _t[[Quekorja was the god of time and possibilities. What stands out about Eyal's myths regarding Quekorja is how wildly inconsistent they are. In particular, tales after the Godhunt tend to have a far less favourable outlook of the god than pre-Godhunt myths. Speculation regarding this is due to Quekorja supposedly taking an interest in written history and appointing its own librarians to record its tales. Since there are no surviving records of this library existing, this theory is considered to be pure conjecture and has no concrete evidence to validate it. There have been some unusual records found too, supposedly written by the same authors on the same dates, but wildly varying in their tone and their description of the god itself. Given the god's ability to control time, it is thought these notes might be from alternate timelines, further obscuring the truth about the god itself.

Quekorja was also thought to be responsible for the creat...[i](You know you read this section, but you can't actually remember it. It is almost like something has deliberately erased it from your mind.)[/i]

According to the records of Anglowen, Quekorja was slain during the Godhunt and its body discovered by the mage Linaniil. Linaniil managed to absorb a small portion of the god's power through a dangerous ritual. This tiny shard of power she acquired made her an archmage without peer, a testament to the sheer might of the gods.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-gods-9",
	category = "Forbidden Cults",
	name = _t"Researcher Dremnot's Demystification of the Gods: Chapter 9 - Xadoch",
	lore = _t[[Xadoch held the title of Blight-Weaver. It loved the creatures which crawled close to the earth and toiled in Eyal's filth, but had no love for its sapient races. As such, it was attributed in many mythologies to the creation of numerous diseases and plagues. Some myths stated that there was necessity to Xadoch's presence, as its plagues prevented any one race dominating the world and kept a balance of sorts. On the other hand, many other myths attest that the god had a cruel curiosity. It spread blight across the world and created diseases just to see what sort of effect they would have on sapient life. If it weren't for the other gods on Eyal, it is believed that Xadoch would have scoured the entire world of sapient life.

Xadoch was one of the first gods to be felled in the God Hunt by the hunter Branzir. The Sher'tul had a particular dislike of the god, as it had tried to undermine them with plagues numerous times. Strains of Xadoch's diseases are thought to still be on Eyal to this day, waiting for some unfortunate victim to carry them back to civilisation, so Xadoch may commit one last act of spite against sapient life.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-gods-12",
	category = "Forbidden Cults",
	name = _t"Researcher Dremnot's Demystification of the Gods: Chapter 12 - Ugg'matho",
	lore = _t[[Ugg'matho was the god responsible for the creation of the trolls. While most Eyalites of the current age think of trolls as dumb brutes, they have frequently proven themselves to be far more clever than they're given credit for. The most commonly attributed dominions of Ugg'matho were the forests and mountains of Eyal. In ancient texts, the title bestowed upon it was 'The Gardener,' for it deeply loved the forests and green places of Eyal. It is thought that it created the trolls in its own image, as savage and powerful stewards of the wild places.

In some legends, there are tales of it reaching down from the sky and annihilating settlements, for it saw civilisation as a blemish on the green canvas of Eyal's surface. In others, it instead chose to alter nature itself to stave off civilisation, creating various plants and guardians to prevent sapient races from plundering its forests for resources. The recurring theme of many of its myths is that it was vehemently opposed to sapient beings living out of harmony with nature.

Ugg'matho was frequently in conflict with other gods in its myths. Many a story tells of how the gods and their chosen champions went on great troll hunts in the wilderness, chasing down Ugg'matho's children in order to wipe them from the face of Eyal. While the tales often described their great success in ridding the wilderness of the troll menace, the sheer number of them throughout the ages suggests that they were not as successful as they made out. One myth stated that Ugg'matho eventually struck a deal with the other gods where they would leave its forests alone and it would leave their creations alone in return. Another states that Ugg'matho was made to submit by the other gods and begrudgingly continued to undermine them in secret.

When Ugg'matho was slained by Branzir, it is said that its blood took on a life of its own, spreading out into the wilderness in the form of living ooze.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-gods-13",
	category = "Forbidden Cults",
	name = _t"Researcher Dremnot's Demystification of the Gods: Chapter 13 - Urh'Rok",
	lore = _t[[Urh'Rok is supposedly a god from the world Mal'Rok, who created the race we know as demons. All of the myths regarding Urh'Rok depict him as being a benevolent and thoughtful god, one which had a deep and intimate relationship with his creations. The demons affectionately refer to him as their Father and they have nothing but praise to sing of him. Since there are not many different sources to cross reference, it may not be possible to get an unbiased examination of Urh'Rok's personality.

Their homeworld is described as a collection of fragmented continents held together only by Urh'Rok's will. According to the demons, this was the result of a great cataclysm which came through a Sher'Thul far portal. Their records state this cataclysm occurred roughly at the same time as the Spellblaze did on Eyal. This suggests that the Spellblaze had far reaching consequences beyond our current understanding and could have impacted multiple worlds.

Despite the benevolent and gentle demeanour he has been attributed in his myths, demons have frequently declared their atrocities committed against Eyalites in his name. This contrast in his attitude toward Eyalites and his own creations does not suggest a benevolent disposition, but rather one similar to a father protecting his spoiled children. His existence proves that gods are not a phenomena which are isolated to simply Eyal, but may exist on countless other worlds too.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-godslayers-0",
	category = "Forbidden Cults",
	name = _t"Mightier than Gods: Preface",
	lore = _t[[As part of scholarly pursuits into the nature of Eyal's gods, the role of the Sher'tul in their demise must not be forgotten. It was nine Sher'tul who slayed the gods, figures now known as the Godslayers. Beyond that, little about these individuals can be said with any certainty. The Sher'Tul are believed to have mastered many forms of technology, magical spells and psionic techniques. There is not a single force on Eyal then or now which could hope to match their might. Using these techniques in ways that we could not even guess at, they forged the weapons which would kill Eyal's gods, nine in total for each of the nine Godslayers who would wield them.

This series will analyse what little information about the Godslayers that is still available. Given the obscure nature of the Sher'tul race, there are no solid records regarding their most prominent figures.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-godslayers-1",
	category = "Forbidden Cults",
	name = _t"Mightier than Gods: Caldizar",
	lore = _t[[All Godslayer myths come back to one figure. Caldizar was the one who gathered the Godslayers and led the Sher'tul against the gods of Eyal. His standing in Sher'tul society is not completely clear, but given the resources he commanded and his influence over the Sher'tul, it's thought that he was one of their leaders, or at least a prominent figure in Sher'tul society.

The Godhunt started because Amakthel commanded the Sher'tul to slay the other gods. Caldizar personally went out and audited potential candidates to wield the Godslayer weapons. He too chose to wield a Godslayer, becoming the leader of the nine who would take part in the Godhunt. However, as the Godslayers did their work, they began to think about how Amakthel was using them as tools to meet its own ends. Their creator, while it wielded great power, had the intellectual capacity of an infant compared to the Sher'tul.

In the end, it was Caldizar who commanded the Sher'tul to slay Amakthel. It was thought that this command was not carried out by all Sher'tul and was, in fact, openly reviled by many of them, leading to conflicts within their ranks. There are no records of the Sher'tul after the Godhunt ended, let alone of Caldizar. No one is certain what became of their race. It is also noted that there is a strange absence of Sher'tul ruins on Eyal, almost as if they have been removed.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-godslayers-2",
	category = "Forbidden Cults",
	name = _t"Mightier than Gods: Branzir",
	lore = _t[[Branzir, for reasons unknown to us, appears to have plenty of surviving documents regarding his life. The recurring story was that he was nobility of some sort, a huntsman renown for his ability to track and slay beasts, which he did purely for sport. The Sher'tul had no worry or need of any resource, so many of them dedicated most of their time to leisurely pursuits, Branzir being no exception. He was given a mighty blade and hunted the gods relentlessly. According to surviving records, he successfully slayed at least two gods by himself and is apparently still pursuing the god Ralkur to this day.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-godslayers-3",
	category = "Forbidden Cults",
	name = _t"Mightier than Gods: Oslrey",
	lore = _t[[Oslrey the Wanderer was considered to be mythical even among the Sher'tul themselves. He spent most of his days wandering across the surface of Eyal, quietly observing the younger races as they emerged from barbarism. While most Sher'tul chose to stay away from what they saw to be the 'lesser' species, Oslrey took his time to walk among them and even speak with them. He carried a plain iron staff with him wherever he walked, an antiquated weapon which he cherished deeply.

He too was asked to become a Godslayer, for his prowess with his staff was the stuff of legends. He refused politely, but again and again, the requests for his assistance kept coming. After watching the land he wandered burn around him, he finally chose to take a stand against the Gods of Eyal. He was presented with Ythral, a uniquely made staff with a crescent blade on one end.

When he fought against the Gods, he acted completely without passion. His staff hammered them down, sliced them open and slaughtered them. He killed without mercy and without malice. When the last of the gods were dead, he returned to his wanderings, carrying Ythral and his old iron staff with him.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-godslayers-4",
	category = "Forbidden Cults",
	name = _t"Mightier than Gods: Murtas",
	lore = _t[[Murtas the Unfathomable came from a famous line of Sher'tul warriors, dating back to the days of the race when they had barely risen out of barbarism. As such, she was a prominent military leader, having decades of experience and prestige behind her. Her expertise in battle tactics proved to be invaluable numerous times to the Sher'tul. She was often described as a calculating and inscrutable individual, someone who did not share her thoughts openly.

When the Godhunt was under way, she was the one who supplied the finest smiths she could in order to produce the weapons necessary to deliver a killing blow to a God. She too was provided with a Godslayer, the blade Hyturac. Without her smiths and her expertise in the forging of arms, the weapons could not have possibly been made.

From there, she outwitted the Gods numerous times, springing ambushes and herding them to the exact locations she wanted them. The Gods, for all of their power, lacked the cunning to match Murtas' tactics, leading to them being cornered and slaughtered like helpless animals.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-godslayers-5",
	category = "Forbidden Cults",
	name = _t"Mightier than Gods: Harqel",
	lore = _t[[Harqel, according to myths, lead a life of hardship and misery. He was quiet, steadfast and forgiving in these stories, an entirely placid demeanor that seemed unfitting for a would-be Godslayer. This lead to him being mistreated numerous times by his peers, whom he always forgave no matter what they did to him. Regardless of what blows rained on him or what terrible wounds he suffered, he always survived. When the Godhunt occurred, he was approached and offered a chance to stand with the Godslayers. He thought at first that the gods could be reasoned with, but he saw the devastation wrought by their meaningless in-fighting. Without a second thought, he pledged himself to the cause.

Upon agreeing, the great shield Anvgrea was forged for him. He stood before the gods and challenged their power, unfazed and unyielding. Scorching flames, freezing cold, rotting blight and burning acid did not faze him or stop his advance. He bore everyone's pain so that they might rid the world of these titanic, uncaring deities. Nothing ever went past him or his mighty shield.

When the Godhunt ended, Harqel returned to a quiet life. The surviving Sher'tul treated the Godslayers as heroes and each were rewarded generously, but Harqel simply requested for a hidden abode somewhere in the stars, somewhere where he would not be disturbed by anyone.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-godslayers-6",
	category = "Forbidden Cults",
	name = _t"Mightier than Gods: Frosat",
	lore = _t[[The Sher'Tul were a people who possessed many exceptional individuals. The tale of Frosat is a mundane one compared to the other Godslayers. He was a scholar who spent most of his time reading, researching and teaching. The Library of Frosat was a fabled place of learning where he kept his large archives of knowledge he had accumulated over his life. Perhaps what was most notable about his career was his research into the nature of antropic power, the energy which only the Gods of Eyal possessed.

He was a consultant on the creation of the Godslayer weapons. His understanding of antropic power was unparalleled among his peers, so his advice proved invaluable to the mighty weaponsmiths who forged these instruments. There were going to be eight Godslayers at first, but he asked for one more weapon to be made. He wished to test the fruit of his research himself, so the staff Frosatur was made and named in his honour.

His fate after the Godhunt is unknown. Some sources speculate that he still remains in his library today, waiting for a student worthy of learning the full contents of his archives.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-godslayers-7",
	category = "Forbidden Cults",
	name = _t"Mightier than Gods: Azorol",
	lore = _t[[Azorol was the great marksman. She was an instructor in the use of weapons and seemed to favour an antiquated approach to their use. Many Sher'tul believed her to be foolish, for they could not see why she would use primitive projectile weapons when far more devastating weaponry had already been developed. She did not give up her ways, however harsh her critics were, for she believed there was value in preserving the old ways of war. Many tales tell of her unerring accuracy. No matter how small the target and how far the distance, her mighty spear throws would always land. 

For her, the spear Thoral was made, a throwing weapon of unparalleled might. She seemed to care little for the reasons behind the Godhunt, for the spear alone was a great enough prize for her. With this new weapon, there were tales of Azorol striking targets in the darkness beyond our world while standing on the flat plains of Eyal. She proved to be one of the mightiest of the Godslayers, for there was nowhere on Eyal which was safe from Thoral and its user.

Judging by surviving records, she was one of the Godslayers who was killed during the climax of the Godhunt. The fate of the spear Thoral is unknown.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-godslayers-8",
	category = "Forbidden Cults",
	name = _t"Mightier than Gods: Uthkal",
	lore = _t[[The death penalty did exist in Sher'tul society, but it was only ever used as a last resort. To deliver such a sentence, special executioners were employed. Uthkal was such an executioner, an expert in the use of a special halberd. Given the unique anatomy of the Sher'tul, executioners required extensive knowledge of how the Sher'tul body worked in order to provide the fastest and least painful death possible. Uthkal was often described as cold, calculating, but had a strange sense of mercy to him. The strokes of his halberd always delivered a sudden and painless death to those he executed.

When the Godhunt came, Uthkal volunteered his services. He knew that the Gods had to be disposed of, but at the same time, he did not wish for them to suffer. For him, it was another execution. The halberd Thragusal was created for him, an executioner's weapon without any equal. It was designed in such a way that it would sever the very nerves of its victim, making cuts from its great blade painless.

It was thought that Uthkal lingered over the corpses of the gods for a long time after the Godhunt ended, ensuring that they were truly dead and not suffering a prolonged, painful journey into oblivion.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}

newLore{
	id = "cults-godslayers-9",
	category = "Forbidden Cults",
	name = _t"Mightier than Gods: Yhurash",
	lore = _t[[Since the Sher'tul had mastered many forms of technology and supernatural techniques, they faced issues with a growing number of their citizens indulging in extremely eccentric entertainment. Physical sport quickly regained popularity among them, the most notable of which was gladiatorial combat. Yhurash the Undefeated was someone who loved the arena.

Yhurash was a nobleman, someone who had seen every pleasure and form of entertainment that the Sher'tul's mighty civilisation had produced. He was often described as being absent minded and largely uninterested in the world around him, as well as lethargic to the extreme. When the arena made its return into Sher'tul society, he quickly became enthralled by it. It got to the point where he eventually gave up his old life and became a gladiator himself. From there, he fought his way up until he became the arena's greatest champion.

When he first heard of the plan to kill the gods, he volunteered eagerly to become one of the Godslayers. He was granted the blade Cirarey, which beared a distinct resemblance to the famous blade he wielded in the arena. After he aided in the slaying of the gods, he willingly gave up Cirarey and returned to the arena, where it is speculated that he was one day killed by another competitor. It was later shown that the competitor had cheated by coating their blade in poison, leading to Yhurash's posthumous title of Yhurash the Undefeated.]],
	on_learn = function(who) world:gainAchievement("CULTS_GODS") end,
}
