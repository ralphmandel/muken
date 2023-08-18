icebreaker_u_modifier_aura = class({})

function icebreaker_u_modifier_aura:IsHidden() return false end
function icebreaker_u_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function icebreaker_u_modifier_aura:IsAura() return true end
function icebreaker_u_modifier_aura:GetModifierAura() return "icebreaker_u_modifier_aura_effect" end
function icebreaker_u_modifier_aura:GetAuraRadius() return self:GetParent():GetCurrentVisionRange() end
function icebreaker_u_modifier_aura:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function icebreaker_u_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function icebreaker_u_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end

function icebreaker_u_modifier_aura:GetAuraEntityReject(hEntity)
  if self:GetCaster():GetTeamNumber() == hEntity:GetTeamNumber() then
    if self:GetCaster() ~= hEntity then return true end
  end

  return self:GetParent() == hEntity
end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_u_modifier_aura:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.radius_day = self.ability:GetSpecialValueFor("radius_day")
  self.radius_night = self.ability:GetSpecialValueFor("radius_night")
  self.hits = self.ability:GetSpecialValueFor("hits") * 4
  self.min_health = self.hits

  AddBonus(self.ability, "CON", self.parent, -9999, 0, nil)

  Timers:CreateTimer(FrameTime(), function()
    self.parent:ModifyHealth(self.hits, self.ability, false, 0)
  end)

  if IsServer() then
		self:PlayEfxStart(self.parent:GetCurrentVisionRange())
		self:OnIntervalThink()
	end
end

function icebreaker_u_modifier_aura:OnRefresh(kv)
end

function icebreaker_u_modifier_aura:OnRemoved()
  if IsServer() then
		self.parent:StopSound("Hero_Icebreaker.Zero.Loop")
		self.parent:EmitSound("Ability.FrostNova")
	end

  RemoveBonus(self.ability, "CON", self.parent)

  if self.parent:IsAlive() then self.parent:ForceKill(false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_u_modifier_aura:CheckState()
	local state = {
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
		[MODIFIER_STATE_EVADE_DISABLED] = true
	}

	return state
end

function icebreaker_u_modifier_aura:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTHBAR_PIPS,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    MODIFIER_PROPERTY_VISUAL_Z_DELTA,
    MODIFIER_PROPERTY_BONUS_DAY_VISION,
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}

	return funcs
end

function icebreaker_u_modifier_aura:GetModifierHealthBarPips(keys)
	return self:GetParent():GetMaxHealth() / 4
end

function icebreaker_u_modifier_aura:OnDeath(keys)
	if keys.unit == self.parent then self:Destroy() end
end

function icebreaker_u_modifier_aura:OnAttacked(keys)
	if keys.target ~= self.parent then return end
  self.min_health = self.min_health - GetPipHitDamage(keys.attacker)
end

function icebreaker_u_modifier_aura:GetDisableHealing()
	return 1
end

function icebreaker_u_modifier_aura:GetMinHealth()
	return self.min_health
end

function icebreaker_u_modifier_aura:GetModifierExtraHealthBonus()
	return self.hits - 1
end

function icebreaker_u_modifier_aura:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("ms_limit")
end

function icebreaker_u_modifier_aura:GetVisualZDelta()
	return 350
end

function icebreaker_u_modifier_aura:GetBonusDayVision()
	return self.radius_day
end

function icebreaker_u_modifier_aura:GetBonusNightVision()
	return self.radius_night
end

function icebreaker_u_modifier_aura:OnIntervalThink()
	local radius = self.parent:GetCurrentVisionRange()
	if self.efx then ParticleManager:SetParticleControl(self.efx, 1, Vector(radius, radius, radius * (radius * 0.002))) end

	if IsServer() then self:StartIntervalThink(1 / (radius * 0.01)) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function icebreaker_u_modifier_aura:GetEffectName()
	return "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf"
end

function icebreaker_u_modifier_aura:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker_u_modifier_aura:PlayEfxStart(radius)
	local particle_1 = "particles/icebreaker/icebreaker_zero.vpcf"

	self.efx = ParticleManager:CreateParticle(particle_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.efx, 1, Vector(radius, radius, radius * (radius * 0.002)))
	self:AddParticle(self.efx, false, false, -1, false, false)

	local particle_cast = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ambient.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then
		self.parent:EmitSound("Hero_Ancient_Apparition.ColdFeetCast")
		self.parent:EmitSound("Hero_Icebreaker.Zero.Loop")
	end
end