item_potion_defense = class({})
LinkLuaModifier("item_potion_defense_modifier", "items/item_potion_defense_modifier", LUA_MODIFIER_MOTION_NONE)

function item_potion_defense:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	--caster:RemoveModifierByName("item_potion_defense_modifier")
	caster:RemoveModifierByName("item_potion_heal_modifier")
	caster:RemoveModifierByName("item_potion_recover_modifier")
	caster:RemoveModifierByName("item_potion_resistance_modifier")
	caster:RemoveModifierByName("item_potion_speed_modifier")
	caster:RemoveModifierByName("item_potion_strenght_modifier")

	caster:AddNewModifier(caster, self, "item_potion_defense_modifier", {duration = duration})
	if IsServer() then caster:EmitSound("DOTA_Item.HealingSalve.Activate") end

	self:StartCooldown(duration)
	self:SetDroppable(false)
	self:SetActivated(false)
end