--[[--
	by ALA @ 163UI
--]]--
----------------------------------------------------------------------------------------------------
local __addon_, __namespace__ = ...;
local __db__ = __namespace__.__db__;
local L = __namespace__.L;

-->		upvalue
	local hooksecurefunc = hooksecurefunc;
	local tonumber = tonumber;
	local select = select;
	local setmetatable = setmetatable;
	local rawget = rawget;
	local next = next;

	local min = math.min;
	local max = math.max;
	local strrep = string.rep;
	local strupper = string.upper;
	local strfind = string.find;
	local format = string.format;
	local tinsert = table.insert;

	local IsShiftKeyDown = IsShiftKeyDown;
	local GetItemQualityColor = GetItemQualityColor;
	local GetPlayerInfoByGUID = GetPlayerInfoByGUID;
	local UnitFactionGroup = UnitFactionGroup;
	local GetCraftReagentItemLink = GetCraftReagentItemLink;
	local RAID_CLASS_COLORS = RAID_CLASS_COLORS;

	local _G = _G;
	--[[
		local UnitGUID = UnitGUID;
		local GameTooltip = GameTooltip;
		local ItemRefTooltip = ItemRefTooltip;
	]]
-->


local CURPHASE = __db__.CURPHASE;

local PLAYER_GUID = UnitGUID('player');


local AVAR, VAR, SET, FAV = nil, nil, nil, nil;
local AuctionMod = nil;


----	index
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
	local index_rid = 16;
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
----


-->		****************
__namespace__:BuildEnv("tooltip");
-->		****************


