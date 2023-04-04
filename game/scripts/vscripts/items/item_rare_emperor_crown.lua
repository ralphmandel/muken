item_rare_emperor_crown = class({})
LinkLuaModifier("item_rare_emperor_crown_mod_passive", "items/item_rare_emperor_crown_mod_passive", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------

function item_rare_emperor_crown:GetIntrinsicModifierName()
	return "item_rare_emperor_crown_mod_passive"
end