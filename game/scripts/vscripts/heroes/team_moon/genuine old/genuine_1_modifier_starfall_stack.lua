genuine_1_modifier_starfall_stack = class({})

function genuine_1_modifier_starfall_stack:IsHidden() return false end
function genuine_1_modifier_starfall_stack:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_1_modifier_starfall_stack:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(1) end
end

function genuine_1_modifier_starfall_stack:OnRefresh(kv)
	if IsServer() then self:IncrementStackCount() end
end

function genuine_1_modifier_starfall_stack:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_1_modifier_starfall_stack:OnStackCountChanged(old)
  if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("special_starfall_combo") then
    CreateStarfall(self.parent, self.ability)
    self:Destroy()
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------