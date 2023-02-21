bocuse_5_modifier_root = class({})

function bocuse_5_modifier_root:IsHidden() return true end
function bocuse_5_modifier_root:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_5_modifier_root:OnCreated(kv)
  self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_root", {
		duration = self:GetDuration(), effect = 3
	})
end

function bocuse_5_modifier_root:OnRefresh(kv)
end

function bocuse_5_modifier_root:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_5_modifier_root:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true
	}

	if self:GetAbility():GetSpecialValueFor("special_mobility") < 0 then
		table.insert(state, MODIFIER_STATE_EVADE_DISABLED, true)
	end

	return state
end

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

-- EFFECTS -----------------------------------------------------------