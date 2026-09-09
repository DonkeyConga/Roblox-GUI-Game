--!strict
-- Ordered from most common to rarest. Index matters: Config.PityMinRarityIndex
-- points at "Epic" below, and pity/set-bonus logic compares against it.
-- Colors are tuned as a pastel palette to sit on the light "Pusheen" theme's
-- cream/white cards (see UIFactory.lua) while staying clearly distinguishable.
local Rarities = {
	{ Name = "Common", Color = Color3.fromRGB(150, 142, 150), Weight = 580, Boost = 0.01 },
	{ Name = "Uncommon", Color = Color3.fromRGB(96, 191, 137), Weight = 260, Boost = 0.03 },
	{ Name = "Rare", Color = Color3.fromRGB(94, 163, 224), Weight = 110, Boost = 0.08 },
	{ Name = "Epic", Color = Color3.fromRGB(173, 122, 224), Weight = 40, Boost = 0.20 },
	{ Name = "Legendary", Color = Color3.fromRGB(235, 163, 66), Weight = 8.5, Boost = 0.50 },
	{ Name = "Mythic", Color = Color3.fromRGB(232, 94, 138), Weight = 1.4, Boost = 1.25 },
	{ Name = "Secret", Color = Color3.fromRGB(216, 190, 235), Weight = 0.1, Boost = 3.00 },
}

for index, rarity in Rarities do
	rarity.Index = index
end

return Rarities
