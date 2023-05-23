bloodstained_u_modifier_slow = class({})

function bloodstained_u_modifier_slow:IsHidden() return false end
function bloodstained_u_modifier_slow:IsPurgable() return false end
function bloodstained_u_modifier_slow:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_u_modifier_slow:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.hp = kv.hp

  if IsServer() then self:SetStackCount(self.hp) end
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

function bloodstained_u_modifier_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS
	}

	return funcs
end

function bloodstained_u_modifier_slow:GetModifierHealthBonus()
	if IsServer() then return -self:GetStackCount() end
end

function bloodstained_u_modifier_slow:OnStackCountChanged(old)
	local void = self:GetParent():FindAbilityByName("_void")
	if void then void:SetLevel(1) end
end

-- UTILS -----------------------------------------------------------

function bloodstained_u_modifier_slow:ChangeHP(amount)
  self.hp = self.hp + amount
  if IsServer() then self:SetStackCount(math.floor(self.hp)) end
end

-- EFFECTS -----------------------------------------------------------