paladin_2_modifier_shield = class({})

function paladin_2_modifier_shield:IsHidden() return false end
function paladin_2_modifier_shield:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_2_modifier_shield:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then
		self:SetStackCount(self.ability:GetSpecialValueFor("hits"))
		self:PlayEfxStart()
	end
end

function paladin_2_modifier_shield:OnRefresh(kv)
  if IsServer() then
		self:SetStackCount(self.ability:GetSpecialValueFor("hits"))
		self:PlayEfxStart()
	end
end

function paladin_2_modifier_shield:OnRemoved()
	if IsServer() then self.parent:EmitSound("Hero_Medusa.ManaShield.Off") end
end

-- API FUNCTIONS -----------------------------------------------------------

function paladin_2_modifier_shield:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}

	return funcs
end

function paladin_2_modifier_shield:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	self:DecrementStackCount()
end

function paladin_2_modifier_shield:GetModifierPhysical_ConstantBlock(keys)
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end

  self:PlayEfxBlocked(keys)

	if self:GetStackCount() < 1 then self:Destroy() end

  return keys.damage * (100 - self.ability:GetSpecialValueFor("reduction")) * 0.01
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function paladin_2_modifier_shield:PlayEfxStart()
  if self.shield_particle then ParticleManager:DestroyParticle(self.shield_particle, true) end

  local string = "particles/econ/items/lanaya/ta_ti9_immortal_shoulders/ta_ti9_refraction.vpcf"
	self.shield_particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.shield_particle, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
  ParticleManager:SetParticleControlEnt(self.shield_particle, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
  ParticleManager:SetParticleControlEnt(self.shield_particle, 5, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	self:AddParticle(self.shield_particle, false, false, -1, true, false)

  if IsServer() then self.parent:EmitSound("Hero_TemplarAssassin.Refraction") end
end

function paladin_2_modifier_shield:PlayEfxBlocked(keys)
	local particle_cast = "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(keys.damage, 0, 0 ))
	ParticleManager:ReleaseParticleIndex(effect_cast)

  if IsServer() then self.parent:EmitSound("Hero_Striker.Shield.Block") end
end