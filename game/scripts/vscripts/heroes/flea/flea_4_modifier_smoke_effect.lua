flea_4_modifier_smoke_effect = class({})

function flea_4_modifier_smoke_effect:IsHidden() return true end
function flea_4_modifier_smoke_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_4_modifier_smoke_effect:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then
		if self.parent == self.caster then
			self.parent:RemoveModifierByNameAndCaster("flea_4_modifier_shadow", self.caster)
		else
			self:ApplyDebuff()
		end
	end
end

function flea_4_modifier_smoke_effect:OnRefresh(kv)
end

function flea_4_modifier_smoke_effect:OnRemoved()
	local shadow_duration = self.ability:GetSpecialValueFor("special_shadow_duration")

	if shadow_duration > 0 and self.parent == self.caster then
		self.parent:AddNewModifier(self.caster, self.ability, "flea_4_modifier_shadow", {
			duration = CalcStatus(shadow_duration, self.parent, self.parent)
		})
	end

  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_blind", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_debuff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

function flea_4_modifier_smoke_effect:ApplyDebuff()
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = self.ability:GetSpecialValueFor("blind")})
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = self.ability:GetSpecialValueFor("slow")})
end

-- EFFECTS -----------------------------------------------------------

function flea_4_modifier_smoke_effect:PlayEfxStart()
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