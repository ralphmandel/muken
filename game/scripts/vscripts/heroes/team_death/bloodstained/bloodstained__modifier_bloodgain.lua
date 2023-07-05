bloodstained__modifier_bloodgain = class({})

function bloodstained__modifier_bloodgain:IsHidden() return false end
function bloodstained__modifier_bloodgain:IsPurgable() return false end
function bloodstained__modifier_bloodgain:RemoveOnDeath() return false end
function bloodstained__modifier_bloodgain:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained__modifier_bloodgain:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:SetStackCount(kv.hp_stolen) end
end

function bloodstained__modifier_bloodgain:OnRefresh(kv)
end

function bloodstained__modifier_bloodgain:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained__modifier_bloodgain:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_BONUS
	}

	return funcs
end

function bloodstained__modifier_bloodgain:GetModifierHealthBonus()
	return self:GetStackCount()
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------