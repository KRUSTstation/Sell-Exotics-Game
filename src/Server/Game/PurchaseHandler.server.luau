local MarketplaceService = game:GetService("MarketplaceService")

local productFunctions = {}

productFunctions[1234567890] = function(receiptInfo, player) --ex for future reference
	
end

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local handler = productFunctions[receiptInfo.ProductId]
	if handler then
		local success = handler(receiptInfo, player)
		if success then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end