--!strict
-- Every rollable title, themed as Pusheen the Cat variants and moments. Id
-- must be unique and stable — it's the save-data key, so never rename or
-- reorder existing ids once players may have discovered them; only add new
-- ones. Titles flagged Exclusive are never rolled by RNG (granted directly,
-- e.g. by VIP). There are 100+ non-exclusive titles on purpose — with the
-- Index requiring every single one per rarity for its set bonus, full
-- completion is meant to take a very long time.
local Titles = {
	-- ============ Common — everyday Pusheen moments (25) ============
	{ Id = "c_napper", Name = "the Napping Pusheen", Rarity = "Common" },
	{ Id = "c_loaf", Name = "the Loaf", Rarity = "Common" },
	{ Id = "c_snacker", Name = "the Snacker", Rarity = "Common" },
	{ Id = "c_bellyrub", Name = "the Belly Rub", Rarity = "Common" },
	{ Id = "c_yarnchaser", Name = "the Yarn Chaser", Rarity = "Common" },
	{ Id = "c_boxsitter", Name = "the Box Sitter", Rarity = "Common" },
	{ Id = "c_windowwatcher", Name = "the Window Watcher", Rarity = "Common" },
	{ Id = "c_sunbeamnapper", Name = "the Sunbeam Napper", Rarity = "Common" },
	{ Id = "c_treatbeggar", Name = "the Treat Beggar", Rarity = "Common" },
	{ Id = "c_couchpotato", Name = "the Couch Potato", Rarity = "Common" },
	{ Id = "c_zoomierunner", Name = "the Zoomie Runner", Rarity = "Common" },
	{ Id = "c_purrmachine", Name = "the Purr Machine", Rarity = "Common" },
	{ Id = "c_tailchaser", Name = "the Tail Chaser", Rarity = "Common" },
	{ Id = "c_blanketburrower", Name = "the Blanket Burrower", Rarity = "Common" },
	{ Id = "c_kibblemuncher", Name = "the Kibble Muncher", Rarity = "Common" },
	{ Id = "c_lazysunday", Name = "the Lazy Sunday", Rarity = "Common" },
	{ Id = "c_stretchyone", Name = "the Stretchy One", Rarity = "Common" },
	{ Id = "c_curiouspaw", Name = "the Curious Paw", Rarity = "Common" },
	{ Id = "c_whiskerwiggler", Name = "the Whisker Wiggler", Rarity = "Common" },
	{ Id = "c_cardboardconnoisseur", Name = "the Cardboard Connoisseur", Rarity = "Common" },
	{ Id = "c_napchampion", Name = "the Nap Champion", Rarity = "Common" },
	{ Id = "c_snugglebug", Name = "the Snuggle Bug", Rarity = "Common" },
	{ Id = "c_milkwhisker", Name = "the Milk Whisker", Rarity = "Common" },
	{ Id = "c_sockthief", Name = "the Sock Thief", Rarity = "Common" },
	{ Id = "c_mirrorstarer", Name = "the Mirror Starer", Rarity = "Common" },

	-- ============ Uncommon — snack & hobby costumes (25) ============
	{ Id = "u_pizzacat", Name = "the Pizza Cat", Rarity = "Uncommon" },
	{ Id = "u_tacotuesday", Name = "the Taco Tuesday", Rarity = "Uncommon" },
	{ Id = "u_sushiroll", Name = "the Sushi Roll", Rarity = "Uncommon" },
	{ Id = "u_donutdream", Name = "the Donut Dream", Rarity = "Uncommon" },
	{ Id = "u_icecreamscoop", Name = "the Ice Cream Scoop", Rarity = "Uncommon" },
	{ Id = "u_cupcakecutie", Name = "the Cupcake Cutie", Rarity = "Uncommon" },
	{ Id = "u_popcornpouncer", Name = "the Popcorn Pouncer", Rarity = "Uncommon" },
	{ Id = "u_burgerbuddy", Name = "the Burger Buddy", Rarity = "Uncommon" },
	{ Id = "u_rainbowbagel", Name = "the Rainbow Bagel", Rarity = "Uncommon" },
	{ Id = "u_avocato", Name = "the Avocato", Rarity = "Uncommon" },
	{ Id = "u_coffeecat", Name = "the Coffee Cat", Rarity = "Uncommon" },
	{ Id = "u_bobatea", Name = "the Boba Tea", Rarity = "Uncommon" },
	{ Id = "u_cookiecrumbler", Name = "the Cookie Crumbler", Rarity = "Uncommon" },
	{ Id = "u_wafflewalker", Name = "the Waffle Walker", Rarity = "Uncommon" },
	{ Id = "u_candycorn", Name = "the Candy Corn", Rarity = "Uncommon" },
	{ Id = "u_marshmallowpuff", Name = "the Marshmallow Puff", Rarity = "Uncommon" },
	{ Id = "u_pretzeltwist", Name = "the Pretzel Twist", Rarity = "Uncommon" },
	{ Id = "u_nachoaverage", Name = "the Nacho Average Cat", Rarity = "Uncommon" },
	{ Id = "u_cheesewheel", Name = "the Cheese Wheel", Rarity = "Uncommon" },
	{ Id = "u_honeypot", Name = "the Honey Pot", Rarity = "Uncommon" },
	{ Id = "u_bubblegumblower", Name = "the Bubblegum Blower", Rarity = "Uncommon" },
	{ Id = "u_frycook", Name = "the Fry Cook", Rarity = "Uncommon" },
	{ Id = "u_ramenslurper", Name = "the Ramen Slurper", Rarity = "Uncommon" },
	{ Id = "u_gummybear", Name = "the Gummy Bear", Rarity = "Uncommon" },
	{ Id = "u_pancakestack", Name = "the Pancake Stack", Rarity = "Uncommon" },

	-- ============ Rare — seasonal & holiday dress-up (20) ============
	{ Id = "r_pumpkinspice", Name = "the Pumpkin Spice", Rarity = "Rare" },
	{ Id = "r_ghostofhalloween", Name = "the Ghost of Halloween", Rarity = "Rare" },
	{ Id = "r_witchsfamiliar", Name = "the Witch's Familiar", Rarity = "Rare" },
	{ Id = "r_santashelper", Name = "the Santa's Helper", Rarity = "Rare" },
	{ Id = "r_snowflakedancer", Name = "the Snowflake Dancer", Rarity = "Rare" },
	{ Id = "r_easterbasket", Name = "the Easter Basket", Rarity = "Rare" },
	{ Id = "r_fireworkwatcher", Name = "the Firework Watcher", Rarity = "Rare" },
	{ Id = "r_turkeydaynapper", Name = "the Turkey Day Napper", Rarity = "Rare" },
	{ Id = "r_valentineheart", Name = "the Valentine Heart", Rarity = "Rare" },
	{ Id = "r_leprechaunsluck", Name = "the Leprechaun's Luck", Rarity = "Rare" },
	{ Id = "r_beachday", Name = "the Beach Day", Rarity = "Rare" },
	{ Id = "r_campfirecuddler", Name = "the Campfire Cuddler", Rarity = "Rare" },
	{ Id = "r_snowangel", Name = "the Snow Angel", Rarity = "Rare" },
	{ Id = "r_fallleafpile", Name = "the Fall Leaf Pile", Rarity = "Rare" },
	{ Id = "r_birthdaycake", Name = "the Birthday Cake", Rarity = "Rare" },
	{ Id = "r_costumeparty", Name = "the Costume Party", Rarity = "Rare" },
	{ Id = "r_newyearscountdown", Name = "the New Year's Countdown", Rarity = "Rare" },
	{ Id = "r_gingerbreadcat", Name = "the Gingerbread Cat", Rarity = "Rare" },
	{ Id = "r_mistletoemuncher", Name = "the Mistletoe Muncher", Rarity = "Rare" },
	{ Id = "r_trickortreater", Name = "the Trick-or-Treater", Rarity = "Rare" },

	-- ============ Epic — fantasy & mythical costumes (15) ============
	{ Id = "e_mermaidtail", Name = "the Mermaid Tail", Rarity = "Epic" },
	{ Id = "e_dragonscale", Name = "the Dragon Scale", Rarity = "Epic" },
	{ Id = "e_fairywings", Name = "the Fairy Wings", Rarity = "Epic" },
	{ Id = "e_wizardsfamiliar", Name = "the Wizard's Familiar", Rarity = "Epic" },
	{ Id = "e_knightscompanion", Name = "the Knight's Companion", Rarity = "Epic" },
	{ Id = "e_phoenixfeather", Name = "the Phoenix Feather", Rarity = "Epic" },
	{ Id = "e_krakensfriend", Name = "the Kraken's Friend", Rarity = "Epic" },
	{ Id = "e_griffinrider", Name = "the Griffin Rider", Rarity = "Epic" },
	{ Id = "e_enchantedforest", Name = "the Enchanted Forest", Rarity = "Epic" },
	{ Id = "e_crystalballgazer", Name = "the Crystal Ball Gazer", Rarity = "Epic" },
	{ Id = "e_potionbrewer", Name = "the Potion Brewer", Rarity = "Epic" },
	{ Id = "e_spellbookkeeper", Name = "the Spellbook Keeper", Rarity = "Epic" },
	{ Id = "e_moonlitprowler", Name = "the Moonlit Prowler", Rarity = "Epic" },
	{ Id = "e_starcatcher", Name = "the Star Catcher", Rarity = "Epic" },
	{ Id = "e_galaxydreamer", Name = "the Galaxy Dreamer", Rarity = "Epic" },

	-- ============ Legendary — famous Pusheen-verse & space (10) ============
	{ Id = "l_pusheenicorn", Name = "the Pusheenicorn", Rarity = "Legendary" },
	{ Id = "l_astronaut", Name = "the Astronaut", Rarity = "Legendary" },
	{ Id = "l_stormy", Name = "Stormy", Rarity = "Legendary" },
	{ Id = "l_pip", Name = "Pip", Rarity = "Legendary" },
	{ Id = "l_rocketrider", Name = "the Rocket Rider", Rarity = "Legendary" },
	{ Id = "l_alienencounter", Name = "the Alien Encounter", Rarity = "Legendary" },
	{ Id = "l_spaceexplorer", Name = "the Space Explorer", Rarity = "Legendary" },
	{ Id = "l_meteorshower", Name = "the Meteor Shower", Rarity = "Legendary" },
	{ Id = "l_zerogravityfloater", Name = "the Zero Gravity Floater", Rarity = "Legendary" },
	{ Id = "l_constellationcat", Name = "the Constellation Cat", Rarity = "Legendary" },

	-- ============ Mythic — ultra-rare box exclusives (6) ============
	{ Id = "m_goldenbox", Name = "the Golden Box Exclusive", Rarity = "Mythic" },
	{ Id = "m_limitededition", Name = "the Limited Edition", Rarity = "Mythic" },
	{ Id = "m_collectorspride", Name = "the Collector's Pride", Rarity = "Mythic" },
	{ Id = "m_diamondpusheen", Name = "the Diamond Pusheen", Rarity = "Mythic" },
	{ Id = "m_platinumpaw", Name = "the Platinum Paw", Rarity = "Mythic" },
	{ Id = "m_ultrararefind", Name = "the Ultra Rare Find", Rarity = "Mythic" },

	-- ============ Secret — hidden & mega rare (4) ============
	{ Id = "s_mysterycat", Name = "the ????? Mystery Cat", Rarity = "Secret" },
	{ Id = "s_glitchedpusheen", Name = "the Glitched Pusheen", Rarity = "Secret" },
	{ Id = "s_developerspet", Name = "the Developer's Pet", Rarity = "Secret" },
	{ Id = "s_oneinamillion", Name = "the One in a Million", Rarity = "Secret" },

	-- Exclusive — never rolled, granted directly by the VIP gamepass.
	{ Id = "vip_pusheen", Name = "the VIP Pusheen", Rarity = "Secret", Exclusive = true },
}

return Titles
