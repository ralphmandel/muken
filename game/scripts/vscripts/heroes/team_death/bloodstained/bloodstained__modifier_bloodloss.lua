bloodstained__modifier_bloodloss = class({})

function bloodstained__modifier_bloodloss:IsHidden() return false end
function bloodstained__modifier_bloodloss:IsPurgable() return false end
function bloodstained__modifier_bloodloss:RemoveOnDeath() return false end
function bloodstained__modifier_bloodloss:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained__modifier_bloodloss:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:SetStackCount(kv.hp_stolen) end
end

function bloodstained__modifier_bloodloss:OnRefresh(kv)
end

function bloodstained__modifier_bloodloss:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained__modifier_bloodloss:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS
	}

	return funcs
end

function bloodstained__modifier_bloodloss:GetModifierHealthBonus()
	return -self:GetStackCount()
end

function bloodstained__modifier_bloodloss:OnStackCountChanged(old)
	local void = self:GetParent():FindAbilityByName("_void")
	if void then void:SetLevel(1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------