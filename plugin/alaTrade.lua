--[[--
	by ALA @ 163UI
--]]--

local __addon_, __namespace__ = ...;


-->		****
__namespace__:BuildEnv("alaTrade");
-->		****


__namespace__:AddAddOnCallback("alaTrade", function()
	local merc = __ala_meta__.merc;
	if merc ~= nil then
		local mod = {  };
		mod.F_QueryPriceByName = merc.F_QueryPriceByName or merc.query_ah_price_by_name;
		mod.F_QueryPriceByID = merc.F_QueryPriceByID or merc.query_ah_price_by_id;
		mod.F_OnDBUpdate = merc.F_OnDBUpdate or merc.add_cache_callback;
		__namespace__:FireEvent("AUCTION_MOD_LOADED", mod);
	end
end);
