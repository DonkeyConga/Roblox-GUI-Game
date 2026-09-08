--!strict
-- VIP gamepass: ownership check on join, purchase prompt + grant on completion.
-- Config.GamepassIds.VIP left at 0 safely disables all of this (no errors) until
-- a real asset id from the Creator Dashboard is filled in.
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local DataService = require(script.Parent.DataService)

local GamepassService = {}

local VIP_TITLE_ID = "vip_ascended"

local function grantVIP(player: Player): boolean
	local data = DataService.Get(player)
	if not data or data.OwnsVIP then
		return false
	end
	data.OwnsVIP = true
	data.DiscoveredTitles[VIP_TITLE_ID] = true
	DataService.MarkDirty(player)
	return true
end

function GamepassService.CheckOwnership(player: Player)
	if Config.GamepassIds.VIP <= 0 then
		return
	end
	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, Config.GamepassIds.VIP)
	end)
	if success and owns then
		grantVIP(player)
	end
end

function GamepassService.PromptVIP(player: Player): boolean
	if Config.GamepassIds.VIP <= 0 then
		return false
	end
	MarketplaceService:PromptGamePassPurchase(player, Config.GamepassIds.VIP)
	return true
end

function GamepassService.Init(onPurchase: ((Player) -> ())?)
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
		if wasPurchased and gamepassId == Config.GamepassIds.VIP then
			if grantVIP(player) and onPurchase then
				onPurchase(player)
			end
		end
	end)
end

return GamepassService
