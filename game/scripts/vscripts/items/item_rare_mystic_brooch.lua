item_rare_mystic_brooch = class({})
LinkLuaModifier("item_rare_mystic_brooch_mod_passive", "items/item_rare_mystic_brooch_mod_passive", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------

function item_rare_mystic_brooch:GetIntrinsicModifierName()
	return "item_rare_mystic_brooch_mod_passive"
end