﻿--[[--
	by ALA
--]]--
--[[
	Scroll = __ala_meta__.__scrolllib.CreateScrollFrame(Parent, width, height, ButtonHeight, Creator(Parent: ScrollFrame.ScrollChild, index, ButtonHeight), Settor(Button, data_index))
	Scroll:SetNumValue(num)
	Scroll:HandleButtonByDataIndex(index, func, ...)			func(Button, ...)
	Scroll:HandleButtonByRawIndex(index, func, ...)				func(Button, ...)
	Scroll:CallButtonFuncByRawIndex(index, FuncName, ...)		Button:func(...)
	Scroll:CallButtonFuncByDataIndex(index, FuncName, ...)		Button:func(...)
	Button:GetDataIndex()
]]
local __version = 250401;

local _G = _G;
_G.__ala_meta__ = _G.__ala_meta__ or {  };
local __ala_meta__ = _G.__ala_meta__;

-->			versioncheck
	local __scrolllib = __ala_meta__.__scrolllib;
	if __scrolllib ~= nil and __scrolllib.__minor ~= nil and __scrolllib.__minor >= __version then
		return;
	elseif __scrolllib == nil then
		__scrolllib = {  };
		__ala_meta__.__scrolllib = __scrolllib;
	else
		if __scrolllib.Halt ~= nil then
			__scrolllib:Halt(__scrolllib.__minor);
		end
	end
	__scrolllib.__minor = __version;
	__scrolllib._Created = __scrolllib._Created or {  };

-->

local uireimp = __ala_meta__.uireimp;

-->			upvalue
	local ceil, floor = ceil, floor;
	local After = C_Timer.After;
	local _ = nil;

	local function _error_(key, msg, ...)
		print("\124cffff0000" .. key .. "\124r", msg and "\124cffff0000" .. msg .. "\124r", ...);
	end

-->			constant
	local def_inner_size = 64;

