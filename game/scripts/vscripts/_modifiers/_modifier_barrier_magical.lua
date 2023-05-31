_modifier_barrier_magical = class({})

--------------------------------------------------------------------------------
function _modifier_barrier_magical:IsHidden()
	return true
end

function _modifier_barrier_magical:IsPurgable()
	return false
end

function _modifier_barrier_magical:GetTexture()
	return "_modifier_barrier_magical"
end

function _modifier_barrier_magical:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function _modifier_barrier_magical:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function _modifier_barrier_magical:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  if IsServer() then
    self.shield = kv.shield
    self.remove = kv.remove
    self:SetStackCount(kv.max_shield)
    self:StartIntervalThink(FrameTime())
  end
end

function _modifier_barrier_magical:OnRemoved()
end

--------------------------------------------------------------------------------

function _modifier_barrier_magical:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT
	}
	
	return funcs
end

function _modifier_barrier_magical:GetModifierIncomingSpellDamageConstant(keys)
  if not IsServer() then
    return self:GetStackCount()
  end

  local damage = keys.damage
  self.shield = self.shield - keys.damage

  if self.shield < 0 then
    damage = damage + self.shield
    self.shield = 0
  end

  self:SetStackCount(self.shield)
  self:SendBuffRefreshToClients()

  return -damage
end

function _modifier_barrier_magical:OnIntervalThink()
  if IsServer() then
    self:SetStackCount(self.shield)
    self:StartIntervalThink(-1)
  end
end

--------------------------------------------------------------------------------