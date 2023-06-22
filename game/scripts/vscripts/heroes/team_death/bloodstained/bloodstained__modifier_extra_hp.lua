bloodstained__modifier_extra_hp = class({})

function bloodstained__modifier_extra_hp:IsHidden() return false end
function bloodstained__modifier_extra_hp:IsPurgable() return false end
function bloodstained__modifier_extra_hp:RemoveOnDeath() return false end
function bloodstained__modifier_extra_hp:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained__modifier_extra_hp:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(kv.extra_life) end
end

function bloodstained__modifier_extra_hp:OnRefresh(kv)
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained__modifier_extra_hp:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS
	}

	return funcs
end

function bloodstained__modifier_extra_hp:GetModifierExtraHealthBonus()
	if IsServer() then return self:GetStackCount() end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------