local T_PriceSpellBlackList = __db__.T_PriceSpellBlackList;
local T_PriceItemBlackList = __db__.T_PriceItemBlackList;
local T_SpaceTable = setmetatable({}, {
	__index = function(t, k)
		local str = "|cff000000" .. strrep("*", 2 * k) .. "|r";
		t[k] = str;
		return str;
	end,
});
--	return price, cost, cost_known, missing, cid
local function F_GetPriceInfoBySID(phase, sid, num, lines, stack_level, is_enchanting, ...)	--	AuctionMod not checked
	local info = __db__.get_info_by_sid(sid);
	if info ~= nil then
		num = num or 1;
		stack_level = stack_level or 0;
		local cid = info[index_cid];
		local cost = nil;
		local cost_known = 0;
		local missing = 0;
		local detail_lines = lines and {  };
		if stack_level == 0 then
			phase = max(info[index_phase], phase);
		end
		if stack_level <= 4 then
			local pid = info[index_pid];
			if info[index_phase] <= phase then
				local reagid = info[index_reagents_id];
				local reagnum = info[index_reagents_count];
				cost = 0;
				for i = 1, #reagid do
					local iid = reagid[i];
					local num = reagnum[i];
					local p, c = nil, nil;
					local got = false;
					if not T_PriceItemBlackList[iid] then
						if iid == cid then
							got = true;
							c = 0;
						else
							for index = 1, select("#", ...) do
								if iid == select(index, ...) then
									got = true;
									break;
								end
							end
						end
						if got then
							got = false;
						else
							local nsids, sids = __db__.get_sid_by_cid(iid);
							if nsids > 0 then
								for index = 1, #sids do
									local sid = sids[index];
									if __db__.get_pid_by_sid(sid) == pid then
										local p2, c2 = F_GetPriceInfoBySID(phase, sid, num, detail_lines, stack_level + 1, nil, cid, ...);
										p = p or p2;
										if c2 then
											if c and c > c2 or not c then
												c = c2;
											end
										end
										got = true;
									end
								end
							end
						end
					end
					if not got then
						local name = AuctionMod.F_QueryNameByID(iid) or __db__.item_name_s(iid);
						local quality = AuctionMod.F_QueryQualityByID(iid) or __db__.item_rarity(iid);
						if quality then
							local _, _, _, code = GetItemQualityColor(quality);
							name = "|c" .. code .. name .. "|r";
						end
						if iid ~= cid then
							p = AuctionMod.F_QueryPriceByID(iid);
							local v = AuctionMod.F_QueryVendorPriceByID(iid);
							if v then
								if p == nil or p > v then
									p = v;
								end
							end
							if p then
								p = p * num;
								if detail_lines then
									tinsert(detail_lines, T_SpaceTable[stack_level + 1] .. name .. "x" .. num);
									tinsert(detail_lines, AuctionMod.F_GetMoneyString(p));
								end
							else
								if detail_lines then
									local bindType = __db__.item_bindType(iid);
									if bindType == 1 or bindType == 4 then
										tinsert(detail_lines, T_SpaceTable[stack_level + 1] .. name .. "x" .. num);
										tinsert(detail_lines, L["BOP"]);
									else
										tinsert(detail_lines, T_SpaceTable[stack_level + 1] .. name .. "x" .. num);
										tinsert(detail_lines, L["UNKOWN_PRICE"]);
									end
								end
							end
						else
							if detail_lines then
								tinsert(detail_lines, T_SpaceTable[stack_level + 1] .. name .. "x" .. num);
								tinsert(detail_lines, "-");
							end
						end
					end
					if not p and not c then
						cost = nil;
						if stack_level > 0 then
							break;
						end
						missing = missing + 1;
					else
						if p then
							if c and p > c then
								p = c;
							end
						else
							p = c;
						end
						if cost then
							cost = cost + p;
						end
						cost_known = cost_known + p;
					end
				end
			end
		end
		local vendorPrice = cid and AuctionMod.F_QueryVendorPriceByID(cid);
		local price = cid and AuctionMod.F_QueryPriceByID(cid);
		if vendorPrice then
			if price == nil or vendorPrice < price then
				price = vendorPrice;
			end
		end
		price = price and price * num;
		local nMade = (info[index_num_made_min] + info[index_num_made_max]) / 2;
		cost = cost and cost * num / nMade;
		cost_known = cost_known and cost_known * num / nMade;
		local name = cid and (AuctionMod.F_QueryNameByID(cid) or __db__.item_name_s(cid));
		local quality = cid and (AuctionMod.F_QueryQualityByID(cid) or __db__.item_rarity(cid));
		if quality then
			local _, _, _, code = GetItemQualityColor(quality);
			name = name and ("|c" .. code .. name .. "|r") or "";
		else
			name = name or "";
		end
		if stack_level == 0 then
			if lines then
				for index = 1, #detail_lines do
					tinsert(lines, detail_lines[index]);
				end
				if is_enchanting then
					if cost then
						tinsert(lines, "|cffff7f00**|r" .. "|cffffffff" .. __db__.spell_name_s(sid) .. "|r" or L["COST_PRICE"]);
						tinsert(lines, L["COST_PRICE"] .. AuctionMod.F_GetMoneyString(cost));
					else
						tinsert(lines, "|cffff7f00**|r" .. "|cffffffff" .. __db__.spell_name_s(sid) .. "|r" or L["COST_PRICE"]);
						tinsert(lines, L["COST_PRICE_KNOWN"] .. AuctionMod.F_GetMoneyString(cost_known));
					end
				else
					if cost then
						tinsert(lines, "|cffff7f00**|r" .. name .. "x" .. num);
						tinsert(lines, L["COST_PRICE"] .. AuctionMod.F_GetMoneyString(cost));
					else
						tinsert(lines, "|cffff7f00**|r" .. name .. "x" .. num);
						tinsert(lines, L["COST_PRICE_KNOWN"] .. AuctionMod.F_GetMoneyString(cost_known));
					end
					if price then
						tinsert(lines, "|cff00ff00**|r" .. name .. "x" .. num);
						tinsert(lines, L["AH_PRICE"] .. AuctionMod.F_GetMoneyString(price));
					end
					if cost and price then
						local diff = price - cost;
						local diffAH = price * 0.95 - cost;
						if diff > 0 then
							tinsert(lines, "|cff00ff00**|r" .. L["PRICE_DIFF+"]);
							tinsert(lines, L["PRICE_DIFF_INFO+"] .. AuctionMod.F_GetMoneyString(diff));
							if diffAH > 0 then
								tinsert(lines, "|cff00ff00**|r" .. L["PRICE_DIFF_AH+"]);
								tinsert(lines, L["PRICE_DIFF_INFO+"] .. AuctionMod.F_GetMoneyString(diffAH));
							elseif diffAH < 0 then
								tinsert(lines, "|cffff0000**|r" .. L["PRICE_DIFF_AH-"]);
								tinsert(lines, L["PRICE_DIFF_INFO-"] .. AuctionMod.F_GetMoneyString(-diffAH));
							else
							end
						elseif diff < 0 then
							tinsert(lines, "|cffff0000**|r" .. L["PRICE_DIFF-"]);
							tinsert(lines, L["PRICE_DIFF_INFO-"] .. AuctionMod.F_GetMoneyString(-diff));
							tinsert(lines, "|cffff0000**|r" .. L["PRICE_DIFF_AH-"]);
							tinsert(lines, L["PRICE_DIFF_INFO-"] .. AuctionMod.F_GetMoneyString(-diffAH));
						end
					end
				end
			end
		else
			if price and (not cost or cost >= price) then
				if lines then
					tinsert(lines, T_SpaceTable[stack_level] .. name .. "x" .. num);
					tinsert(lines, AuctionMod.F_GetMoneyString(price));
				end
			elseif cost and (not price or cost < price) then
				if lines then
					tinsert(lines, T_SpaceTable[stack_level] .. name .. "x" .. num);
					tinsert(lines, AuctionMod.F_GetMoneyString(cost));
					for index = 1, #detail_lines do
						tinsert(lines, detail_lines[index]);
					end
				end
				price = nil;
			else
				if lines then
					local bindType = __db__.item_bindType(cid);
					if bindType == 1 or bindType == 4 then
						tinsert(lines, T_SpaceTable[stack_level] .. name .. "x" .. num);
						tinsert(lines, L["BOP"]);
					else
						tinsert(lines, T_SpaceTable[stack_level] .. name .. "x" .. num);
						tinsert(lines, L["UNKOWN_PRICE"]);
					end
				end
			end
		end
		return price, cost, cost_known, missing, cid;
	end
