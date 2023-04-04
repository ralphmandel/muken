item_rare_killer_dagger = class({})
LinkLuaModifier("item_rare_killer_dagger_mod_passive", "items/item_rare_killer_dagger_mod_passive", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------

function item_rare_killer_dagger:GetIntrinsicModifierName()
	return "item_rare_killer_dagger_mod_passive"
end