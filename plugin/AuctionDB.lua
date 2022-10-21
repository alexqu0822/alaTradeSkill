--[[--
	by ALA @ 163UI
--]]--

local __addon, __private = ...;

-->		upvalue
	local GetItemInfo = GetItemInfo;
-->


-->		****
__private:BuildEnv("AuctionDB");
-->		****


local mod = {  };

local GetInfo = nil;
function mod.F_QueryPriceByName(name, num)
	return nil;
end
function mod.F_QueryPriceByID(id, num)
	if not id then return nil; end
	num = num or 1;
	if GetInfo == nil then
		local AuctionDB = AuctionDB;
		if AuctionDB ~= nil and AuctionDB.AHGetAuctionInfoByLink ~= nil then
			GetInfo = AuctionDB.AHGetAuctionInfoByLink;
		else
			return;
		end
	end
	local name, link = GetItemInfo(id);
	if link ~= nil then
		local info = GetInfo(link);
		if info ~= nil and info.minBuyout ~= nil then
			return info.minBuyout * num;
		end
	end
end


__private.F_AuctionModCallback("AuctionDB", function()
	__private.F_AddAuctionMod("AuctionDB", mod);
end);