end
local function set_tip_by_sid(tip, sid)
	local info = __db__.get_info_by_sid(sid);
	if info ~= nil then
		tip:AddLine(L["CRAFT_INFO"]);
		local cid = info[index_cid];
		local pid = info[index_pid];
		local texture = __db__.get_texture_by_pid(pid);
		-- local rank = info[index_learn_rank];
		local pname = __db__.get_pname_by_pid(pid) or "";
		if texture then
			pname = "|T" .. texture .. ":12:12:0:0|t " .. pname;
		end
		-- if rank then
		-- 	pname = pname .. "(" .. rank .. ")";
		-- end
		pname = pname .. " " .. __db__.get_difficulty_rank_list_text_by_sid(sid, true) .. "";
		tip:AddLine("|cff00afff" .. pname .. "|r");
		local detail_lines = {  };
		F_GetPriceInfoBySID(tip.__phase or CURPHASE, sid, (info[index_num_made_min] + info[index_num_made_max]) / 2, detail_lines, 0, cid == nil);
		if #detail_lines > 0 then
			for i = 1, #detail_lines, 2 do
				tip:AddDoubleLine(detail_lines[i], detail_lines[i + 1]);
			end
			tip:Show();
		end
	end
end
local function set_tip_by_cid(tip, cid)
	local nsids, sids = __db__.get_sid_by_cid(cid);
	if nsids > 0 then
		tip:AddLine(L["CRAFT_INFO"]);
		for index = 1, #sids do
			local sid = sids[index];
			local info = __db__.get_info_by_sid(sid);
			if info ~= nil then
				local pid = info[index_pid];
				local texture = __db__.get_texture_by_pid(pid);
				-- local rank = info[index_learn_rank];
				local pname = __db__.get_pname_by_pid(pid) or "";
				if texture then
					pname = "|T" .. texture .. ":12:12:0:0|t " .. pname;
				end
				-- if rank then
				-- 	pname = pname .. "(" .. rank .. ")";
				-- end
				pname = pname .. " " .. __db__.get_difficulty_rank_list_text_by_sid(sid, true) .. "";
				tip:AddLine("|cff00afff" .. pname .. "|r");
				local detail_lines = {  };
				F_GetPriceInfoBySID(tip.__phase or CURPHASE, sid, (info[index_num_made_min] + info[index_num_made_max]) / 2, detail_lines, 0, false);
				if #detail_lines > 0 then
					for i = 1, #detail_lines, 2 do
						tip:AddDoubleLine(detail_lines[i], detail_lines[i + 1]);
					end
				end
			end
		end
		tip:Show();
	end
