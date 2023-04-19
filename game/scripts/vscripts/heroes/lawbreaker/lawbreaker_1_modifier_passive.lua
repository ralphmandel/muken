lawbreaker_1_modifier_passive = class({})

function lawbreaker_1_modifier_passive:IsHidden() return false end
function lawbreaker_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:SetStackCount(0) end
end

function lawbreaker_1_modifier_passive:OnRefresh(kv)
end

function lawbreaker_1_modifier_passive:OnRemoved()
	
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function lawbreaker_1_modifier_passive:OnAttackLanded(keys)
  if keys.attacker ~= self.parent then return end
  if self.parent:PassivesDisabled() then return end
  if IsServer() then self:IncrementStackCount() end

  if self:GetStackCount() == self.ability:GetSpecialValueFor("max_hit") - 1 then
    BaseStats(self.parent):SetForceCrit(100, nil)
  end
end

function lawbreaker_1_modifier_passive:OnStackCountChanged(old)
  if self:GetStackCount() == self.ability:GetSpecialValueFor("max_hit") then 
    if IsServer() then self:SetStackCount(0) end
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function lawbreaker_1_modifier_passive:GetStatusEffectName()
  return ""
end

function lawbreaker_1_modifier_passive:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function lawbreaker_1_modifier_passive:GetEffectName()
	return ""
end

function lawbreaker_1_modifier_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function lawbreaker_1_modifier_passive:PlayEfxStart()
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