-->
	function __scrolllib.CreateScrollFrame(Parent, FrameWidth, FrameHeight, ButtonHeight, Creator, Settor)
		local ScrollFrame = CreateFrame('SCROLLFRAME', nil, Parent);
		local ScrollChild = CreateFrame('FRAME', nil, ScrollFrame);
		local ScrollBar = CreateFrame('SLIDER', nil, ScrollFrame);
		ScrollFrame.ScrollBar = ScrollBar;
		ScrollFrame.ScrollChild = ScrollChild;

		local TblButtons = {  };
		local NumButtons = 0;
		local NumShown = 0;
		local IndexOffset = 0;
		local NumValues = -1;

		local BarWidth = 12;
		local MaxValue = 0;

		ScrollFrame:Show();
		ScrollFrame:EnableMouse(true);
		ScrollFrame:SetMovable(true);
		ScrollFrame:RegisterForDrag("LeftButton");

		ScrollChild:Show();
		ScrollChild:SetPoint("LEFT", ScrollFrame);

		ScrollBar:SetWidth(BarWidth);
		ScrollBar:SetPoint("TOPRIGHT", ScrollFrame, "TOPRIGHT", 0, -2);
		ScrollBar:SetPoint("BOTTOMRIGHT", ScrollFrame, "BOTTOMRIGHT", 0, 2);
		ScrollBar:Show();
		ScrollBar:EnableMouse(true);
		uireimp._SetSimpleBackdrop(ScrollBar, -1, 1, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, 1.0);
		ScrollBar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob");
		local Thumb = ScrollBar:GetThumbTexture();
		Thumb:SetSize(BarWidth, 24);
		-- Thumb:SetTexCoord(0.20, 0.80, 0.125, 0.875);
		Thumb:SetColorTexture(0.25, 0.25, 0.25, 1.0);

		ScrollFrame:SetVerticalScroll(0);
		ScrollFrame:SetScrollChild(ScrollChild);
		ScrollFrame:SetScript("OnMouseWheel", function(self, delta, stepSize)
			stepSize = stepSize or ButtonHeight;
			local minVal, maxVal = ScrollBar:GetMinMaxValues();
			local val = ScrollBar:GetValue() - delta * stepSize;
			if val > maxVal then
				val = maxVal;
			elseif val < minVal then
				val = minVal;
			end
			ScrollBar:SetValue(val);
		end);
		function ScrollFrame:OnSizeChanged(width, height)
			width = width or ScrollFrame:GetWidth();
			height = height or ScrollFrame:GetHeight();
			ScrollChild:SetHeight(height);
			--ScrollBar:SetValue(mscrollBar:GetValue());
			ScrollChild:CreateScrollChildButtons();
			ScrollFrame:Update();
			FrameWidth = width;
			FrameHeight = height;
			if ScrollBar:IsShown() then
				ScrollBar:UpdateThumbHeight();
			end
		end
		function ScrollFrame:SetButtonHeight(height)
			if ButtonHeight == height then
				return;
			end
			ButtonHeight = height;
			ScrollFrame:OnSizeChanged();
		end
		--[=[ScrollFrame._SetSize = ScrollFrame.SetSize;
		function ScrollFrame:SetSize(...)
			ScrollFrame:_SetSize(...);
			ScrollFrame:OnSizeChanged(...);
		end
		ScrollFrame._SetHeight = ScrollFrame.SetHeight;
		function ScrollFrame:SetHeight(...)
			ScrollFrame:_SetHeight(...);
			ScrollFrame:OnSizeChange(ScrollFrame:GetWidth(), ...);
		end
		ScrollFrame._SetWidth = ScrollFrame.SetWidth;
		function ScrollFrame:SetWidth(...)
			ScrollFrame:_SetWidth(...);
			ScrollChild:SetWidth(...);
		end--]=]
		ScrollFrame:SetScript("OnSizeChanged", ScrollFrame.OnSizeChanged);
		ScrollFrame:SetScript("OnDragStart", function(self, button)
			if Parent:IsMovable() then
				Parent:StartMoving();
			end
		end);
		ScrollFrame:SetScript("OnDragStop", function(self, button)
			Parent:StopMovingOrSizing();
		end);
		ScrollFrame:SetScript("OnShow", function(self)
			ScrollFrame:Update();
		end);
		function ScrollFrame:UpdateButtons()
			if ScrollFrame:IsVisible() then
				for i = 1, NumShown do
					-- Settor(TblButtons[i], i + IndexOffset);
					After(0.0, TblButtons[i].ScopedUpdate);
				end
			end
		end
		function ScrollFrame:Update()
			if ScrollFrame:IsVisible() then
				MaxValue = NumValues * ButtonHeight - FrameHeight;
				if MaxValue < 0 then
					MaxValue = 0;
				end
				local val = ScrollBar:GetValue();
				if val > MaxValue then
					val = MaxValue;
				end
				ScrollBar:SetMinMaxValues(0, MaxValue);
				ScrollBar:SetValue(val);
				if NumShown - 1 > NumValues then
					ScrollBar:Hide();
					ScrollChild:SetWidth(ScrollFrame:GetWidth());
				else
					ScrollBar:Show();
					ScrollChild:SetWidth(ScrollFrame:GetWidth() - BarWidth - 2);
					ScrollBar:UpdateThumbHeight();
				end
				ScrollFrame:UpdateButtons();
			end
		end
		function ScrollFrame:SetNumValue(num)
			if num >= 0 and NumValues ~= num then
				NumValues = num;
				ScrollFrame:Update();
			end
		end
		function ScrollFrame:HandleButtonByDataIndex(index, func, ...)
			return ScrollFrame:HandleButtonByRawIndex(index - IndexOffset, func, ...);
		end
		function ScrollFrame:HandleButtonByRawIndex(index, func, ...)
			if index >= 1 and index <= #TblButtons then
				return func(TblButtons[index], ...);
			else
				-- _error_("HandleButtonByRawIndex", index);
				return nil;
			end
		end
		function ScrollFrame:CallButtonFuncByRawIndex(index, func, ...)
			if index >= 1 and index <= #TblButtons then
				func = TblButtons[index][func];
				if func then
					return func(TblButtons[index], ...);
				else
					_error_("CallButtonFuncByRawIndex", index);
					return nil;
				end
			else
				-- _error_("CallButtonFuncByRawIndex", index);
				return nil;
			end
			return nil;
		end
		function ScrollFrame:CallButtonFuncByDataIndex(index, func, ...)
			return ScrollFrame:CallButtonFuncByRawIndex(index - IndexOffset, func, ...);
		end
		function ScrollFrame:SetBarWidth(width)
			BarWidth = width;
			ScrollBar:SetWidth(BarWidth);
			Thumb:SetSize(BarWidth, 24);
			ScrollFrame:Update();
		end

		local function GetDataIndex(self)
			return self.id + IndexOffset;
		end
		function ScrollChild:CreateScrollChildButtons()
			local num = ceil(ScrollChild:GetHeight() / ButtonHeight) + 1;
			if num == NumShown then
				return;
			end
			if num < NumShown then
				for i = num + 1, NumShown do
					TblButtons[i]:Hide();
				end
			else
				if num > NumButtons then
					for i = NumButtons + 1, num do
						local Button = Creator(ScrollChild, i, ButtonHeight);
						Button.id = i;
						TblButtons[i] = Button;
						if i == 1 then
							Button:SetPoint("TOPLEFT");
							Button:SetPoint("TOPRIGHT");
						else
							Button:SetPoint("TOPLEFT", TblButtons[i - 1], "BOTTOMLEFT", 0, 0);
							Button:SetPoint("TOPRIGHT", TblButtons[i - 1], "BOTTOMRIGHT", 0, 0);
						end
						TblButtons[i]:Show();
						Button.GetDataIndex = GetDataIndex;
						Button.ScopedUpdate = function()
							return Settor(Button, i + IndexOffset);
						end
						NumButtons = i;
					end
				end
				for i = NumShown + 1, num do
					TblButtons[i]:Show();
				end
			end
			NumShown = num;
			-- ScrollBar:SetStepsPerPage(NumShown - 2);
		end

		ScrollBar:SetValueStep(ButtonHeight);
		ScrollBar:SetMinMaxValues(0, 0);
		ScrollBar:SetValue(0);
		ScrollBar:SetScript("OnValueChanged", function(self, value)
			value = value or ScrollBar:GetValue();
			local index = value / ButtonHeight;
			local ofs = (index % 1.0) * ButtonHeight;
			ScrollFrame:SetVerticalScroll(ofs);
			IndexOffset = index - index % 1.0;
			ScrollFrame:UpdateButtons();
		end);
		function ScrollBar:UpdateThumbHeight()
			local Total = NumValues * ButtonHeight;
			local Height = ScrollBar:GetHeight();
			local ThumbHeight = Height * FrameHeight / Total;
			if ThumbHeight < BarWidth then
				ThumbHeight = BarWidth;
			elseif ThumbHeight > Height * 0.75 then
				ThumbHeight = Height * 0.75;
				ThumbHeight = ThumbHeight - ThumbHeight % 1.0;
			end
			Thumb:SetHeight(ThumbHeight);
		end

		if FrameWidth == nil or FrameWidth < def_inner_size then
			FrameWidth = def_inner_size;
		end
		if FrameHeight == nil or FrameHeight < def_inner_size then
			FrameHeight = def_inner_size;
		end
		ScrollFrame:SetSize(FrameWidth, FrameHeight);

		ScrollFrame:SetNumValue(0);

		__scrolllib._Created[ScrollFrame] = __version;

		return ScrollFrame;
	end

-->
