inquisitor_3_modifier_speed = class({})

--------------------------------------------------------------------------------

function inquisitor_3_modifier_speed:IsHidden()
	return true
end

function inquisitor_3_modifier_speed:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function inquisitor_3_modifier_speed:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function inquisitor_3_modifier_speed:OnRefresh( kv )
end

function inquisitor_3_modifier_speed:OnRemoved()
end

--------------------------------------------------------------------------------

function inquisitor_3_modifier_speed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BASE_OVERRIDE,
	}
	
	return funcs
end

function inquisitor_3_modifier_speed:GetModifierAttackSpeedBaseOverride(keys)
	return 3.75
end