--[[--
	by ALA @ 163UI
--]]--

--[==[

--	must
	function mod.F_QueryPriceByID(id, num)				return AHPrice;			--	nilable			--	must
	alias	mod.query_ah_price_by_id

	function mod.F_QueryPriceByName(name, num)			return AHPrice;			--	nilable			--	nouses
	alias	mod.query_ah_price_by_name

--	optional
	function mod.F_OnDBUpdate(callback)					--	callback when price of new item add or refresh
	alias	mod.add_cache_callback

	function mod.F_QueryNameByID(id)					return name;			--	nilable
	alias	mod.query_name_by_id

	function mod.F_QueryQualityByID(id)					return quality;			--	nilable
	alias	mod.query_quality_by_id


--	optional and built-in defualt method
	function mod.F_QueryVendorPriceByLink(link, num)	return VendorPrice;		--	nilable
	alias	mod.get_material_vendor_price_by_link

	function mod.F_QueryVendorPriceByID(id, num)		return VendorPrice;		--	nilable
	alias	mod.get_material_vendor_price_by_id

	function mod.F_QueryVendorPriceByName(name, num)	return VendorPrice;		--	nilable
	alias	mod.get_material_vendor_price_by_name


	function mod.F_GetMoneyString(copper)				return string;			--	"%d%s %02d%s %02d%s"	"%d%s %02d%s"	"%d%s"
	alias	mod.MoneyString

]==]
