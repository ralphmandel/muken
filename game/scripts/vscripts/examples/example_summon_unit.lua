template_x_modifier_example = class({})

function template_x_modifier_example:IsHidden() return false end
function template_x_modifier_example:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function template_x_modifier_example:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.hits = self.ability:GetSpecialValueFor("hits") * 4
  self.min_health = self.hits
  AddBonus(self.ability, "_1_CON", self.parent, -9999, 0, nil)

  Timers:CreateTimer(FrameTime(), function()
    self.parent:ModifyHealth(self.hits, self.ability, false, 0)
  end)
end

function template_x_modifier_example:OnRefresh(kv)
end

function template_x_modifier_example:OnRemoved()
  RemoveBonus(self.ability, "_1_CON", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function template_x_modifier_example:CheckState()
	local state = {
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
		[MODIFIER_STATE_EVADE_DISABLED] = true
	}

	return state
end

function template_x_modifier_example:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTHBAR_PIPS,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT
	}

	return funcs
end

function template_x_modifier_example:GetModifierHealthBarPips(keys)
	return self:GetParent():GetMaxHealth() / 4
end

function template_x_modifier_example:OnDeath(keys)
	if keys.unit == self.parent then self:Destroy() end
end

function template_x_modifier_example:OnAttacked(keys)
	if keys.target ~= self.parent then return end
  local hit = 1

  if keys.attacker:IsHero() then
    if keys.attacker:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then hit = 4 else hit = 2 end
  end

  self.min_health = self.min_health - hit
end

function template_x_modifier_example:GetDisableHealing()
	return 1
end

function template_x_modifier_example:GetMinHealth()
	return self.min_health
end

function template_x_modifier_example:GetModifierExtraHealthBonus()
	return self.hits - 1
end

function template_x_modifier_example:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("ms_limit")
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------