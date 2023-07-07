example_modifier_barrier = class({})

function example_modifier_barrier:IsHidden() return false end
function example_modifier_barrier:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function example_modifier_barrier:OnCreated(kv)
  if not IsServer() then return end

  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.max_barrier = 100
  self.barrier = self.max_barrier

  self:SetHasCustomTransmitterData(true)
  self:OnIntervalThink()
end

function example_modifier_barrier:OnRefresh(kv)
end

function example_modifier_barrier:OnRemoved()
end

function example_modifier_barrier:AddCustomTransmitterData()
  return {
    barrier = self.barrier,
  }
end

function example_modifier_barrier:HandleCustomTransmitterData(data)
  self.barrier = data.barrier
end

-- API FUNCTIONS -----------------------------------------------------------

function example_modifier_barrier:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT
	}

	return funcs
end

function example_modifier_barrier:GetModifierIncomingDamageConstant(keys)  
  if not IsServer() then return self.barrier end

  local damage = keys.damage

  self.barrier = self.barrier - damage
  if self.barrier < 0 then self:Destroy() end

  return -damage
end

function example_modifier_barrier:OnIntervalThink()
  if not IsServer() then return end

  if self.barrier < self.max_barrier then self.barrier = self.barrier + 1 end
  self:SendBuffRefreshToClients()
  self:StartIntervalThink(0.2)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------