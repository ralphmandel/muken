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

  if IsServer() then
    self:SetStackCount(1)
    self:StartIntervalThink(0.1)
  end
end

function strike_modifier:OnRefresh( kv )
end

function strike_modifier:OnRemoved()
end

--------------------------------------------------------------------------------------------------------------------------

function strike_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
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

function strike_modifier:OnStackCountChanged(old)
  if self:GetStackCount() == 1 then
    self.parent:AddNewModifier(self.caster, self.ability, "strike_modifier_speed", {})
  else
    self.parent:AddNewModifier(self.caster, self.ability, "strike_modifier_slow", {})
  end
end

function strike_modifier:OnIntervalThink()
  if IsServer() then
    if self.ability:IsCooldownReady() then
      self:SetStackCount(1)
    else
      self:SetStackCount(0)
    end
    self:StartIntervalThink(0.1)
  end
end