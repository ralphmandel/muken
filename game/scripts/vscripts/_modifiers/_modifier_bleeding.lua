_modifier_bleeding = class({})

function _modifier_bleeding:IsHidden() return false end
function _modifier_bleeding:IsPurgable() return true end
function _modifier_bleeding:GetTexture() return "bleeding" end
function _modifier_bleeding:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function _modifier_bleeding:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then
		self:StartIntervalThink(0.3)
		self:PlayEfxStart()
	end
end

function _modifier_bleeding:OnRefresh(kv)
	if IsServer() then self:PlayEfxStart() end
end

function _modifier_bleeding:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function _modifier_bleeding:OnIntervalThink()
  local damage = 0
  if self.parent:IsMoving() then damage = 30 else damage = 10 end

  ApplyDamage({
		victim = self.parent,
		attacker = self.caster,
    ability = self.ability,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
		damage_flags = DOTA_DAMAGE_FLAG_DONT_DISPLAY_DAMAGE_IF_SOURCE_HIDDEN
	})

  if IsServer() then self:StartIntervalThink(0.3) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function _modifier_bleeding:GetEffectName()
	return "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf"
end

function _modifier_bleeding:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function _modifier_bleeding:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)

	local particle_cast2 = "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok.vpcf"
	local effect_cast2 = ParticleManager:CreateParticle(particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast2, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast2, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast2)

	if IsServer() then self.parent:EmitSound("Generic.Bleed") end
end