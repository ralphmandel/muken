druid_4_modifier_strenght = class({})

function druid_4_modifier_strenght:IsHidden()
	return false
end

function druid_4_modifier_strenght:IsPurgable()
	return true
end

function druid_4_modifier_strenght:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_4_modifier_strenght:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(1) end
end

function druid_4_modifier_strenght:OnRefresh(kv)
	if IsServer() then self:IncrementStackCount() end
end

function druid_4_modifier_strenght:OnRemoved()
	self.ability:RemoveBonus("_1_STR", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_4_modifier_strenght:OnStackCountChanged(old)
    if self:GetStackCount() > 0 then
		self.ability:RemoveBonus("_1_STR", self.parent)
		self.ability:AddBonus("_1_STR", self.parent, self:GetStackCount(), 0, nil)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_4_modifier_strenght:GetEffectName()
	return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
end

function druid_4_modifier_strenght:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
