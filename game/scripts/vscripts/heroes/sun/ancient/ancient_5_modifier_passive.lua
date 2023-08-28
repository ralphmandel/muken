ancient_5_modifier_passive = class({})

function ancient_5_modifier_passive:IsHidden() return true end
function ancient_5_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_5_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function ancient_5_modifier_passive:OnRefresh(kv)
end

function ancient_5_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_5_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
	}
	
	return funcs
end

function ancient_5_modifier_passive:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_regen")
end

function ancient_5_modifier_passive:GetModifierHPRegenAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("regen_percent")
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function ancient_5_modifier_passive:GetEffectName()
	return "particles/ancient/flesh/ancient_flesh_lvl2.vpcf"
end

function ancient_5_modifier_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end