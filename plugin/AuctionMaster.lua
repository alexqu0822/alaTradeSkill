--[[--
	by ALA @ 163UI
--]]--

local __addon, __private = ...;

-->		upvalue
	local GetItemInfo = GetItemInfo;
-->


-->		****
__private:BuildEnv("AuctionMaster");
-->		****


local mod = {  };

local GetInfo = nil;
function mod.F_QueryPriceByName(name, num)
	return nil;
end
function mod.F_QueryPriceByID(id, num)
	if id == nil then return nil; end
	num = num or 1;
	if GetInfo == nil then
		if AucMasGetCurrentAuctionInfo ~= nil then
			GetInfo = AucMasGetCurrentAuctionInfo;
		else
			return;
		end
	end
	local _, link = GetItemInfo(id);
	if link ~= nil then
		local _, _, bid, ap = GetInfo(link)
		if ap ~= nil and ap > 0 then
			return ap * num;
		end
	end
end


__private.F_AuctionModCallback("AuctionMaster", function()
	__private.F_AddAuctionMod("AuctionMaster", mod);
end);
