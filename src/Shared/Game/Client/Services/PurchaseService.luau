local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local PurchaseService = {}

function PurchaseService.PromptProductPurchase(productId)
	MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productId)
end

return PurchaseService
