item_rare_serluc_armor_mod_aura = class({})

function item_rare_serluc_armor_mod_aura:IsHidden()
    return true
end

function item_rare_serluc_armor_mod_aura:IsPurgable()
    return false
end

function item_rare_serluc_armor_mod_aura:IsAura()
	if self:GetParent():PassivesDisabled() then return false end
	if self:GetParent():IsIllusion() then return false end
	return true
end

function item_rare_serluc_armor_mod_aura:GetModifierAura()
	return "item_rare_serluc_armor_mod_effect"
end

function item_rare_serluc_armor_mod_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function item_rare_serluc_armor_mod_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function item_rare_serluc_armor_mod_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

function item_rare_serluc_armor_mod_aura:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
end

---------------------------------------------------------------------------------------------------

function item_rare_serluc_armor_mod_aura:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local passive_con = self.ability:GetSpecialValueFor("passive_con")
	local passive_mnd = self.ability:GetSpecialValueFor("passive_mnd")

	AddBonus(self.ability, "CON", self.parent, passive_con, 0, nil)
	AddBonus(self.ability, "MND", self.parent, passive_mnd, 0, nil)
end

function item_rare_serluc_armor_mod_aura:OnRefresh( kv )
end

function item_rare_serluc_armor_mod_aura:OnRemoved( kv )
	RemoveBonus(self.ability, "CON", self.parent)
	RemoveBonus(self.ability, "MND", self.parent)
end


--------------------------------------------------------------------------------------------------

function item_rare_serluc_armor_mod_aura:GetEffectName()
	return "particles/items_fx/aura_shivas.vpcf"
end

function item_rare_serluc_armor_mod_aura:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end