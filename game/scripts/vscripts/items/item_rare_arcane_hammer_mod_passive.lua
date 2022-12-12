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
	AddBonus(self.ability, "_1_INT", self.parent, passive_int, 0, nil)
	self.ability:SetFrozenCooldown(false)
end

function item_rare_arcane_hammer_mod_passive:OnRefresh( kv )
end

function item_rare_arcane_hammer_mod_passive:OnRemoved( kv )
	RemoveBonus(self.ability, "_1_INT", self.parent)
	self.ability:SetFrozenCooldown(true)
end

---------------------------------------------------------------------------------------------------