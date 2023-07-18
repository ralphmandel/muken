hunter_4_modifier_channeling = class({})

function hunter_4_modifier_channeling:IsHidden() return true end
function hunter_4_modifier_channeling:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_4_modifier_channeling:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if self.caster ~= self.parent then
    self.parent:Hold()
  end
end

function hunter_4_modifier_channeling:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_2_modifier_passive:CheckState()
	local state = {}

  if self:GetCaster() ~= self:GetParent() then
    table.insert(state, MODIFIER_STATE_COMMAND_RESTRICTED, true)
  end

	return state
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------