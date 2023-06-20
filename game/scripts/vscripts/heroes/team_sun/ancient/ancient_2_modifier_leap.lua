ancient_2_modifier_leap = class({})
STATE_PRE_HIT = 1
STATE_POS_HIT = 2

function ancient_2_modifier_leap:IsHidden() return true end
function ancient_2_modifier_leap:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_2_modifier_leap:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  local gesture_time = 1.07
  local gesture_hit_point = 0.4
  local interval_total = self.ability:GetSpecialValueFor("interval")
  
  self.interval_pre = interval_total * gesture_hit_point
  self.interval_pos = interval_total - self.interval_pre
  self.speed = gesture_time / interval_total
  self.end_combo = false

  if self.ability:GetCurrentAbilityCharges() == 1 then
    self.state = STATE_POS_HIT
  else
    self.state = STATE_PRE_HIT
  end


  if IsServer() then self:OnIntervalThink() end
end

function ancient_2_modifier_leap:OnRefresh(kv)
end

function ancient_2_modifier_leap:OnRemoved()
  self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_5)

  if self.ability.aggro_target then
    if IsValidEntity(self.ability.aggro_target) then
      if self.parent:IsAlive() and self.ability.aggro_target:IsAlive() then
        self.parent:MoveToTargetToAttack(self.ability.aggro_target)
      end
    end
  end
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_2_modifier_leap:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true
	}

	return state
end

function ancient_2_modifier_leap:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_UNIT_MOVED
	}

	return funcs
end

function ancient_2_modifier_leap:OnStateChanged(keys)
  if keys.unit ~= self.parent then return end
  if self.parent:IsStunned() or self.parent:IsHexed() then self:Destroy() end
end

function ancient_2_modifier_leap:OnUnitMoved(keys)
  if keys.unit == self.parent then self:Destroy() end
end

function ancient_2_modifier_leap:OnIntervalThink()
  if self.state == STATE_PRE_HIT then self:PreHit() return end
  if self.state == STATE_POS_HIT then self:PosHit() end
end

-- UTILS -----------------------------------------------------------

function ancient_2_modifier_leap:PreHit()
  if self.end_combo == true then self:Destroy() return end
  self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_5)
  self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5, self.speed)
  self.state = STATE_POS_HIT

  if IsServer() then
    self.parent:EmitSound("Hero_ElderTitan.PreAttack")
    self:StartIntervalThink(self.interval_pre)
  end
end

function ancient_2_modifier_leap:PosHit()
  GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), self.ability:GetAOERadius(), false)

  local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius(),
    self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
    self.ability:GetAbilityTargetFlags(), 0, false
	)

	for _,enemy in pairs(enemies) do
    self.parent:PerformAttack(enemy, false, true, true, true, false, false, false)
	end

  local charges = self.parent:FindModifierByName(self.ability:GetIntrinsicModifierName())
  
  if charges:GetStackCount() == 1 then
    self.end_combo = true
  else
    self.ability:EndCooldown()
    self.ability:StartCooldown(1)
  end

  if IsServer() then charges:DecrementStackCount() end

  self.state = STATE_PRE_HIT

  if IsServer() then
    self:PlayEfxHit(self.ability:GetAOERadius())
    self:StartIntervalThink(self.interval_pos)
  end
end

-- EFFECTS -----------------------------------------------------------

function ancient_2_modifier_leap:PlayEfxHit(radius)
  local particle_cast = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf"
  local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))

  if IsServer() then self.parent:EmitSound("Hero_ElderTitan.EchoStomp") end
end