hunter_u_modifier_camouflage = class({})

function hunter_u_modifier_camouflage:IsHidden() return false end
function hunter_u_modifier_camouflage:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_u_modifier_camouflage:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.delay = false

  AddModifierOnAllCosmetics(self.parent, self.ability, "_modifier_invi_level", {level = 1})

  if IsServer() then
    self:SetEfxCamouflage(true)
    self:StartIntervalThink(0.1)
  end
end

function hunter_u_modifier_camouflage:OnRefresh(kv)
end

function hunter_u_modifier_camouflage:OnRemoved()
  RemoveModifierOnAllCosmetics(self.parent, self.ability, "_modifier_invi_level")
end

function hunter_u_modifier_camouflage:OnDestroy(kv)
  if self.endCallback then self.endCallback(self.interrupted) end
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_u_modifier_camouflage:CheckState()
	local state = {
    [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
    [MODIFIER_STATE_NO_HEALTH_BAR_FOR_ENEMIES] = true
	}

	return state
end

function hunter_u_modifier_camouflage:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    MODIFIER_PROPERTY_BONUS_DAY_VISION,
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    MODIFIER_EVENT_ON_ATTACK_START,
    MODIFIER_EVENT_ON_STATE_CHANGED
	}

	return funcs
end

function hunter_u_modifier_camouflage:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("limit_speed")
end

function hunter_u_modifier_camouflage:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("vision_range")
end

function hunter_u_modifier_camouflage:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("vision_range")
end

function hunter_u_modifier_camouflage:GetModifierAttackRangeBonus()
  return self:GetAbility():GetSpecialValueFor("atk_range")
end

function hunter_u_modifier_camouflage:OnAttackStart(keys)
  if keys.attacker ~= self.parent then return end
  AddModifier(keys.target, self.ability, "_modifier_no_vision_attacker", {duration = 0.5}, false)
end

function hunter_u_modifier_camouflage:OnStateChanged(keys)
  if keys.unit ~= self.parent then return end
  if self.parent:PassivesDisabled() then self:Destroy() end
end

function hunter_u_modifier_camouflage:OnIntervalThink()
  local interval = 0.1

  if HasTreeNearby(self.parent:GetOrigin(), 150) == false then
    if self.delay == true then
      self:Destroy()
    else
      self.delay = true
      interval = self.ability:GetSpecialValueFor("delay_out")
    end
  else
    self.delay = false
  end

  if IsServer() then self:StartIntervalThink(interval) end
end

-- UTILS -----------------------------------------------------------

function hunter_u_modifier_camouflage:SetEndCallback(func)
	self.endCallback = func
end

-- EFFECTS -----------------------------------------------------------

function hunter_u_modifier_camouflage:SetEfxCamouflage(bEnabled)
  if bEnabled then
    local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_scurry_passive.vpcf"
    local effect_cast = ParticleManager:CreateParticleForTeam(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent, self.parent:GetTeamNumber())
    ParticleManager:SetParticleControl(effect_cast, 2, Vector(125, 0, 0 ))
    self:AddParticle(effect_cast, false, false, -1, false, false)
  
    if IsServer() then EmitSoundOnLocationForAllies(self.parent:GetOrigin(), "Hunter.Invi", self.parent) end
  end
end