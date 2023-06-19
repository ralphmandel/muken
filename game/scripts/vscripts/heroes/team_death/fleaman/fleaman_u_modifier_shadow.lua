fleaman_u_modifier_shadow = class({})

function fleaman_u_modifier_shadow:IsHidden() return true end
function fleaman_u_modifier_shadow:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_u_modifier_shadow:OnCreated(kv)
	self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddModifier(self.parent, self.caster, self.ability, "_modifier_invisible", {
    delay = 1, attack_break = 0
  }, false)

	if IsServer() then
		self:PlayEfxStart()
		self:OnIntervalThink()
	end
end

function fleaman_u_modifier_shadow:OnRefresh(kv)
end

function fleaman_u_modifier_shadow:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_invisible", self.ability)
  if IsServer() then self.parent:StopSound("Fleaman.Shadow.Start") end
end

-- API FUNCTIONS -----------------------------------------------------------

function fleaman_u_modifier_shadow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}

	return funcs
end

function fleaman_u_modifier_shadow:GetActivityTranslationModifiers()
	return "shadow_dance"
end

function fleaman_u_modifier_shadow:OnIntervalThink()
	if self.effect_cast then ParticleManager:SetParticleControl(self.effect_cast, 1, self.parent:GetOrigin()) end
	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function fleaman_u_modifier_shadow:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_slark/slark_shadow_dance.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 3, self.parent, PATTACH_POINT_FOLLOW, "attach_eyeR", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 4, self.parent, PATTACH_POINT_FOLLOW, "attach_eyeL", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

	local particle_cast_2 = "particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf"
	local effect_cast_1 = ParticleManager:CreateParticle(particle_cast_2, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast_1, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast_1, 1, self.parent:GetOrigin())
	self:AddParticle(effect_cast_1, false, false, -1, false, false)

	self.effect_cast = effect_cast_1
	if IsServer() then self.parent:EmitSound("Fleaman.Shadow.Start") end
end