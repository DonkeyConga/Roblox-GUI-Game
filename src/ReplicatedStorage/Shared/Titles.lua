--!strict
-- Every rollable title. Id must be unique and stable — it's the save-data key.
-- Titles flagged Exclusive are never rolled by RNG (granted directly, e.g. by VIP).
local Titles = {
	-- Common (58%)
	{ Id = "c_wanderer", Name = "the Wanderer", Rarity = "Common" },
	{ Id = "c_apprentice", Name = "the Apprentice", Rarity = "Common" },
	{ Id = "c_novice", Name = "the Novice", Rarity = "Common" },
	{ Id = "c_recruit", Name = "the Recruit", Rarity = "Common" },
	{ Id = "c_villager", Name = "the Villager", Rarity = "Common" },
	{ Id = "c_scout", Name = "the Scout", Rarity = "Common" },

	-- Uncommon (26%)
	{ Id = "u_hunter", Name = "the Hunter", Rarity = "Uncommon" },
	{ Id = "u_ranger", Name = "the Ranger", Rarity = "Uncommon" },
	{ Id = "u_mercenary", Name = "the Mercenary", Rarity = "Uncommon" },
	{ Id = "u_duelist", Name = "the Duelist", Rarity = "Uncommon" },
	{ Id = "u_seeker", Name = "the Seeker", Rarity = "Uncommon" },
	{ Id = "u_nomad", Name = "the Nomad", Rarity = "Uncommon" },

	-- Rare (11%)
	{ Id = "r_knight", Name = "the Knight", Rarity = "Rare" },
	{ Id = "r_vanguard", Name = "the Vanguard", Rarity = "Rare" },
	{ Id = "r_warlord", Name = "the Warlord", Rarity = "Rare" },
	{ Id = "r_stormcaller", Name = "the Stormcaller", Rarity = "Rare" },
	{ Id = "r_shadowblade", Name = "the Shadowblade", Rarity = "Rare" },
	{ Id = "r_ironheart", Name = "the Ironheart", Rarity = "Rare" },

	-- Epic (4%)
	{ Id = "e_dragonslayer", Name = "the Dragonslayer", Rarity = "Epic" },
	{ Id = "e_worldbreaker", Name = "the Worldbreaker", Rarity = "Epic" },
	{ Id = "e_soulreaper", Name = "the Soulreaper", Rarity = "Epic" },
	{ Id = "e_voidwalker", Name = "the Voidwalker", Rarity = "Epic" },
	{ Id = "e_starforged", Name = "the Starforged", Rarity = "Epic" },

	-- Legendary (~0.85%)
	{ Id = "l_godslayer", Name = "the Godslayer", Rarity = "Legendary" },
	{ Id = "l_eternal", Name = "the Eternal", Rarity = "Legendary" },
	{ Id = "l_ascendant", Name = "the Ascendant", Rarity = "Legendary" },
	{ Id = "l_omniscient", Name = "the Omniscient", Rarity = "Legendary" },

	-- Mythic (~0.14%)
	{ Id = "m_beyondgod", Name = "Beyond God", Rarity = "Mythic" },
	{ Id = "m_realitybender", Name = "the Reality Bender", Rarity = "Mythic" },
	{ Id = "m_infinite", Name = "the Infinite", Rarity = "Mythic" },

	-- Secret (~0.01%)
	{ Id = "s_forsaken", Name = "the ????? Forsaken", Rarity = "Secret" },
	{ Id = "s_singularity", Name = "the Singularity", Rarity = "Secret" },

	-- Exclusive — never rolled, granted directly by the VIP gamepass.
	{ Id = "vip_ascended", Name = "the Ascended [VIP]", Rarity = "Secret", Exclusive = true },
}

return Titles