end
local function LF_AddAccountLearnedInfo(tip, rid, sid)
	sid = sid or __db__.get_sid_by_rid(rid);
	if sid then
		local info = __db__.get_info_by_sid(sid);
		if info ~= nil then
			local pid = info[index_pid];
			local add_head = true;
			local learn_rank = info[index_learn_rank];
			for GUID, VAR in next, AVAR do
				-- if PLAYER_GUID ~= GUID then
					local var = rawget(VAR, pid);
					if var then
						if add_head then
							tip:AddLine(L["LABEL_ACCOUT_RECIPE_LEARNED"]);
							add_head = false;
						end
						local lClass, class, lRace, race, sex, name = GetPlayerInfoByGUID(GUID);
						if name and class then
							local classColorTable = RAID_CLASS_COLORS[strupper(class)];
							name = format("|cff%.2x%.2x%.2x", classColorTable.r * 255, classColorTable.g * 255, classColorTable.b * 255) .. name .. "|r";
						else
							name = GUID;
						end
						if var[2][sid] then
							name = T_SpaceTable[1] .. L["RECIPE_LEARNED"] .. "  " .. name .. "  |cffffffff" .. var.cur_rank .. "/" .. var.max_rank .. "|r";
						else
							name = T_SpaceTable[1] .. L["RECIPE_NOT_LEARNED"] .. "  " .. name
										.. ((var.cur_rank >= learn_rank) and "  |cff00ff00" or "  |cffff0000") .. var.cur_rank
										.. ((var.max_rank >= learn_rank) and "|r|cffffffff/|r|cff00ff00" or "|r|cffffffff/|r|cffff0000") .. var.max_rank .. "|r";
							-- if var.cur_rank >= learn_rank then
							-- 	name = T_SpaceTable[1] .. L["RECIPE_NOT_LEARNED"] .. "  " .. name .. "  |cff00ff00" .. var.cur_rank .. "|r|cffffffff/" .. var.max_rank .. "|r";
							-- else
							-- 	name = T_SpaceTable[1] .. L["RECIPE_NOT_LEARNED"] .. "  " .. name .. "  |cffff0000" .. var.cur_rank .. "|r|cffffffff/" .. var.max_rank .. "|r";
							-- end
						end
						tip:AddLine(name);
					end
				-- end
			end
			tip:Show();
		end
	end
end
local function LF_AddMaterialCraftInfo(tip, iid)
	local data = __db__.get_sid_by_reagent(iid);
	if data then
		local not_show_all = not IsShiftKeyDown();
		tip:AddLine(L["LABEL_USED_AS_MATERIAL_IN"]);
		local lineL = nil;
		local lineR = nil;
		local nLines = 0;
		local sids, nums = data[1], data[2];
		for index = 1, #sids do
			local sid = sids[index];
			local num = nums[index];
			if not_show_all and nLines >= 8 then
				tip:AddLine(T_SpaceTable[1] .. "|cffff0000...|r");
				break;
			end
			local info = __db__.get_info_by_sid(sid);
			if info ~= nil then
				local cid = info[index_cid];
				local pname = __db__.get_pname_by_pid(info[index_pid]) or "";
				if cid then
					lineL = T_SpaceTable[1] .. __db__.item_string_s(cid) .. "x" .. num;
					-- lineR = "|cff00afff" .. pname .. info[index_learn_rank] .. "|r";
				else
					lineL = T_SpaceTable[1] .. __db__.spell_string_s(sid) .. "x" .. num;
					-- lineR = "|cff00afff" .. pname .. info[index_learn_rank] .. "|r";
				end
					lineR = "|cff00afff" .. pname .. " " .. __db__.get_difficulty_rank_list_text_by_sid(sid, true) .. "|r";
				tip:AddDoubleLine(lineL, lineR);
				nLines = nLines + 1;
			end
		end
		tip:Show();
	end
