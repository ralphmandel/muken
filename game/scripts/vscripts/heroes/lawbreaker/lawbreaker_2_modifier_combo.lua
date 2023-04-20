lawbreaker_2_modifier_combo = class({})

function lawbreaker_2_modifier_combo:IsHidden() return false end
function lawbreaker_2_modifier_combo:IsPurgable() return false end
function lawbreaker_2_modifier_combo:GetPriority() return MODIFIER_PRIORITY_ULTRA end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_2_modifier_combo:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.gesture = {[1] = ACT_DOTA_ATTACK, [2] = ACT_DOTA_ATTACK2}
  self.type = 1
  

  AddBonus(self.ability, "_1_AGI", self.parent, self.ability:GetSpecialValueFor("agi"), 0, nil)
  
  if IsServer() then 
    self:SetStackCount(self.ability:GetSpecialValueFor("max_shots"))
    self:StartIntervalThink(1 / self:GetAS()) 
  end
end

function lawbreaker_2_modifier_combo:OnRefresh(kv)
end

function lawbreaker_2_modifier_combo:OnRemoved()
	RemoveBonus(self.ability,"_1_AGI", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker_2_modifier_combo:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true
	}

	return state
end

function lawbreaker_2_modifier_combo:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING,
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    MODIFIER_PROPERTY_MOVESPEED_LIMIT
	}

	return funcs
end

function lawbreaker_2_modifier_combo:GetModifierDisableTurning()
  return 1
end

function lawbreaker_2_modifier_combo:GetModifierAttackRangeBonus()
  return self:GetAbility():GetSpecialValueFor("atk_range")
end

function lawbreaker_2_modifier_combo:GetModifierMoveSpeed_Limit()
  return self:GetAbility():GetSpecialValueFor("limit_ms")
end

function lawbreaker_2_modifier_combo:OnIntervalThink()
  local front = self.parent:GetForwardVector():Normalized()
  local point = self.ability.point
  local direction = point - self.parent:GetOrigin()
	direction.z = 0
	direction = direction:Normalized()

  self.parent:FadeGesture(self.gesture[self.type])
  if self.type == 1 then self.type = 2 else self.type = 1 end
  self.parent:StartGestureWithPlaybackRate(self.gesture[self.type], self:GetAS())

  local linear_info = {
    Source = self.parent,
    Ability = self.ability,
    vSpawnOrigin = self.parent:GetAbsOrigin(),
    
    bDeleteOnHit = true,
    
    iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
    iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    
    EffectName = "particles/lawbreaker/lawbreaker_skill2_bullets.vpcf",
    fDistance = self.parent:Script_GetAttackRange(),
    fStartRadius = 50,
    fEndRadius = 50,
    vVelocity = direction * self.parent:GetProjectileSpeed(),

    bProvidesVision = false,
    iVisionRadius = 0,
    iVisionTeamNumber = self.parent:GetTeamNumber()
  }
  ProjectileManager:CreateLinearProjectile(linear_info)
  if IsServer() then
    self:DecrementStackCount()
    self:StartIntervalThink(1 / self:GetAS()) 
  end
end

function lawbreaker_2_modifier_combo:OnStackCountChanged(old)
  if self:GetStackCount() ~= old and self:GetStackCount() == 0 then
    self:Destroy()
  end
  
end
-- UTILS -----------------------------------------------------------

function lawbreaker_2_modifier_combo:GetAS()
  --local attack_speed1 = 100 + (BaseStats(self.parent):GetSpecialValueFor("attack_speed") * (BaseStats(self.parent):GetStatTotal("_1_AGI") + 1))
  local attack_speed = (BaseStats(self.parent):GetStatTotal("AGI") + 1)
  attack_speed = 100 + (BaseStats(self.parent):GetSpecialValueFor("attack_speed") * attack_speed)
  return attack_speed / 100 * 1.2
end

-- EFFECTS -----------------------------------------------------------

function lawbreaker_2_modifier_combo:PlayEfxLifesteal(target)
	local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)
end