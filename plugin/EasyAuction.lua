--[[--
	by enpingking (url = https://ngabbs.com/read.php?tid=45700523&_fu=1409755%2C2&rand=83)
--]]--


local __addon, __private = ...;
local MT = __private.MT;
local CT = __private.CT;
local VT = __private.VT;

local mod = {};

function mod.F_QueryPriceByID(id, num)
    if not id then return nil end
    local name = GetItemInfo(id)
    if not name then return nil end
    local history = EasyAuctionDB and EasyAuctionDB.PriceHistory and EasyAuctionDB.PriceHistory[name]
    if not history or #history == 0 then return nil end
    local min = nil
    for _, info in ipairs(history) do
        if info.unit then
            if not min or info.unit < min then
                min = info.unit
            end
        end
    end
    if min then
        return min * (num or 1)
    end
end

function mod.F_QueryPriceByName(name, num)
    if not name then return nil end
    local history = EasyAuctionDB and EasyAuctionDB.PriceHistory and EasyAuctionDB.PriceHistory[name]
    if not history or #history == 0 then return nil end
    local min = nil
    for _, info in ipairs(history) do
        if info.unit then
            if not min or info.unit < min then
                min = info.unit
            end
        end
    end
    if min then
        return min * (num or 1)
    end
end

MT.RegsiterAuctionModOnLoad("EasyAuction", function()
    MT.AddAuctionMod("EasyAuction", mod)
end)