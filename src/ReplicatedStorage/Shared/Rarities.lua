--!strict
-- Ordered from most common to rarest. Index matters: Config.PityMinRarityIndex
-- points at "Epic" below, and pity/set-bonus logic compares against it.
local Rarities = {
	{ Name = "Common", Color = Color3.fromRGB(190, 190, 190), Weight = 580, Boost = 0.01 },
	{ Name = "Uncommon", Color = Color3.fromRGB(90, 200, 90), Weight = 260, Boost = 0.03 },
	{ Name = "Rare", Color = Color3.fromRGB(70, 140, 240), Weight = 110, Boost = 0.08 },
	{ Name = "Epic", Color = Color3.fromRGB(170, 90, 230), Weight = 40, Boost = 0.20 },
	{ Name = "Legendary", Color = Color3.fromRGB(240, 180, 40), Weight = 8.5, Boost = 0.50 },
	{ Name = "Mythic", Color = Color3.fromRGB(240, 60, 60), Weight = 1.4, Boost = 1.25 },
	{ Name = "Secret", Color = Color3.fromRGB(235, 235, 245), Weight = 0.1, Boost = 3.00 },
}

for index, rarity in Rarities do
	rarity.Index = index
end

return Rarities
