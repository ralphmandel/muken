_modifier_example = class({})

function _modifier_example:IsHidden() return true end
function _modifier_example:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function _modifier_example:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	AddBonus(self.ability, "_1_AGI", self.parent, value, 0, nil)
end

function _modifier_example:OnRefresh(kv)
end

function _modifier_example:OnRemoved()
	RemoveBonus(self.ability, "_1_AGI", self.parent)
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

function _modifier_example:PlayEfxStart()
	-- RELEASE PARTICLE
	local string = ""
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	-- MOD PARTICLE
	local string = ""
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	self:AddParticle(particle, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("") end
end