templar_2_modifier_barrier = class({})

function templar_2_modifier_barrier:IsHidden() return false end
function templar_2_modifier_barrier:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function templar_2_modifier_barrier:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:PlayEfxStart() end
end

function templar_2_modifier_barrier:OnRefresh(kv)
end

function templar_2_modifier_barrier:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function templar_2_modifier_barrier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
	}

	return funcs
end

function templar_2_modifier_barrier:GetAbsoluteNoDamagePhysical(keys)
  return 1
end

function templar_2_modifier_barrier:GetAbsoluteNoDamageMagical(keys)
  return 1
end

function templar_2_modifier_barrier:GetAbsoluteNoDamagePure(keys)
  return 1
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function templar_2_modifier_barrier:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_halo_buff.vpcf"
end

function templar_2_modifier_barrier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function templar_2_modifier_barrier:PlayEfxStart()  
  local particle = "particles/econ/items/omniknight/omni_2021_immortal/omni_2021_immortal.vpcf"
  local efx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:SetParticleControl(efx, 0, self.parent:GetOrigin())
  self:AddParticle(efx, false, false, -1, true, false)

  if IsServer() then self.parent:EmitSound("Hero_Omniknight.GuardianAngel.Cast") end
end