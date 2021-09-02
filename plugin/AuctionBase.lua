--[[--
	by ALA @ 163UI
--]]--

local __addon_, __namespace__ = ...;
local __db__ = __namespace__.__db__;
local L = __namespace__.L;

-->		upvalue
	local next = next;
	local floor = math.floor;
	local format = string.format;
	local RequestLoadItemDataByID = RequestLoadItemDataByID or C_Item.RequestLoadItemDataByID;
	local GetItemInfo = GetItemInfo;
-->


local AuctionMod = nil;


local F = CreateFrame('FRAME');


-->		****
__namespace__:BuildEnv("AuctionBase");
-->		****

local AuctionBase = {  };

local T_MaterialVendorPrice = __db__.T_MaterialVendorPrice;
local T_MaterialVendorPriceByName = {  };
local function LF_CacheItem(id)
	local name = GetItemInfo(id);
	if name ~= nil then
		T_MaterialVendorPriceByName[name] = T_MaterialVendorPrice[id];
		return true;
	else
		return false;
	end
end
local N_MaterialVendorPrice = 0;
for id, price in next, T_MaterialVendorPrice do
	N_MaterialVendorPrice = N_MaterialVendorPrice + 1;
end
F:RegisterEvent("ITEM_DATA_LOAD_RESULT");
F:SetScript("OnEvent", function(self, event, arg1, arg2)
	if T_MaterialVendorPrice[arg1] ~= nil then
		if arg2 and LF_CacheItem(arg1) then
			N_MaterialVendorPrice = N_MaterialVendorPrice - 1;
		else
			RequestLoadItemDataByID(arg1);
		end
		if N_MaterialVendorPrice <= 0 then
			self:SetScript("OnEvent", nil);
			self:UnregisterAllEvents();
			F = nil;
		end
	end
end);
for id, price in next, T_MaterialVendorPrice do
	RequestLoadItemDataByID(id);
end
--
function AuctionBase.F_QueryVendorPriceByLink(link, num)
	local id = tonumber(select(3, strfind(link, "item:(%d+)")));
	return id ~= nil and AuctionBase.F_QueryVendorPriceByID(id, num);
end
function AuctionBase.F_QueryVendorPriceByID(id, num)
	local p = T_MaterialVendorPrice[id];
	if p ~= nil then
		if num ~= nil then
			return p * num;
		else
			return p;
		end
	else
		return nil;
	end
end
function AuctionBase.F_QueryVendorPriceByName(name, num)
	local p = T_MaterialVendorPriceByName[name];
	if p ~= nil then
		if num ~= nil then
			return p * num;
		else
			return p;
		end
	else
		return nil;
	end
end

function AuctionBase.F_QueryNameByID(id)
	return nil;
end
function AuctionBase.F_QueryQualityByID(id)
	return nil;
end
local C_GoldIcon    = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:0:0|t";
local C_SilverIcon  = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:0:0|t";
local C_CopperIcon  = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:0:0|t";
function AuctionBase.F_GetMoneyString(copper)
	-- GetCoinTextureString
	local G = floor(copper / 10000);
	copper = copper % 10000;
	local S = floor(copper / 100);
	copper = copper % 100;
	local C = floor(copper);
	if G > 0 then
		return format("%d%s %02d%s %02d%s", G, C_GoldIcon, S, C_SilverIcon, C, C_CopperIcon);
	elseif S > 0 then
		return format("%d%s %02d%s", S, C_SilverIcon, C, C_CopperIcon);
	else
		return format("%d%s", C, C_CopperIcon);
	end
end

local T_AliasList = {
	F_QueryVendorPriceByLink = "get_material_vendor_price_by_link",
	F_QueryVendorPriceByID = "get_material_vendor_price_by_id",
	F_QueryVendorPriceByName = "get_material_vendor_price_by_name",
	F_QueryNameByID = "query_name_by_id",
	F_QueryQualityByID = "query_quality_by_id",
	F_GetMoneyString = "MoneyString",
	--
	F_QueryPriceByName = "query_ah_price_by_name",
	F_QueryPriceByID = "query_ah_price_by_id",
	F_OnDBUpdate = "add_cache_callback",
};
__namespace__:AddCallback(
	"AUCTION_MOD_LOADED",
	function(mod)
		if mod ~= nil then
			AuctionMod = mod;
			for key, val in next, AuctionBase do
				local alias = T_AliasList[key];
				mod[key] = mod[key] or mod[alias] or val;
			end
		end
	end,
	'prepend'
);

function __namespace__.F_GetAuctionMod()
	return AuctionMod;
end
