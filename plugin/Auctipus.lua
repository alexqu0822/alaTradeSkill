--[[--
	by ALA @ 163UI
--]]--

local __addon, __private = ...;

-->		upvalue
	local GetItemInfo = GetItemInfo;
-->


-->		****
__private:BuildEnv("Auctipus");
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


__private.F_AuctionModCallback("Auctipus", function()
	__private.F_AddAuctionMod("Auctipus", mod);
end);
