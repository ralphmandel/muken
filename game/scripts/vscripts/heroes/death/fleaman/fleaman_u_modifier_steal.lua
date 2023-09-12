fleaman_u_modifier_steal = class({})

function fleaman_u_modifier_steal:IsHidden() return false end
function fleaman_u_modifier_steal:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_u_modifier_steal:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then
    self:SetStackCount(0)
    self:AddStack()
  end
end

function fleaman_u_modifier_steal:OnRefresh(kv)
	if IsServer() then
    self:AddStack()
  end
end

function fleaman_u_modifier_steal:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function fleaman_u_modifier_steal:OnStackCountChanged(old)
  if self:GetStackCount() ~= old and self:GetStackCount() == 0 then self:Destroy() end
end

-- UTILS -----------------------------------------------------------

function fleaman_u_modifier_steal:AddStack()
  if IsServer() then self:IncrementStackCount() end
  
  local stat_modifier = AddBonus(self.ability, "STR", self.parent, -1, 0, self:GetDuration())

  stat_modifier:SetEndCallback(function(interrupted)
    if IsServer() then self:DecrementStackCount() end
  end)
end

-- EFFECTS -----------------------------------------------------------