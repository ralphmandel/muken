genuine_u_modifier_curse = class({})

function genuine_u_modifier_curse:IsHidden() return false end
function genuine_u_modifier_curse:IsPurgable() return false end
function genuine_u_modifier_curse:RemoveOnDeath() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_u_modifier_curse:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then
    self:PlayEfxStart()
    --self:OnIntervalThink()
  end
end

function genuine_u_modifier_curse:OnRefresh(kv)
end

function genuine_u_modifier_curse:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_u_modifier_curse:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
	}
	return funcs
end

function genuine_u_modifier_curse:GetBonusVisionPercentage()
	return self:GetAbility():GetSpecialValueFor("vision_reduction")
end

function genuine_u_modifier_curse:OnIntervalThink()
  if IsServer() then
    self:PlayEfxInterval()
    self:StartIntervalThink(3)
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function genuine_u_modifier_curse:PlayEfxStart()
	local particle = "particles/genuine/genuine_ultimate.vpcf"
  local effect_target = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_target, 0, self.parent:GetOrigin())
	self:AddParticle(effect_target, false, false, -1, false, false)

	--if IsServer() then self.parent:EmitSound("Genuine.Curse.Loop") end
end

function genuine_u_modifier_curse:PlayEfxInterval()
	local particle_cast = "particles/genuine/ult_deny/genuine_deny_v2.vpcf"
  local effect_target = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_target, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_target, 1, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_target)
end