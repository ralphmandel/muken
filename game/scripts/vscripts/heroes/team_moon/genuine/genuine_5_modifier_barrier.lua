genuine_5_modifier_barrier = class({})

function genuine_5_modifier_barrier:IsHidden() return true end
function genuine_5_modifier_barrier:IsPurgable() return false end
function genuine_5_modifier_barrier:RemoveOnDeath() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_5_modifier_barrier:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.interval = 0.1

  if IsServer() then
    self.max_barrier = self.ability:GetMaxBarrier()
    self.barrier = self.ability:GetMaxBarrier()
    self:SetStackCount(self.barrier)
    self:StartIntervalThink(self.interval)
  end
end

function genuine_5_modifier_barrier:OnRefresh(kv)
end

function genuine_5_modifier_barrier:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_5_modifier_barrier:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT,
    MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT
	}
	
	return funcs
end

function genuine_5_modifier_barrier:GetModifierConstantHealthRegen()
  return self.max_barrier * self:GetAbility():GetSpecialValueFor("barrier_regen") * 0.01 * self:GetAbility():GetSpecialValueFor("special_hp_regen")
end

function genuine_5_modifier_barrier:GetModifierIncomingSpellDamageConstant(keys)
  if self:GetAbility():GetSpecialValueFor("special_universal") == 1 then return 0 end

  if not IsServer() then
    return self:GetStackCount()
  end

  local damage = keys.original_damage
  self.barrier = self.barrier - damage

  if self.barrier < 0 then
    damage = damage + self.barrier
    self.barrier = 0
  end

  self:UpdateBarrier(0, true)

  return -damage
end

function genuine_5_modifier_barrier:GetModifierIncomingDamageConstant(keys)
  if self:GetAbility():GetSpecialValueFor("special_universal") == 0 then return 0 end
  
  if not IsServer() then
    return self:GetStackCount()
  end

  local damage = keys.original_damage
  self.barrier = self.barrier - damage

  if self.barrier < 0 then
    damage = damage + self.barrier
    self.barrier = 0
  end

  self:UpdateBarrier(0, true)

  return -damage
end

function genuine_5_modifier_barrier:OnIntervalThink()
  if IsServer() then
    if self.barrier < self.max_barrier then
      self:UpdateBarrier(self.max_barrier * self.ability:GetSpecialValueFor("barrier_regen") * self.interval * 0.01, true)
    end

    self:StartIntervalThink(self.interval)
  end
end

-- UTILS -----------------------------------------------------------

function genuine_5_modifier_barrier:UpdateBarrier(value, isRegen)
  if self.barrier + value > self.max_barrier then value = self.max_barrier - self.barrier end

  if isRegen == false and self.ability:GetSpecialValueFor("special_hp_regen") == 1 then
    self.parent:ModifyHealth(self.parent:GetHealth() + value, self.ability, false, 0)
  end

  self.barrier = self.barrier + value
  self:SetStackCount(self.barrier)
  self:SendBuffRefreshToClients()
end

-- EFFECTS -----------------------------------------------------------