end
local function LF_TooltipSetSpellByID(tip, sid)
	if AuctionMod ~= nil then
		if SET.show_tradeskill_tip_craft_spell_price then
			if sid and __db__.is_tradeskill_sid(sid) then
				set_tip_by_sid(tip, sid);
			end
		end
	end
end
local function LF_TooltipSetItemByID(tip, iid)
	if SET.show_tradeskill_tip_recipe_account_learned then
		LF_AddAccountLearnedInfo(tip, iid);
	end
	if SET.show_tradeskill_tip_material_craft_info then
		LF_AddMaterialCraftInfo(tip, iid);
	end
	if AuctionMod ~= nil then
		if SET.show_tradeskill_tip_craft_item_price then
			if iid and __db__.is_tradeskill_cid(iid) then
				set_tip_by_cid(tip, iid);
			end
		end
		if SET.show_tradeskill_tip_recipe_price then
			local sid = __db__.get_sid_by_rid(iid);
			if sid then
				set_tip_by_sid(tip, sid);
			end
		end
	end
end
local function LF_TooltipSetHyperlink(tip, link)
	local _, sid = tip:GetSpell();
	if sid then
		LF_TooltipSetSpellByID(tip, sid);
		return;
	end
	if link then
		local cid = tonumber(select(3, strfind(link, "item:(%d+)")) or nil);
		if cid then
			LF_TooltipSetItemByID(tip, cid);
		end
	end
end
local function LF_TooltipGUISetSpell(tip)
	local _, sid = tip:GetSpell();
	if sid then
		LF_TooltipSetSpellByID(tip, sid);
	end
end
local function LF_TooltipGUISetItem(tip)
	local _, link = tip:GetItem();
	if link then
		local iid = tonumber(select(3, strfind(link, "item:(%d+)")) or nil);
		if iid then
			LF_TooltipSetItemByID(tip, iid);
		end
	end
end
local function LF_TooltipSetCraftSpell(tip)
	local _, sid = tip:GetSpell();
	if sid then
		LF_TooltipSetSpellByID(tip, sid);
	else
		local _, link = tip:GetItem();
		local iid = link and tonumber(select(3, strfind(link, "item:(%d+)")) or nil);
		if iid then
			LF_TooltipSetItemByID(tip, iid);
		end
	end
end
local function F_HookTip(tip)
	hooksecurefunc(tip, "SetHyperlink", LF_TooltipSetHyperlink);
	hooksecurefunc(tip, "SetSpellByID", LF_TooltipSetSpellByID);
	hooksecurefunc(tip, "SetItemByID", LF_TooltipSetItemByID);
	hooksecurefunc(tip, "SetCraftSpell", LF_TooltipSetCraftSpell);
	--
	hooksecurefunc(tip, "SetMerchantItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetBuybackItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetBagItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetAuctionItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetAuctionSellItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetLootItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetLootRollItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetInventoryItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetTradePlayerItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetTradeTargetItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetQuestItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetQuestLogItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetInboxItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetSendMailItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetTradeSkillItem", LF_TooltipGUISetItem);
	hooksecurefunc(tip, "SetCraftItem", function(tip, recipe_index, reagent_index)
		local link = GetCraftReagentItemLink(recipe_index, reagent_index);
		if link then
			local iid = tonumber(select(3, strfind(link, "item:(%d+)")) or nil);
			if iid then
				LF_TooltipSetItemByID(tip, iid);
			end
		end
	end);
	hooksecurefunc(tip, "SetTrainerService", LF_TooltipGUISetItem);
