bloodstained_u_modifier_seal = class({})

function bloodstained_u_modifier_seal:IsHidden() return true end
function bloodstained_u_modifier_seal:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function bloodstained_u_modifier_seal:IsAura() return true end
function bloodstained_u_modifier_seal:GetModifierAura() return "bloodstained_u_modifier_aura_effect" end
function bloodstained_u_modifier_seal:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function bloodstained_u_modifier_seal:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function bloodstained_u_modifier_seal:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function bloodstained_u_modifier_seal:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_u_modifier_seal:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
		
		self.ability:SetActivated(false)

	if IsServer() then self:PlayEfxStart() end
end

function bloodstained_u_modifier_seal:OnRefresh(kv)
end

function bloodstained_u_modifier_seal:OnRemoved()
	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end
	if IsServer() then self.parent:StopSound("bloodstained.seal") end

	self.ability:SetActivated(true)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained_u_modifier_seal:PlayEfxStart()
	local point = self.parent:GetAbsOrigin()
	point.z = point.z - 2

	local particle_cast = "particles/bloodstained/bloodstained_u_bubbles.vpcf"
  self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, point)

	local particle_cast_2 = "particles/bloodstained/bloodstained_field_replica.vpcf"
  local effect_cast_2 = ParticleManager:CreateParticle(particle_cast_2, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast_2, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(effect_cast_2, 10, Vector(self:GetDuration(), 0, 0))

	local particle_cast_3 = "particles/bloodstained/bloodstained_seal_impact.vpcf"
  local effect_cast_3 = ParticleManager:CreateParticle(particle_cast_3, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast_3, 0, self.parent:GetOrigin())

	local particle_cast_4 = "particles/bloodstained/bloodstained_seal_war.vpcf"
  local effect_cast_4 = ParticleManager:CreateParticle(particle_cast_4, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast_4, 0, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound("bloodstained.seal") end
end