brute_1_modifier_spin = class({})

function brute_1_modifier_spin:IsHidden() return false end
function brute_1_modifier_spin:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function brute_1_modifier_spin:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.spin_interval = self.ability:GetSpecialValueFor("spin_interval")

  AddModifier(self.parent, self.caster, self.ability, "_modifier_percent_movespeed_debuff", {
    percent = self.ability:GetSpecialValueFor("slow_percent")
  }, false)

  if IsServer() then
    self:SetStackCount(self.ability:GetSpecialValueFor("spin_number"))
    self:OnIntervalThink()
  end
end

function brute_1_modifier_spin:OnRefresh(kv)
  self.spin_interval = self.ability:GetSpecialValueFor("spin_interval")

  if IsServer() then
    self:SetStackCount(self.ability:GetSpecialValueFor("spin_number"))
  end
end

function brute_1_modifier_spin:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)
  self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_3)
end

-- API FUNCTIONS -----------------------------------------------------------

function brute_1_modifier_spin:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING,
    MODIFIER_EVENT_ON_STATE_CHANGED,
    MODIFIER_EVENT_ON_ORDER
	}

	return funcs
end

function brute_1_modifier_spin:GetModifierDisableTurning()
  return 1
end

function brute_1_modifier_spin:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsStunned() or self.parent:IsHexed()
  or self.parent:IsFrozen() or self.parent:IsDisarmed() then
		self:Destroy()
	end
end

function brute_1_modifier_spin:OnOrder(keys)
	if keys.unit ~= self.parent then return end

	if keys.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
    Timers:CreateTimer(FrameTime(), function()
      if self.parent:IsCommandRestricted() == false then
        self.parent:MoveToNPC(keys.target)
      end
    end)
	end
end

function brute_1_modifier_spin:OnIntervalThink()
  if self:GetStackCount() == 0 then self:Destroy() return else self:DecrementStackCount() end
  local gesture_rate = 0.47 / self.spin_interval
  self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_3)
  self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_3, gesture_rate)

  local enemies = FindUnitsInRadius(
    self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, self.parent:Script_GetAttackRange(),
    self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(), self.ability:GetAbilityTargetFlags(),
    0, false
  )

  for _,enemy in pairs(enemies) do
    if enemy:IsMagicImmune() == false then
      AddModifier(enemy, self.caster, self.ability, "_modifier_stun", {duration = 0.1}, false)
    end

    self.parent:PerformAttack(enemy, false, true, true, false, false, false, true)
    --if IsServer() then enemy:EmitSound("") end
  end

  if IsServer() then
    self.parent:EmitSound("Hero_Axe.CounterHelix_Blood_Chaser")
    self:StartIntervalThink(self.spin_interval)
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------