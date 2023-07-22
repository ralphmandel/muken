bloodstained_1_modifier_rage = class({})

function bloodstained_1_modifier_rage:IsHidden() return false end
function bloodstained_1_modifier_rage:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_1_modifier_rage:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.str = 0

	self.ability:EndCooldown()
	self.ability:SetActivated(false)

  AddStatusEfx(self.ability, "bloodstained_1_modifier_rage_status_efx", self.caster, self.parent)
  AddBonus(self.ability, "LCK", self.parent, self.ability:GetSpecialValueFor("lck"), 0, nil)
end

function bloodstained_1_modifier_rage:OnRefresh(kv)
  self.str = 0
end

function bloodstained_1_modifier_rage:OnRemoved()
	if IsServer() then self.parent:StopSound("Bloodstained.rage") end

  RemoveStatusEfx(self.ability, "bloodstained_1_modifier_rage_status_efx", self.caster, self.parent)
	RemoveBonus(self.ability, "LCK", self.parent)
	RemoveBonus(self.ability, "STR", self.parent)

	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self.ability:SetActivated(true)
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_1_modifier_rage:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function bloodstained_1_modifier_rage:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
  self:FilterDamage(keys.damage)
end

function bloodstained_1_modifier_rage:OnStackCountChanged(old)
	RemoveBonus(self.ability, "STR", self.parent)
  AddBonus(self.ability, "STR", self.parent, self:GetStackCount(), 0, nil)	
end

-- UTILS -----------------------------------------------------------

function bloodstained_1_modifier_rage:FilterDamage(amount)
  self:CalcGain(amount * self.ability:GetSpecialValueFor("str_gain") * 0.01)
end

function bloodstained_1_modifier_rage:CalcGain(gain)
	if IsServer() then
    self.str = self.str + gain
    self:SetStackCount(math.floor(self.str))
  end
end

-- EFFECTS -----------------------------------------------------------

function bloodstained_1_modifier_rage:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_debuff.vpcf"
end

function bloodstained_1_modifier_rage:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function bloodstained_1_modifier_rage:GetStatusEffectName()
	return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf"
end

function bloodstained_1_modifier_rage:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end