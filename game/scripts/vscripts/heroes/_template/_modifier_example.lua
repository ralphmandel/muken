_modifier_example = class({})

function _modifier_example:IsHidden()
	return true
end

function _modifier_example:IsPurgable()
	return false
end

function _modifier_example:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function _modifier_example:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.ability:AddBonus("_1_AGI", self.parent, value, 0, nil)
end

function _modifier_example:OnRefresh(kv)
end

function _modifier_example:OnRemoved()
	self.ability:RemoveBonus("_1_AGI", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function _modifier_example:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true
	}

	return state
end

function _modifier_example:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function _modifier_example:OnAttackLanded(keys)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function _modifier_example:GetStatusEffectName()
    return ""
end

function _modifier_example:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function _modifier_example:GetEffectName()
	return ""
end

function _modifier_example:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function _modifier_example:PlayEfxStart(target)
	-- RELEASE PARTICLE
	local string_1 = ""
	local particle_1 = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_1, 0, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle_1)

	-- MOD PARTICLE
	local string_2 = ""
	local particle_2 = ParticleManager:CreateParticle(string_2, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(particle_2, 0, target:GetOrigin())
	self:AddParticle(particle_2, false, false, -1, false, false)

	if IsServer() then target:EmitSound("") end
end