genuine_5_modifier_barrier = class({})

function genuine_5_modifier_barrier:IsHidden() return true end
function genuine_5_modifier_barrier:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_5_modifier_barrier:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then
    self:SetStackCount(self.ability:GetMaxBarrier())
    self:StartIntervalThink(FrameTime())
  end
end

function genuine_5_modifier_barrier:OnRefresh(kv)
end

function genuine_5_modifier_barrier:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_5_modifier_barrier:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT
	}
	
	return funcs
end

function genuine_5_modifier_barrier:GetModifierIncomingSpellDamageConstant(keys)
  if not IsServer() then
    return self:GetStackCount()
  end

  local damage = keys.damage
  self.ability.barrier = self.ability.barrier - keys.damage

  if self.ability.barrier < 0 then
    damage = damage + self.ability.barrier
    self.ability.barrier = 0
  end

  self:SetStackCount(self.ability.barrier)
  self:SendBuffRefreshToClients()

  return -damage
end

function genuine_5_modifier_barrier:OnIntervalThink()
  if IsServer() then
    if self.ability.barrier > self.ability:GetMaxBarrier() then
      self.ability.barrier = self.ability:GetMaxBarrier()
      self:SetStackCount(self.ability.barrier)
      self:SendBuffRefreshToClients()
    end
    if self.ability.barrier < self.ability:GetMaxBarrier() then 
      self.ability.barrier = self.ability.barrier + 1
      self:SetStackCount(self.ability.barrier)
      self:SendBuffRefreshToClients()
    end

    if self:GetStackCount() ~= self.ability.barrier then
      self:SetStackCount(self.ability.barrier)
    end

    self:StartIntervalThink(1 / self.ability:GetSpecialValueFor("barrier_regen"))
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------