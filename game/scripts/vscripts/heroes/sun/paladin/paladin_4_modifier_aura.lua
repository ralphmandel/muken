paladin_4_modifier_aura = class({})

function paladin_4_modifier_aura:IsHidden() return false end
function paladin_4_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function paladin_4_modifier_aura:IsAura() return true end
function paladin_4_modifier_aura:GetModifierAura() return "paladin_4_modifier_aura_effect" end
function paladin_4_modifier_aura:GetAuraRadius() return self.radius end
function paladin_4_modifier_aura:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function paladin_4_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function paladin_4_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_4_modifier_aura:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.radius = self.ability:GetAOERadius()
  self.interval = self.ability:GetSpecialValueFor("interval")
  
  if IsServer() then
    self:StartIntervalThink(self.interval)
    self:PlayEfxStart()
  end
end

function paladin_4_modifier_aura:OnRefresh(kv)
end

function paladin_4_modifier_aura:OnRemoved()
  if IsServer() then self.parent:StopSound("Hero_ArcWarden.MagneticField") end
end

-- API FUNCTIONS -----------------------------------------------------------

function paladin_4_modifier_aura:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

-- function paladin_4_modifier_aura:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
-- 		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
-- 		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
-- 	}

-- 	return funcs
-- end

-- function paladin_4_modifier_aura:GetAbsoluteNoDamagePhysical(keys)
--   if keys.attacker:HasModifier("paladin_4_modifier_aura_effect") then return 1 end
--   return 0
-- end

-- function paladin_4_modifier_aura:GetAbsoluteNoDamageMagical(keys)
--   if keys.attacker:HasModifier("paladin_4_modifier_aura_effect") then return 1 end
--   return 0
-- end

-- function paladin_4_modifier_aura:GetAbsoluteNoDamagePure(keys)
--   if keys.attacker:HasModifier("paladin_4_modifier_aura_effect") then return 1 end
--   return 0
-- end 

function paladin_4_modifier_aura:OnIntervalThink()
  if IsServer() then self.parent:EmitSound("Paladin.Magnus.Hit") end

  ApplyDamage({
    victim = self.parent, attacker = self.caster,
    damage = self.caster:GetMaxHealth() * self.ability:GetSpecialValueFor("damage_percent") * self.interval * 0.01,
    damage_type = self.ability:GetAbilityDamageType(),
    ability = self.ability, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
  })
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function paladin_4_modifier_aura:PlayEfxStart()
	local particle_cast = "particles/paladin/cross_magnus/paladin_cross_magnus.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self.radius, self.radius, self.radius))
	self:AddParticle(self.effect_cast, false, false, -1, true, false)

  if IsServer() then self.parent:EmitSound("Hero_ArcWarden.MagneticField") end
end