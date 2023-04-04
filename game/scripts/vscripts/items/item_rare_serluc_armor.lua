item_rare_serluc_armor = class({})
LinkLuaModifier("item_rare_serluc_armor_mod_aura", "items/item_rare_serluc_armor_mod_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_rare_serluc_armor_mod_effect", "items/item_rare_serluc_armor_mod_effect", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------

function item_rare_serluc_armor:GetIntrinsicModifierName()
	return "item_rare_serluc_armor_mod_aura"
end