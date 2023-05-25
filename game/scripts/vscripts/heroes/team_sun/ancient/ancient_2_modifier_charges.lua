ancient_2_modifier_charges = class({})

function ancient_2_modifier_charges:IsHidden() return false end
function ancient_2_modifier_charges:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_2_modifier_charges:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then
    self:StartIntervalThink(1)
    self:SetStackCount(0)
  end
end

function ancient_2_modifier_charges:OnRefresh(kv)
end

function ancient_2_modifier_charges:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_2_modifier_charges:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER
	}

	return funcs
end

function ancient_2_modifier_charges:OnOrder(keys)
  if keys.unit ~= self.parent then return end
  if keys.order_type == 8 or keys.order_type == 5 then
    self.ability.aggro_target = self.parent:GetAggroTarget()
  end
end


function ancient_2_modifier_charges:OnStackCountChanged(old)  
  if self:GetStackCount() == 0 then
    self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
    if IsServer() then self:SetStackCount(self.ability:GetSpecialValueFor("hits")) end
  end

  if self:GetStackCount() == self.ability:GetSpecialValueFor("hits") then
    self.ability:SetCurrentAbilityCharges(1)
  else
    self.ability:SetCurrentAbilityCharges(2)
  end
end

function ancient_2_modifier_charges:OnIntervalThink()
  self.parent:FindAbilityByName("ancient__jump"):SetLevel(math.floor(self.parent:GetIdealSpeed()))
  if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------