bocuse_5_modifier_root = class({})

function bocuse_5_modifier_root:IsHidden() return true end
function bocuse_5_modifier_root:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_5_modifier_root:OnCreated(kv)
  self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  AddBonus(self.ability, "AGI", self.parent, self.ability:GetSpecialValueFor("special_agi"), 0, nil)
  AddModifier(self.parent, self.ability, "_modifier_root", {duration = self:GetDuration(), effect = 3}, false)
end

function bocuse_5_modifier_root:OnRefresh(kv)
end

function bocuse_5_modifier_root:OnRemoved()
  RemoveBonus(self.ability, "AGI", self.parent)
end

function bocuse_5_modifier_root:OnDestroy(kv)
  if self.endCallback then self.endCallback(self.interrupted) end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_5_modifier_root:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_STATE_CHANGED
	}
	
	return funcs
end

function bocuse_5_modifier_root:OnStateChanged(keys)
  if keys.unit ~= self.parent then return end
	if self.parent:IsRooted() == false then self:Destroy() end
end

-- UTILS -----------------------------------------------------------

function bocuse_5_modifier_root:SetEndCallback(func)
	self.endCallback = func
end

-- EFFECTS -----------------------------------------------------------