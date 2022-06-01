_modifier_blind = class({})

--------------------------------------------------------------------------------
function _modifier_blind:IsPurgable()
	return true
end

function _modifier_blind:IsHidden()
	return true
end

function _modifier_blind:IsDebuff()
	return true
end

function _modifier_blind:GetTexture()
	return "_modifier_blind"
end

function _modifier_blind:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_blind:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.percent = kv.percent
	self.miss_chance = kv.miss_chance or 0

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind_stack", {})
end

function _modifier_blind:OnRemoved()
	self.percent = 0
	local mod = self.parent:FindModifierByName("_modifier_blind_stack")
	if mod then mod:Check() end
end

--------------------------------------------------------------------------------

function _modifier_blind:GetPercent()
	return self.percent
end

function _modifier_blind:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
	}
	return funcs
end

function _modifier_blind:GetModifierMiss_Percentage()
	return self.miss_chance
end