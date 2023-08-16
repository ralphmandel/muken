hunter_5_modifier_trap_invi = class({})

function hunter_5_modifier_trap_invi:IsHidden() return true end
function hunter_5_modifier_trap_invi:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_5_modifier_trap_invi:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("delay")) end
end

function hunter_5_modifier_trap_invi:OnRefresh(kv)
end

function hunter_5_modifier_trap_invi:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------


function hunter_5_modifier_trap_invi:OnIntervalThink()
  self:PlayEfxHide()
  AddModifier(self.parent, self.ability, "_modifier_invisible", {}, false)
  self:Destroy()
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function hunter_5_modifier_trap_invi:PlayEfxHide()
	local particle_cast = "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_missile_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin() )
  ParticleManager:ReleaseParticleIndex(effect_cast)


  if IsServer() then self.parent:EmitSound("Hunter.Invi") end
end