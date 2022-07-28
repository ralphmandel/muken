krieger_1_modifier_fury = class({})

function krieger_1_modifier_fury:IsHidden()
	return true
end

function krieger_1_modifier_fury:IsPurgable()
	return true
end

function krieger_1_modifier_fury:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function krieger_1_modifier_fury:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local agi = self.ability:GetSpecialValueFor("agi")

	self.ability:AddBonus("_1_AGI", self.parent, agi, 0, nil)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "krieger_1_modifier_fury_status_efx", true) end

	if IsServer() then self.parent:EmitSound("Hero_Sven.GodsStrength") end
end

function krieger_1_modifier_fury:OnRefresh(kv)
end

function krieger_1_modifier_fury:OnRemoved()
	self.ability:RemoveBonus("_1_AGI", self.parent)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "krieger_1_modifier_fury_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function krieger_1_modifier_fury:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_debuff.vpcf"
end

function krieger_1_modifier_fury:GetEffectAttachType()
	return PATTACH_ABSORIGIN
end

function krieger_1_modifier_fury:GetStatusEffectName()
	return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf"
end

function krieger_1_modifier_fury:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end