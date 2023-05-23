bloodstained__modifier_target_hp = class({})

function bloodstained__modifier_target_hp:IsHidden() return false end
function bloodstained__modifier_target_hp:IsPurgable() return false end
function bloodstained__modifier_target_hp:RemoveOnDeath() return false end
function bloodstained__modifier_target_hp:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained__modifier_target_hp:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.hp = kv.hp

  if IsServer() then self:SetStackCount(self.hp) end
end

function bloodstained__modifier_target_hp:OnRefresh(kv)
end

function bloodstained__modifier_target_hp:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- function bloodstained__modifier_target_hp:CheckState()
-- 	local state = {
-- 		[MODIFIER_STATE_SILENCED] = true
-- 	}

-- 	return state
-- end

function bloodstained__modifier_target_hp:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS
	}

	return funcs
end

function bloodstained__modifier_target_hp:GetModifierHealthBonus()
	if IsServer() then return -self:GetStackCount() end
end

function bloodstained__modifier_target_hp:OnStackCountChanged(old)
	local void = self:GetParent():FindAbilityByName("_void")
	if void then void:SetLevel(1) end
end

-- UTILS -----------------------------------------------------------

function bloodstained__modifier_target_hp:ChangeHP(amount)
  self.hp = self.hp + amount
  if IsServer() then self:SetStackCount(math.floor(self.hp)) end
end

-- EFFECTS -----------------------------------------------------------