end

__namespace__.F_HookTip = F_HookTip;
__namespace__.F_GetPriceInfoBySID = F_GetPriceInfoBySID;

local N_RecipeSourceMOD = 0;
local T_RecipeSourceMOD = {  };
-- function __namespace__:AddRecipeSourceMOD(mod)
--	-- N_RecipeSourceMOD = N_RecipeSourceMOD + 1;
-- 	-- T_RecipeSourceMOD[N_RecipeSourceMOD] = mod;
-- 	__namespace__:FireEvent("RECIPESOURCE_MOD_LOADED", mod);
-- end
__namespace__:AddCallback("RECIPESOURCE_MOD_LOADED", function(mod)
	if mod ~= nil then
		N_RecipeSourceMOD = N_RecipeSourceMOD + 1;
		T_RecipeSourceMOD[N_RecipeSourceMOD] = mod;
	end
end);
function __namespace__.F_TooltipAddSource(Tip, sid)
	if N_RecipeSourceMOD > 0 then
		for index = N_RecipeSourceMOD, 1, -1 do
			local mod = T_RecipeSourceMOD[index];
			if mod.Tip ~= nil then
				return mod.Tip(Tip, sid);
			end
		end
	end
end

local function LF_SetRecipeSourceTip(Tip, sid)
	local info = __db__.get_info_by_sid(sid);
	if info ~= nil then
		if info[index_trainer] ~= nil then			-- trainer
			Tip:AddDoubleLine(L["LABEL_GET_FROM"], "|cffff00ff" .. L["trainer"] .. "|r");
			Tip:Show();
		end
		local rid = info[index_rid];
		if rid ~= nil then				-- recipe
			local _, line, _, _, _, _, _, _, bind = __db__.item_info(rid);
			if not line then
				line = "|cffffffff" .. L["item"] .. "|r ID: " .. rid;
			end
			if bind ~= 1 and bind ~= 4 then
				line = line .. "(|cff00ff00" .. L["tradable"] .. "|r)";
				if AuctionMod ~= nil then
					local price = AuctionMod.F_QueryPriceByID(rid);
					if price and price > 0 then
						line = line .. " |cff00ff00AH|r " .. AuctionMod.F_GetMoneyString(price);
					end
				end
			else
				line = line .. "(|cffff0000" .. L["non_tradable"] .. "|r)";
			end
			Tip:AddDoubleLine(L["LABEL_GET_FROM"], line);
		end
		local qid = info[index_quest];
		if qid ~= nil then			-- quests
			Tip:AddDoubleLine(L["LABEL_GET_FROM"], "Quest: " .. qid);
		end
		-- if info[index_object] ~= nil then			-- objects
		-- 	if type(info[index_object]) == 'table' then
		-- 		for _, oid in next, info[index_object] do
		-- 			LF_MTSL_SetObject(info[index_pid], oid, L["LABEL_GET_FROM"], 1);
		-- 		end
		-- 	else
		-- 		LF_MTSL_SetObject(info[index_pid], info[index_object], L["LABEL_GET_FROM"], 1);
		-- 	end
		-- end
		Tip:Show();
	end
end

function __namespace__.init_tooltip()
	AVAR, VAR, SET, FAV = __namespace__.AVAR, __namespace__.VAR, __namespace__.SET, __namespace__.FAV;
	F_HookTip(GameTooltip);
	F_HookTip(ItemRefTooltip);
	__namespace__:AddCallback("AUCTION_MOD_LOADED", function(mod)
		if mod ~= nil then
			AuctionMod = mod;
		end
	end);
	__namespace__:FireEvent("RECIPESOURCE_MOD_LOADED", {
		Tip = LF_SetRecipeSourceTip,
		SetItem = __namespace__._noop_,
		SetUnit = __namespace__._noop_,
		SetObject = __namespace__._noop_,
		SetQuest = __namespace__._noop_,
	});
end
