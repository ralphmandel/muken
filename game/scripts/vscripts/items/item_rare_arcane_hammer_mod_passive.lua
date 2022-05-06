item_rare_arcane_hammer_mod_passive = class({})

function item_rare_arcane_hammer_mod_passive:IsHidden()
    return true
end

function item_rare_arcane_hammer_mod_passive:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_rare_arcane_hammer_mod_passive:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local passive_int = self.ability:GetSpecialValueFor("passive_int")
	self.passive_mana = self.ability:GetSpecialValueFor("passive_mana")

	self.ability:AddBonus("_1_INT", self.parent, passive_int, 0, nil)
end

function item_rare_arcane_hammer_mod_passive:OnRefresh( kv )
end

function item_rare_arcane_hammer_mod_passive:OnRemoved( kv )
	self.ability:RemoveBonus("_1_INT", self.parent)
end

---------------------------------------------------------------------------------------------------

function item_rare_arcane_hammer_mod_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_BONUS
	}

	return funcs
end

function item_rare_arcane_hammer_mod_passive:GetModifierManaBonus()
	return self.passive_mana
end