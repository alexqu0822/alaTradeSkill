--[[--
	by ALA @ 163UI
--]]--

local __addon_, __namespace__ = ...;

-->		upvalue
	local GetItemInfo = GetItemInfo;
-->


-->		****
__namespace__:BuildEnv("Auctionator");
-->		****


local mod = {  };

local GetPrice = nil;
function mod.F_QueryPriceByName(name, num)
	if name == nil then return nil; end
	num = num or 1;
	if GetPrice == nil then
		if Atr_GetAuctionPrice ~= nil then
			GetPrice = Atr_GetAuctionPrice;
		else
			return;
		end
	end
	local ap = GetPrice(name);
	if ap ~= nil then
		return ap * num;
	end
	return nil;
end
function mod.F_QueryPriceByID(id, num)
	if id == nil then return nil; end
	num = num or 1;
	if GetPrice == nil then
		if Atr_GetAuctionPrice ~= nil then
			GetPrice = Atr_GetAuctionPrice;
		else
			return;
		end
	end
	local name = GetItemInfo(id);
	if name ~= nil then
		local ap = GetPrice(name);
		if ap ~= nil and ap > 0 then
			return ap * num;
		end
	end
end


__namespace__:AddAddOnCallback("Auctionator", function()
	mod.F_OnDBUpdate = Atr_RegisterFor_DBupdated;
	__namespace__:FireEvent("AUCTION_MOD_LOADED", mod);
end);
