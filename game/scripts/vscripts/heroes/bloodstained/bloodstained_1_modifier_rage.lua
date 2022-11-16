bloodstained_1_modifier_rage = class({})

function bloodstained_1_modifier_rage:IsHidden()
	return false
end

function bloodstained_1_modifier_rage:IsPurgable()
	return true
end

function bloodstained_1_modifier_rage:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_1_modifier_rage:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.str = 0

	-- UP 1.21
	if self.ability:GetRank(21) and self.parent:IsStunned() then
		self.str = 5
	end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bloodstained_1_modifier_rage_status_efx", true) end
end

function bloodstained_1_modifier_rage:OnRefresh(kv)
	self.str = 0

	-- UP 1.21
	if self.ability:GetRank(21) and self.parent:IsStunned() then
		self.str = 5
	end
end

function bloodstained_1_modifier_rage:OnRemoved()
	if IsServer() then self.parent:StopSound("Bloodstained.rage") end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bloodstained_1_modifier_rage_status_efx", false) end

	self.ability:RemoveBonus("_1_STR", self.parent)
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
	self:CalcGain(keys.damage)
end

function bloodstained_1_modifier_rage:OnAttackLanded(keys)
    if keys.attacker ~= self.parent then return end
	if keys.attacker:IsIllusion() then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	-- UP 1.41
	if self.ability:GetRank(41) then
		local cleaveatk = DoCleaveAttack(
			self.parent, keys.target, self.ability, keys.damage * 0.75, 100, 400, 500,
			"particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength_crit.vpcf"
		)
	end
end

function bloodstained_1_modifier_rage:OnStackCountChanged(old)
	self.ability:RemoveBonus("_1_STR", self.parent)

	if self:GetStackCount() > 0 then
		self.ability:AddBonus("_1_STR", self.parent, self:GetStackCount(), 0, nil)	
	end
end

-- UTILS -----------------------------------------------------------

function bloodstained_1_modifier_rage:CalcGain(damage)
	local str_gain = self.ability:GetSpecialValueFor("str_gain")
	self.str = self.str + (damage * str_gain * 0.01)

	if IsServer() then self:SetStackCount(math.floor(self.str)) end
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