lawbreaker_2_modifier_combo = class({})

function lawbreaker_2_modifier_combo:IsHidden() return true end
function lawbreaker_2_modifier_combo:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_2_modifier_combo:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.gesture = {[1] = ACT_DOTA_ATTACK, [2] = ACT_DOTA_ATTACK2}
  self.type = 1
  
  AddBonus(self.ability, "_1_AGI", self.parent, self.ability:GetSpecialValueFor("agi"), 0, nil)
  AddModifier(self.caster, self.parent, self.ability, "_modifier_percent_movespeed_debuff", {
    percent = self.ability:GetSpecialValueFor("slow_percent")
  }, false)
  
  if IsServer() then 
    self:StartIntervalThink(1 / self:GetAS()) 
  end
end

function lawbreaker_2_modifier_combo:OnRefresh(kv)
end

function lawbreaker_2_modifier_combo:OnRemoved()
	RemoveBonus(self.ability,"_1_AGI", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker_2_modifier_combo:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING,
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    MODIFIER_EVENT_ON_STATE_CHANGED,
    MODIFIER_EVENT_ON_ORDER
	}

	return funcs
end

function lawbreaker_2_modifier_combo:GetModifierDisableTurning()
  return 1
end

function lawbreaker_2_modifier_combo:GetModifierAttackRangeBonus()
  return self:GetAbility():GetSpecialValueFor("atk_range")
end

function lawbreaker_2_modifier_combo:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsStunned() or self.parent:IsHexed()
  or self.parent:IsFrozen() or self.parent:IsDisarmed() then
		self:Destroy()
	end
end

function lawbreaker_2_modifier_combo:OnOrder(keys)
	if keys.unit ~= self.parent then return end

	if keys.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
    Timers:CreateTimer(FrameTime(), function()
      self.parent:MoveToNPC(keys.target)
    end)
	end
end

function lawbreaker_2_modifier_combo:OnIntervalThink()
  local front = self.parent:GetForwardVector():Normalized()
  local point = self.parent:GetOrigin() + front * self.parent:Script_GetAttackRange()
  local direction = point - self.parent:GetOrigin()
	direction.z = 0
	direction = direction:Normalized()

  self.parent:FadeGesture(self.gesture[self.type])
  if self.type == 1 then self.type = 2 else self.type = 1 end
  self.parent:StartGestureWithPlaybackRate(self.gesture[self.type], self:GetAS())

  ProjectileManager:CreateLinearProjectile({
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
  })

  if IsServer() then
    self.parent:EmitSound("Hero_Snapfire.ExplosiveShellsBuff.Attack")
    self.parent:FindModifierByName(self:GetIntrinsicModifierName()):DecrementStackCount()
    self:StartIntervalThink(1 / self:GetAS()) 
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