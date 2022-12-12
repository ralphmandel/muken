druid_4_modifier_strength = class({})

function druid_4_modifier_strength:IsHidden()
	return false
end

function druid_4_modifier_strength:IsPurgable()
	return true
end

function druid_4_modifier_strength:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_4_modifier_strength:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(1) end
end

function druid_4_modifier_strength:OnRefresh(kv)
	if IsServer() then self:IncrementStackCount() end
end

function druid_4_modifier_strength:OnRemoved()
	RemoveBonus(self.ability, "_1_STR", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_4_modifier_strength:OnStackCountChanged(old)
    if self:GetStackCount() > 0 then
		RemoveBonus(self.ability, "_1_STR", self.parent)
		AddBonus(self.ability, "_1_STR", self.parent, self:GetStackCount(), 0, nil)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_4_modifier_strength:GetEffectName()
	return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
end

function druid_4_modifier_strength:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
