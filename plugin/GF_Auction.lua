--[[--
	provided by @GF_Auction
	alaTradeSkill - GF_Auction adapter
--]]--
----------------------------------------------------------------------------------------------------
local __addon, __private = ...;
local MT = __private.MT;
local CT = __private.CT;
local VT = __private.VT;
local DT = __private.DT;


-->		upvalue
	local tonumber = tonumber;
	local _G = _G;

-->


-->		****
MT.BuildEnv("GF_Auction");
-->		****


local mod = {  };

local function GetDatabase()
	local gf = _G.GFAuction or _G.GF_Auction;
	if not gf or not gf.GetModule then return nil; end
	local Database = gf:GetModule("Database");
	if not Database or not Database.GetPriceStats then return nil; end
	return Database;
end

function mod.F_QueryPriceByID(id, num)
	id = tonumber(id);
	if not id or id <= 0 then return nil; end
	num = tonumber(num) or 1;
	if num <= 0 then num = 1; end

	local Database = GetDatabase();
	if not Database then return nil; end

	local stats = Database:GetPriceStats(id);
	local unit = stats and tonumber(stats.minUnit) or nil;
	if unit and unit > 0 then
		return unit * num;
	end
	return nil;
end

function mod.F_QueryPriceByName(name, num)
	if not name then return nil; end
	local Database = GetDatabase();
	if not Database or not Database.FindItemIDByName then return nil; end
	local id = Database:FindItemIDByName(name);
	if not id then return nil; end
	return mod.F_QueryPriceByID(id, num);
end

function mod.F_OnDBUpdate(callback)
	local Database = GetDatabase();
	if Database and Database.RegisterUpdate then
		Database:RegisterUpdate(callback);
	end
end

MT.RegsiterAuctionModOnLoad("GF_Auction", function()
	MT.AddAuctionMod("GF_Auction", mod);
end);
