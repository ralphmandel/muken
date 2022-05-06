item_rare_mystic_brooch_mod_passive = class({})

function item_rare_mystic_brooch_mod_passive:IsHidden()
    return true
end

function item_rare_mystic_brooch_mod_passive:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_rare_mystic_brooch_mod_passive:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local passive_dex = self.ability:GetSpecialValueFor("passive_dex")
	local passive_mnd = self.ability:GetSpecialValueFor("passive_mnd")

	self.ability:AddBonus("_2_DEX", self.parent, passive_dex, 0, nil)
	self.ability:AddBonus("_2_MND", self.parent, passive_mnd, 0, nil)
	self.regen = 0
end

function item_rare_mystic_brooch_mod_passive:OnRefresh( kv )
end

function item_rare_mystic_brooch_mod_passive:OnRemoved( kv )
	self.ability:RemoveBonus("_2_DEX", self.parent)
	self.ability:RemoveBonus("_2_MND", self.parent)
end

---------------------------------------------------------------------------------------------------

function item_rare_mystic_brooch_mod_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function item_rare_mystic_brooch_mod_passive:GetModifierConstantHealthRegen()
    return self.regen
end

function item_rare_mystic_brooch_mod_passive:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	self.regen = self.ability:GetSpecialValueFor("regen")
	self:StartIntervalThink(-1)
	self:StartIntervalThink(3)
end

function item_rare_mystic_brooch_mod_passive:OnIntervalThink()
	self.regen = 0
	self:StartIntervalThink(-1)
end