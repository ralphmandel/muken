rage_modifier = class({})

function rage_modifier:IsHidden()
	return false
end

function rage_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function rage_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function rage_modifier:OnRefresh( kv )
end

function rage_modifier:OnRemoved()
end

--------------------------------------------------------------------------------

function rage_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function rage_modifier:OnAttackLanded(keys)
	if keys.attacker:PassivesDisabled() then return end

	if keys.attacker == self.parent then
		self.parent:AddNewModifier(self.caster, self.ability, "rage_modifier_damage", {})
	end
end