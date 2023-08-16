hunter_2_modifier_timer = class({})

function hunter_2_modifier_timer:IsHidden() return false end
function hunter_2_modifier_timer:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_2_modifier_timer:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function hunter_2_modifier_timer:OnRemoved()
end

function hunter_2_modifier_timer:OnDestroy(kv)
  if self.endCallback then self.endCallback(self.interrupted) end
end


-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

function hunter_2_modifier_timer:SetEndCallback(func)
	self.endCallback = func
end

-- EFFECTS -----------------------------------------------------------