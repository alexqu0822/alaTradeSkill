--[[--
	by ALA @ 163UI
--]]--

local __addon_, __namespace__ = ...;

-->		upvalue
	local GetItemInfo = GetItemInfo;
-->


-->		****
__namespace__:BuildEnv("Auctipus");
-->		****


local mod = {  };

local GetAuctionBuyoutRange = nil;
function mod.F_QueryPriceByName(name, num)
	return nil;
end
function mod.F_QueryPriceByID(id, num)
	if id == nil then return nil; end
	num = num or 1;
	if GetAuctionBuyoutRange == nil then
		local Auctipus = Auctipus;
		if Auctipus ~= nil and Auctipus.API ~= nil and Auctipus.API.GetAuctionBuyoutRange ~= nil then
			GetAuctionBuyoutRange = Auctipus.API.GetAuctionBuyoutRange;
		else
			return;
		end
	end
	local minBuyout, maxBuyout, daysElapsed = GetAuctionBuyoutRange(id)
	if minBuyout ~= nil then
		return minBuyout * num;
	end
end


__namespace__:AddAddOnCallback("Auctipus", function()
	__namespace__:FireEvent("AUCTION_MOD_LOADED", mod);
end);
