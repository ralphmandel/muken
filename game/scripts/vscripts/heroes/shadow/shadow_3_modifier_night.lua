shadow_3_modifier_night = class({})

--------------------------------------------------------------------------------
function shadow_3_modifier_night:IsPurgable()
	return false
end

function shadow_3_modifier_night:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function shadow_3_modifier_night:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function shadow_3_modifier_night:OnRemoved()
end

--------------------------------------------------------------------------------

function shadow_3_modifier_night:CheckState()
	local state = {
		[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true
	}

	return state
end

function shadow_3_modifier_night:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}
	return funcs
end

function shadow_3_modifier_night:GetBonusNightVision()
	return 100
end