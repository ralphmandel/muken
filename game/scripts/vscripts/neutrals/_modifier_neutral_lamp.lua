_modifier_neutral_lamp = class({})

function _modifier_neutral_lamp:IsHidden()
	return true
end

function _modifier_neutral_lamp:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function _modifier_neutral_lamp:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	--self.spot = kv.spot
end

function _modifier_neutral_lamp:OnRefresh( kv )
end

function _modifier_neutral_lamp:OnRemoved()
end

--------------------------------------------------------------------------------

function _modifier_neutral_lamp:DeclareFunctions()
	local funcs = {
	}

	return funcs
end