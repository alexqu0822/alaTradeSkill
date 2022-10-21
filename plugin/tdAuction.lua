--[[--
	by ALA @ 163UI
--]]--

local __addon, __private = ...;

-->		upvalue
	local GetItemInfo = GetItemInfo;
-->


local PLAYER_REALM_NAME = GetRealmName();


-->		****
__private:BuildEnv("Auctioneer");
-->		****


local mod = {  };

local prices = nil;
function mod.F_QueryPriceByName(name, num)
	return nil;
end
function mod.F_QueryPriceByID(id, num)
	if not id then return nil; end
	num = num or 1;
	if prices == nil then
		local TDDB_AUCTION = TDDB_AUCTION;
		if TDDB_AUCTION ~= nil
			and TDDB_AUCTION.global ~= nil
			and TDDB_AUCTION.global.prices ~= nil
			and TDDB_AUCTION.global.prices[PLAYER_REALM_NAME] ~= nil then
			prices = TDDB_AUCTION.global.prices[PLAYER_REALM_NAME];
		else
			return;
		end
	end
	local price = prices[id .. ":0"];
	if price ~= nil then
		return price * num;
	end
end


__private.F_AuctionModCallback("tdAuction", function()
	__private.F_AddAuctionMod("tdAuction", mod);
end);
