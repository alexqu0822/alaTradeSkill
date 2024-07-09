--[[--
	by ALA 
--]]--
----------------------------------------------------------------------------------------------------
local __addon, __private = ...;
local MT = __private.MT;
local CT = __private.CT;
local VT = __private.VT;
local DT = __private.DT;

-->		upvalue
	local next = next;

	local min = math.min;
	local max = math.max;
	local format = string.format;

	local GetMapInfo = C_Map.GetMapInfo;
	local GetAreaInfo = C_Map.GetAreaInfo;
	local GetFactionInfoByID = GetFactionInfoByID;
	local IsAddOnLoaded = IsAddOnLoaded;

	local _G = _G;
-->
	local DataAgent = DT.DataAgent;
	local l10n = CT.l10n;

-->
MT.BuildEnv("CodexLite");
-->		predef
	local index_validated = 1;
	local index_phase = 2;
	local index_pid = 3;
	local index_sid = 4;
	local index_cid = 5;
	local index_learn_rank = 6;
	local index_yellow_rank = 7;
	local index_green_rank = 8;
	local index_grey_rank = 9;
	local index_num_made_min = 10;
	local index_num_made_max = 11;
	local index_reagents_id = 12;
	local index_reagents_count = 13;
	local index_trainer = 14;
	local index_train_price = 15;
	local index_recipe = 16;
	local index_quest = 17;
	local index_object = 18;
	local index_class = 19;
	local index_spec = 20;
	--
	-- 1itemName, 2itemLink, 3itemRarity, 4itemLevel, 5itemMinLevel, 6itemType, 7itemSubType, 8itemStackCount,
	-- 9itemEquipLoc, 10itemIcon, 11itemSellPrice, 12itemClassID, 13itemSubClassID, 14bindType, 15expacID, 16itemSetID, 
	-- 17isCraftingReagent = GetItemInfo(itemID or "itemString" or "itemName" or "itemLink") 
	local index_i_name = 1;			--	1
	local index_i_link = 2;			--	2
	local index_i_rarity = 3;		--	3
	local index_i_loc = 4;			--	9
	local index_i_icon = 5;			--	10
	local index_i_sellPrice = 6;	--	11
	local index_i_typeID = 7;		--	12
	local index_i_subTypeID = 8;	--	13
	local index_i_bindType = 9;		--	14	--	0 - none; 1 - on pickup; 2 - on equip; 3 - on use; 4 - quest.
	-- local index_i_ilevel = 4;		--	4
	-- local index_i_plevel = 5;		--	5
	-- local index_i_type = 6;			--	6
	-- local index_i_subType = 7;		--	7
	-- local index_i_stackCount = 7;	--	8
	local index_i_name_lower = 10;
	local index_i_link_lower = 11;
	local index_i_string = 12;
-->

local CodexLite = nil;
local CodexLiteDataAgent = nil;
local CodexLiteLocale = nil;

--	mtsl
local LT_MTSL_LocaleKey = {
	["enUS"] = "English",
	["frFR"] = "French",
	["deDE"] = "German",
	["ruRU"] = "Russian",
	["koKR"] = "Korean",
	["zhCN"] = "Chinese",
	["zhTW"] = "Chinese",
	["esES"] = "Spanish",
	["ptBR"] = "Portuguese",
};
local LT_MTSL_SkillName = {
	[1] = "First Aid",
	[2] = "Blacksmithing",
	[3] = "Leatherworking",
	[4] = "Alchemy",
	[6] = "Cooking",
	[7] = "Mining",
	[8] = "Tailoring",
	[9] = "Engineering",
	[10] = "Enchanting",
	[15] = "Jewelcrafting",
};
local MTSL_LOCALE = LT_MTSL_LocaleKey[CT.LOCALE] or LT_MTSL_LocaleKey.enUS;

local LF_Codex_SetQuest;
local LF_Codex_SetItem;
local LF_Codex_SetObject;
local LF_Codex_SetUnit;
local LT_MapName = {  };

local function LF_MTSL_AddReputation(Tip, rep, val)
	local line = nil;
	local name = GetFactionInfoByID(rep);
	if name then
		line = name;
	else
		line = "factionID: " .. rep;
	end
	local rank = 1;
	for r = 1, #LT_StandingRank_Value do
		if val >= LT_StandingRank_Value[r] then
			rank = r;
		end
	end
	if rank == 8 or val - LT_StandingRank_Value[rank] == 0 then
		line = line .. LT_StandingRank_Color[rank] .. LT_StandingRank_Text[rank] .. "|r"
	else
		line = line .. LT_StandingRank_Color[rank] .. LT_StandingRank_Text[rank] .. "|r>=" .. (val - LT_StandingRank_Value[rank])
	end
	Tip:AddDoubleLine(" ", line);
	Tip:Show();
