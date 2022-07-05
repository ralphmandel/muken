_modifier_ethereal = class({})

--------------------------------------------------------------------------------
function _modifier_ethereal:IsHidden()
	return false
end

function _modifier_ethereal:IsPurgable()
	return true
end

function _modifier_ethereal:GetTexture()
	return "_modifier_ethereal"
end

function _modifier_ethereal:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_ethereal:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.ability, "_modifier_ethereal_status_efx", true) end
end

function _modifier_ethereal:OnRemoved()
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.ability, "_modifier_ethereal_status_efx", false) end
end

--------------------------------------------------------------------------------

function _modifier_ethereal:CheckState()
	local state = {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function _modifier_ethereal:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

function _modifier_ethereal:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end