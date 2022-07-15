genuine_4_modifier_aura_effect = class({})

function genuine_4_modifier_aura_effect:IsHidden()
	return false
end

function genuine_4_modifier_aura_effect:IsPurgable()
	return false
end

function genuine_4_modifier_aura_effect:IsDebuff()
	return true
end

-----------------------------------------------------------

function genuine_4_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local res = self.ability:GetSpecialValueFor("res")

	-- UP 4.41
	if self.ability:GetRank(41) then
		res = res + 10
	end

	self.ability:AddBonus("_2_RES", self.parent, -res, 0, nil)
end

function genuine_4_modifier_aura_effect:OnRefresh(kv)
end

function genuine_4_modifier_aura_effect:OnRemoved(kv)
	self.ability:RemoveBonus("_2_RES", self.parent)
end

-----------------------------------------------------------

function genuine_4_modifier_aura_effect:GetEffectName()
	return "particles/econ/events/ti9/radiance_ti9.vpcf"
end

function genuine_4_modifier_aura_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end