end
local LT_StandingRank_Color = {
	[0] = "|cffff0000",
	[1] = "|cffff0000",	--	仇恨
	[2] = "|cffff0000",	--	敌对
	[3] = "|cffff0000",	--	冷淡
	[4] = "|cffffff00",	--	中立
	[5] = "|cff00ff00",	--	友善
	[6] = "|cff00ff00",	--	尊敬
	[7] = "|cff00ff00",	--	崇敬
	[8] = "|cff00ff00",	--	崇拜
	[9] = "|cff00ff00",
	[10] = "|cff00ff00",
	[11] = "|cff00ff00",
	[12] = "|cff00ff00",
	[13] = "|cff00ff00",
};
local LT_StandingRank_Value = {
	[1] = -6000,
	[2] = -3000,
	[3] = 0,
	[4] = 3000,
	[5] = 6000,
	[6] = 12000,
	[7] = 21000,
	[8] = 42000,
};
local LT_StandingRank_Text = {
	FACTION_STANDING_LABEL1,
	FACTION_STANDING_LABEL2,
	FACTION_STANDING_LABEL3,
	FACTION_STANDING_LABEL4,
	FACTION_STANDING_LABEL5,
	FACTION_STANDING_LABEL6,
	FACTION_STANDING_LABEL7,
	FACTION_STANDING_LABEL8,
};

