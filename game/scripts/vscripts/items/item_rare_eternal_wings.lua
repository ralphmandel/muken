item_rare_eternal_wings = class({})
LinkLuaModifier("item_rare_eternal_wings_mod_passive", "items/item_rare_eternal_wings_mod_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_rare_eternal_wings_mod_buff", "items/item_rare_eternal_wings_mod_buff", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------

function item_rare_eternal_wings:GetIntrinsicModifierName()
	return "item_rare_eternal_wings_mod_passive"
end