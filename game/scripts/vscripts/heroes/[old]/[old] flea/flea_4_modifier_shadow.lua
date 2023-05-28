flea_4_modifier_shadow = class({})

function flea_4_modifier_shadow:IsHidden() return false end
function flea_4_modifier_shadow:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_4_modifier_shadow:OnCreated(kv)
	self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.parent:AddNewModifier(self.caster, self.ability, "flea_4_modifier_invisible", {duration = self:GetDuration()})

	if IsServer() then
		self:PlayEfxStart()
		self:OnIntervalThink()
	end
end

function flea_4_modifier_shadow:OnRefresh(kv)
	if IsServer() then self.parent:EmitSound("DOTA_Item.InvisibilitySword.Activate") end
end

function flea_4_modifier_shadow:OnRemoved()
	self.parent:RemoveModifierByName("flea_4_modifier_invisible")
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_4_modifier_shadow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}

	return funcs
end

function flea_4_modifier_shadow:GetActivityTranslationModifiers()
	return "shadow_dance"
end

function flea_4_modifier_shadow:OnIntervalThink()
	if self.effect_cast then ParticleManager:SetParticleControl(self.effect_cast, 1, self.parent:GetOrigin()) end
	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function flea_4_modifier_shadow:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_slark/slark_shadow_dance.vpcf"
	local effect_cast = ParticleManager:CreateParticleForTeam(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent, self.parent:GetTeamNumber())
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 3, self.parent, PATTACH_POINT_FOLLOW, "attach_eyeR", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 4, self.parent, PATTACH_POINT_FOLLOW, "attach_eyeL", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

	local particle_cast_2 = "particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf"
	local effect_cast_1 = ParticleManager:CreateParticle(particle_cast_2, PATTACH_WORLDORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast_1, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast_1, 1, self.parent:GetOrigin())
	self:AddParticle(effect_cast_1, false, false, -1, false, false)

	self.effect_cast = effect_cast_1
	if IsServer() then self.parent:EmitSound("DOTA_Item.InvisibilitySword.Activate") end
end