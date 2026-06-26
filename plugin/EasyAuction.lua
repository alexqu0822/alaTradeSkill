--[[--
	by enpingking (url = https://ngabbs.com/read.php?tid=45700523&_fu=1409755%2C2&rand=83)
--]]--

local __addon, __private = ...;
local MT = __private.MT;
local CT = __private.CT;
local VT = __private.VT;
local DT = __private.DT;


-->		upvalue
    local type = type;
    local ipairs = ipairs;
    local _G = _G;

-->


-->		****
MT.BuildEnv("EasyAuction");
-->		****


local mod = {  };

-- 按 id 查询，自动拼 name:itemid
local function EA_DecodePriceHistoryString(raw)
    if type(raw) ~= "string" then return nil end
    local minText, _, body = raw:match("^PH2|([^|]*)|([^|]*)|(.*)$")
    if not minText then return nil end
    local records = {}
    for unitText, countText, timeText in tostring(body or ""):gmatch("([^,;]+),([^,;]+),([^;]+)") do
        local unit = tonumber(unitText)
        if unit and unit > 0 then
            records[#records + 1] = { unit = unit, count = tonumber(countText) or 1, t = tonumber(timeText) }
        end
    end
    return records
end

local function EA_NormalizePriceHistoryTable(raw)
    if type(raw) ~= "table" then return nil end
    local records = {}
    for _, rec in ipairs(raw) do
        if type(rec) == "table" and rec.unit then
            records[#records + 1] = {
                unit = tonumber(rec.unit) or rec.unit,
                count = tonumber(rec.count) or 1,
                t = tonumber(rec.t)
            }
        end
    end
    return records
end

local function EA_GetPriceHistoryRecords(raw)
    if type(raw) == "table" then
        return EA_NormalizePriceHistoryTable(raw)
    elseif type(raw) == "string" then
        return EA_DecodePriceHistoryString(raw)
    end
    return nil
end

function mod.F_QueryPriceByID(id, num)
    if mod.dbver == 1 then
        if not id then return nil end
        local name = mod.F_QueryNameByID(id)
        if not name then return nil end
        local EasyAuctionDB = _G.EasyAuctionDB;
        local raw = EasyAuctionDB and EasyAuctionDB.PriceHistory and EasyAuctionDB.PriceHistory[name]
        local history = EA_GetPriceHistoryRecords(raw)
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
    else
        if not id then return nil end
        local name = mod.F_QueryNameByID(id)
        if not name then return nil end
        local key = name .. ":" .. id
        local EasyAuctionDB = _G.EasyAuctionDB;
        local raw = EasyAuctionDB and EasyAuctionDB.PriceHistory and EasyAuctionDB.PriceHistory[key]
        local history = EA_GetPriceHistoryRecords(raw)
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
end

-- 按 name 查询，自动遍历所有 name:itemid，取最低价
function mod.F_QueryPriceByName(name, num)
    if mod.dbver == 1 then
        if not name then return nil end
        local min = nil
        local EasyAuctionDB = _G.EasyAuctionDB
        if EasyAuctionDB and EasyAuctionDB.PriceHistory then
            local raw = EasyAuctionDB.PriceHistory[name]
            local history = EA_GetPriceHistoryRecords(raw)
            if not history or #history == 0 then return nil end
            for _, info in ipairs(history) do
                if info.unit then
                    if not min or info.unit < min then
                        min = info.unit
                    end
                end
            end
        end
        if min then
            return min * (num or 1)
        end
    else
        if not name then return nil end
        local min = nil
        local EasyAuctionDB = _G.EasyAuctionDB
        if EasyAuctionDB and EasyAuctionDB.PriceHistory then
            for key, raw in pairs(EasyAuctionDB.PriceHistory) do
                if type(key) == "string" and key:match("^(.-):%d+$") == name then
                    local history = EA_GetPriceHistoryRecords(raw)
                    if history and #history > 0 then
                        for _, info in ipairs(history) do
                            if info.unit then
                                if not min or info.unit < min then
                                    min = info.unit
                                end
                            end
                        end
                    end
                end
            end
        end
        if min then
            return min * (num or 1)
        end
    end
end

MT.RegsiterAuctionModOnLoad("EasyAuction", function()
    local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata;
    local version = GetAddOnMetadata("EasyAuction", "Version");
    mod.version = version
    mod.dbver = 1
    if version then
        local major, minor, patch = strsplit(".", version)
        major = tonumber(major)
        minor = tonumber(minor)
        patch = tonumber(patch)
        if major and minor and patch then
            if major > 2
                or (major == 2 and minor > 3)
                or (major == 2 and minor == 3 and patch >= 6)
            then
                mod.dbver = 2
            end
        end
    end
    MT.AddAuctionMod("EasyAuction", mod)
end)
