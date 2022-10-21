--[[--
	by ALA @ 163UI
--]]--

local __addon, __private = ...;


-->		****
__private:BuildEnv("Leatrix_Plus");
-->		****


__private:AddAddOnCallback("Leatrix_Plus", function()
	if LeaPlusDB ~= nil then
		LeaPlusDB["EnhanceProfessions"] = "Off";
	end
	__private.F_uiFrameFixSkillList();
end);