LF_Codex_SetUnit = function(Tip, pid, uid, label, isAlliance, prefix, suffix, stack_size)
	if stack_size < 8 then
		if CodexLiteDataAgent then
			local info = CodexLiteDataAgent.unit[uid];
			if info then
				local color = "|cffffffff";
				if info.facId then
					local _, _, standing_rank, _, _, val = GetFactionInfoByID(info.facId);
					color = LT_StandingRank_Color[standing_rank] or color;
				end
				local line = prefix .. color;
				local name = CodexLiteLocale.unit[uid];
				if name then
					line = line .. "[" .. name .. "]|r";
				else
					line = line .. "[npcID: " .. uid .. "]|r";
				end
				if info.minLvl ~= nil then
					if info.maxLvl ~= nil and info.minLvl ~= info.maxLvl then
						line = line .. "Lv" .. info.minLvl .. "-" .. info.maxLvl;
					else
						line = line .. "Lv" .. info.minLvl;
					end
				elseif info.maxLvl ~= nil then
					line = line .. "Lv" .. info.maxLvl;
				end
				line = line .. "|r" .. suffix;
				Tip:AddDoubleLine(label, line);
				local coords = info.coords;
				if coords then
					for i = 1, min(#coords, 6) do
						local coord = coords[i];
						local map = LT_MapName[coord[3]];
						if map == nil then
							local mapinfo = GetMapInfo(coord[3]);
							if mapinfo then
								map = mapinfo.name;
								LT_MapName[coord[3]] = map;
							else
								map = "Map: " .. coord[i];
							end
						end
						Tip:AddDoubleLine(" ", format("(%.1f, %.1f) %s", coord[1], coord[2], map), 1, 1, 1, 1, 1, 1);
					end
					if #coords > 6 then
						Tip:AddDoubleLine(" ", "...(+" .. (#coords - 6) .. ")", 1, 1, 1, 1, 1, 1);
					end
				end
				local spawn = info.spawn;
				if spawn then
					if spawn.O then
						for oid, _ in next, spawn.O do
							LF_Codex_SetObject(Tip, pid, oid, " ", CT.SELFISALLIANCE, "@", "", stack_size + 1);
						end
					end
					if spawn.U then
						for uid, _ in next, spawn.U do
							LF_Codex_SetUnit(Tip, pid, uid, " ", CT.SELFISALLIANCE, "@", "", stack_size + 1);
						end
					end
				end
			else
				local line = prefix;
				local name = CodexLiteLocale.unit[uid];
				if name then
					line = line .. "|cffffffff[" .. name .. "]|r";
				else
					line = line .. "|cffffffff[npcID: " .. uid .. "]|r";
				end
				line = line .. suffix;
				Tip:AddDoubleLine(label, line);
			end
		else
			Tip:AddDoubleLine(label, prefix .. "|cffffffff[npcID: " .. uid .. "]|r" .. suffix);
		end
		Tip:Show();
	end
end
LF_Codex_SetQuest = function(Tip, pid, qid, label, stack_size)
	if stack_size <= 8 then
		if CodexLiteDataAgent then
			local info = CodexLiteDataAgent.quest[qid];
			if info then
				local line = "|cffffff00[";
				local desc = CodexLiteLocale.quest[qid];
				if desc and desc[1] then
					line = line .. desc[1] .. "]|r(ID: " .. qid .. ")";
				else
					line = line .. l10n["quest"] .. " ID: " .. qid .. "]|r";
				end
				if info.min then
					line = line .. "Lv" .. info.min;
				end
				Tip:AddDoubleLine(label, l10n["quest_reward"] .. ": " .. line);
				if info.rep then
					for i = 1, #info.rep do
						local rep = info.rep[i];
						LF_MTSL_AddReputation(Tip, rep[1], rep[2]);
					end
				end
				if info.race then
				end
				if info.class then
				end
				if info.skill then
				end
				local start = info.start;
				if start then
					if start.U then
						for _, uid in next, start.U do
							LF_Codex_SetUnit(Tip, pid, uid, " ", CT.SELFISALLIANCE, l10n["quest_accepted_from"], "", stack_size + 1);
						end
					end
					if start.O then
						for _, oid in next, start.O do
							LF_Codex_SetObject(Tip, pid, oid, " ", CT.SELFISALLIANCE, l10n["quest_accepted_from"], "", stack_size + 1);
						end
					end
					if start.I then
						for _, iid in next, start.I do
							LF_Codex_SetItem(Tip, pid, iid, " ", l10n["quest_accepted_from"], "", stack_size + 1);
						end
					end
				end
			else
				local line = "|cffffff00[";
				local desc = CodexLiteLocale.quest[qid];
				if desc and desc[1] then
					line = line .. desc[1] .. "]|r(ID: " .. qid .. ")";
				else
					line = line .. l10n["quest"] .. "|r ID: " .. qid .. "]";
				end
				Tip:AddDoubleLine(label, l10n["quest_reward"] .. ": " .. line);
			end
		else
			Tip:AddDoubleLine(label, l10n["quest_reward"] .. ": |cffffff00[" .. l10n["quest"] .. " ID: " .. qid .. "]|r");
		end
	end
end
LF_Codex_SetItem = function(Tip, pid, iid, label, prefix, suffix, stack_size)
	if stack_size <= 8 then
		local _, line, _, _, _, _, _, _, bind = DataAgent.item_info(iid);
		if not line then
			line = "|cffffffff[" .. l10n["item"] .. "|r ID: " .. iid .. "]";
		end
		line = suffix .. line;
		if bind ~= 1 and bind ~= 4 then
			line = line .. "(|cff00ff00" .. l10n["tradable"] .. "|r)";
			if VT.AuctionMod ~= nil then
				local price = VT.AuctionMod.F_QueryPriceByID(iid);
				if price ~= nil and price > 0 then
					line = line .. " |cff00ff00AH|r " .. MT.GetMoneyString(price);
				end
			end
		else
			line = line .. "(|cffff0000" .. l10n["non_tradable"] .. "|r)";
		end
		line = line .. suffix;
		Tip:AddDoubleLine(label, line);
		if CodexLiteDataAgent then
			local info = CodexLiteDataAgent.item[iid];
			if info then
				if info.V then
					for uid, _ in next, info.V do
						LF_Codex_SetUnit(Tip, pid, uid, " ", CT.SELFISALLIANCE, l10n["sold_by"], "|r", stack_size + 1);
					end
				end
				if info.U then
					for uid, rate in next, info.U do
						if rate > 10 then
							LF_Codex_SetUnit(Tip, pid, uid, " ", not CT.SELFISALLIANCE, l10n["dropped_by"], "", stack_size + 1);
						end
					end
				end
				if info.O then
					for oid, rate in next, info.O do
						if rate > 10 then
							LF_Codex_SetObject(Tip, pid, oid, " ", CT.SELFISALLIANCE, l10n["dropped_by"], "", stack_size + 1);
						end
					end
				end
			end
		end
		Tip:Show();
	end
end
local LT_ObjectStanding_Prefix = {	--	FactionGroup == "Alliance"
	[true] = {
		A = ": |Tinterface\\timer\\Alliance-logo:20|t|cff00ff00",
		AH = ": |Tinterface\\timer\\Alliance-logo:20|t|cff00ff00",
		H = ": |Tinterface\\timer\\Horde-logo:20|t|cffff0000",
		["*"] = ": |cffffffff",
	},
	[false] = {
		A = ": |Tinterface\\timer\\Alliance-logo:20|t|cffff0000",
		H = ": |Tinterface\\timer\\Horde-logo:20|t|cff00ff00",
		AH = ": |Tinterface\\timer\\Horde-logo:20|t|cff00ff00",
		["*"] = ": |cffffffff",
	},
};
LF_Codex_SetObject = function(Tip, pid, oid, label, isAlliance, prefix, suffix, stack_size)
	if stack_size <= 8 then
		if CodexLiteDataAgent then
			local info = CodexLiteDataAgent.object[oid];
			if info then
				local colortable = LT_ObjectStanding_Prefix[isAlliance];
				local line = prefix .. (colortable[info.fac] or colortable["*"]);
				local name = CodexLiteLocale.object[oid];
				if name then
					line = line .. "[" .. name .. "]|r";
				else
					line = line .. "[objectID: " .. oid .. "]|r";
				end
				line = line .. "|r" .. suffix;
				Tip:AddDoubleLine(label, line);
				local coords = info.coords;
				if coords then
					for i = 1, min(#coords, 6) do
						local coord = coords[i];
						local map = LT_MapName[coord[3]];
						if map == nil then
							local mapinfo = GetMapInfo(coord[3]);
							if mapinfo then
								map = mapinfo.name;
								LT_MapName[coord[3]] = map;
							else
								map = "Map: " .. coord[i];
							end
						end
						Tip:AddDoubleLine(" ", format("(%.1f, %.1f) %s", coord[1], coord[2], map), 1, 1, 1, 1, 1, 1);
					end
					if #coords > 6 then
						Tip:AddDoubleLine(" ", "...(+" .. (#coords - 6) .. ")", 1, 1, 1, 1, 1, 1);
					end
				end
				local spawn = info.spawn;
				if spawn.O then
					for oid, _ in next, spawn.O do
						LF_Codex_SetObject(Tip, pid, oid, " ", CT.SELFISALLIANCE, "@", "", stack_size + 1);
					end
				end
				if spawn.U then
					for uid, _ in next, spawn.U do
						LF_Codex_SetUnit(Tip, pid, uid, " ", CT.SELFISALLIANCE, "@", "", stack_size + 1);
					end
				end
			else
				local line = prefix;
				local name = CodexLiteLocale.object[oid];
				if name then
					line = line .. "|cffffffff[" .. name .. "]|r";
				else
					line = line .. "|cffffffff[objectID: " .. oid .. "]|r";
				end
				line = line .. suffix;
				Tip:AddDoubleLine(label, line);
			end
		else
			Tip:AddDoubleLine(label, prefix .. "|cffffffff[objectID: " .. oid .. "]|r" .. suffix);
		end
		Tip:Show();
	end
end
local function LF_Codex_SetSpellTip(Tip, sid)
	local info = DataAgent.get_info_by_sid(sid);
	if info ~= nil then
		local spec = info[index_spec];
		if spec ~= nil then
			local name = DataAgent.spell_name(spec);
			if name ~= nil then
				if DataAgent.is_spec_learned(spec) then
					Tip:AddDoubleLine(" ", name, 1, 1, 1, 0, 1, 0);
				else
					Tip:AddDoubleLine(" ", name, 1, 1, 1, 1, 0, 0);
				end
			end
		end
		if info[index_trainer] ~= nil then			-- trainer
			local price = info[index_train_price];
			if price ~= nil and price > 0 then
				Tip:AddDoubleLine(l10n["LABEL_GET_FROM"], "|cffff00ff" .. l10n["trainer"] .. "|r " ..  MT.GetMoneyString(price));
			else
				Tip:AddDoubleLine(l10n["LABEL_GET_FROM"], "|cffff00ff" .. l10n["trainer"] .. "|r");
			end
		end
		--
		local pid = info[index_pid];
		local rids = info[index_recipe];
		if rids then				-- recipe
			for index = 1, #rids do
				local rid = rids[index];
				LF_Codex_SetItem(Tip, pid, rid, l10n["LABEL_GET_FROM"], "", "", 1);
			end
		end
		local qids = info[index_quest];
		if qids then			-- quests
			for index = 1, #qids do
				local qid = qids[index];
				LF_Codex_SetQuest(Tip, pid, qid, l10n["LABEL_GET_FROM"], 1);
			end
		end
		local oid = info[index_object];
		if oid ~= nil then			-- objects
			if type(oid) == 'table' then
				for _, oid in next, oid do
					LF_Codex_SetObject(Tip, pid, oid, l10n["LABEL_GET_FROM"], CT.SELFISALLIANCE, "", "", 1);
				end
			else
				LF_Codex_SetObject(Tip, pid, oid, l10n["LABEL_GET_FROM"], CT.SELFISALLIANCE, "", "", 1);
			end
		end
		Tip:Show();
	end
end


MT.RegisterOnAddOnLoaded("CodexLite", function()
	CodexLite = __ala_meta__.quest;
	CodexLiteLocale = CodexLite.CT.l10n;
	CodexLiteDataAgent = CodexLite.DT.DB;
	MT.FireCallback("RECIPESOURCE_MOD_LOADED", {
		SetSpell = LF_Codex_SetSpellTip,
		SetItem = LF_Codex_SetItem,
		SetUnit = LF_Codex_SetUnit,
		SetObject = LF_Codex_SetObject,
		SetQuest = LF_Codex_SetQuest,
	});
end);
