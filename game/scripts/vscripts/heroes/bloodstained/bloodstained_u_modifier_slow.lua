bloodstained_u_modifier_slow = class({})

function bloodstained_u_modifier_slow:IsHidden() return false end
function bloodstained_u_modifier_slow:IsPurgable() return false end
function bloodstained_u_modifier_slow:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_u_modifier_slow:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function bloodstained_u_modifier_slow:OnRefresh(kv)
end

function bloodstained_u_modifier_slow:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- function bloodstained_u_modifier_slow:CheckState()
-- 	local state = {
-- 		[MODIFIER_STATE_SILENCED] = true
-- 	}

-- 	return state
-- end


-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------