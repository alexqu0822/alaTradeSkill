--[[--
	by ALA @ 163UI
--]]--

local __addon_, __namespace__ = ...;


-->		****
__namespace__:BuildEnv("Leatrix_Plus");
-->		****


__namespace__:AddAddOnCallback("Leatrix_Plus", function()
	if LeaPlusDB then
		LeaPlusDB["EnhanceProfessions"] = "Off";
	end
end);

