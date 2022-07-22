striker_6_modifier_sof = class({})

function striker_6_modifier_sof:IsHidden()
	return false
end

function striker_6_modifier_sof:IsPurgable()
	return false
end

function striker_6_modifier_sof:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_6_modifier_sof:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

function striker_6_modifier_sof:OnRefresh(kv)
end

function striker_6_modifier_sof:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_6_modifier_sof:OnIntervalThink()
	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function striker_6_modifier_sof:GetEffectName()
	return "particles/econ/items/spectre/spectre_arcana/spectre_arcana_radiance_owner_body.vpcf"
end

function striker_6_modifier_sof:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end