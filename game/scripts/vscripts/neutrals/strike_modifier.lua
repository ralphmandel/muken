strike_modifier = class({})

function strike_modifier:IsHidden()
	return false
end

function strike_modifier:IsPurgable()
    return false
end

function strike_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.strike_damage = self.ability:GetSpecialValueFor("strike_damage")
end

function strike_modifier:OnRefresh( kv )
end

function strike_modifier:OnRemoved()
end

--------------------------------------------------------------------------------------------------------------------------

function strike_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}

	return funcs
end

function strike_modifier:GetModifierProcAttack_BonusDamage_Physical(keys)
	if (not self.parent:PassivesDisabled()) then
		if self.ability:IsCooldownReady() then
			if IsServer() then keys.target:EmitSound("Crocodile.Strike") end
			self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
			return self.strike_damage
		end
		self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	end
end

function strike_modifier:GetModifierMoveSpeedBonus_Percentage()
	if self.ability:IsCooldownReady() then return 100 end
	return 0
end