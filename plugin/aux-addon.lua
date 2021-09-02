--[[--
	by ALA @ 163UI
--]]--

local __addon_, __namespace__ = ...;


-->		****
__namespace__:BuildEnv("aux-addon");
-->		****


local mod = {  };

local history = nil;
function mod.F_QueryPriceByName(name, num)
	return nil;
end
function mod.F_QueryPriceByID(id, num)
	if id == nil then return nil; end
	num = num or 1;
	if history == nil then
		if require ~= nil then
			history = require 'aux.core.history';
			if history == nil then
				return;
			end
		else
			return;
		end
	end
	local ap = history.market_value(id .. ":0");
	if ap ~= nil and ap > 0 then
		return ap * num;
	end
end


__namespace__:AddAddOnCallback("aux-addon", function()
	__namespace__:FireEvent("AUCTION_MOD_LOADED", mod);
end);
