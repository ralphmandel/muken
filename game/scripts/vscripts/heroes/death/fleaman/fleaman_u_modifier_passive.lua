fleaman_u_modifier_passive = class({})

function fleaman_u_modifier_passive:IsHidden() return false end
function fleaman_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_u_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(0) end
end

function fleaman_u_modifier_passive:OnRefresh(kv)
end

function fleaman_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function fleaman_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function fleaman_u_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
  if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:PassivesDisabled() then return end
  if self.parent:IsIllusion() then return end

  local mod_steal = keys.target:FindModifierByNameAndCaster("fleaman_u_modifier_steal", self.caster)

  if mod_steal then
    if mod_steal:GetStackCount() >= self.ability:GetSpecialValueFor("max_stack") then
      return
    end
  end

  mod_steal = AddModifier(keys.target, self.ability, "fleaman_u_modifier_steal", {
    duration = self.ability:GetSpecialValueFor("stack_duration")
  }, true)

  if IsServer() then
    self:IncrementStackCount()
    self:PlayEfxHit(keys.target)
  end
  
  local stat_modifier = AddBonus(self.ability, "STR", self.parent, 1, 0, mod_steal:GetDuration())

  stat_modifier:SetEndCallback(function(interrupted)
    if IsServer() then self:DecrementStackCount() end
  end)
end

function fleaman_u_modifier_passive:OnStackCountChanged(old)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function fleaman_u_modifier_passive:PlayEfxHit(target)
	local particle_cast = "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 1, self.caster:GetOrigin() + Vector(0, 0, 64))
  ParticleManager:SetParticleControlTransformForward(effect_cast, 3, self.parent:GetOrigin(), self.caster:GetLeftVector())
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Hero_BountyHunter.Jinada") end
end