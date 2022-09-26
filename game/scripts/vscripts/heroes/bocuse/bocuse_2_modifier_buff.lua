bocuse_2_modifier_buff = class({})

function bocuse_2_modifier_buff:IsHidden()
	return false
end

function bocuse_2_modifier_buff:IsPurgable()
	return true
end

function bocuse_2_modifier_buff:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_2_modifier_buff:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.bonus_amount = 0

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bocuse_2_modifier_status_efx", true) end

	local init_duration = self.ability:GetSpecialValueFor("init_duration")
	self.intervals = self.ability:GetSpecialValueFor("intervals")

	if IsServer() then
		self:SetDuration(init_duration, false)
		self:SetStackCount(math.ceil(self:GetRemainingTime()))
		self:StartIntervalThink(self.intervals)
		self.parent:EmitSound("Bocuse.Flambee.Buff")
	end
end

function bocuse_2_modifier_buff:OnRefresh(kv)
	local init_duration = self.ability:GetSpecialValueFor("init_duration")
	self.bonus_amount = 0

	if IsServer() then
		self:SetDuration(init_duration, false)
		self:SetStackCount(math.ceil(self:GetRemainingTime()))
		self.parent:StopSound("Bocuse.Flambee.Buff")
		self.parent:EmitSound("Bocuse.Flambee.Buff")
	end
end

function bocuse_2_modifier_buff:OnRemoved()
	if IsServer() then self.parent:StopSound("Bocuse.Flambee.Buff") end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bocuse_2_modifier_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_2_modifier_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function bocuse_2_modifier_buff:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end

	self.bonus_amount = self:AddBonusAmount(keys.damage)
end

function bocuse_2_modifier_buff:OnIntervalThink()
	if IsServer() then
		self:CalcTime()
		self:ApplyMana()
		self:ApplyHeal()
		self:StartIntervalThink(self.intervals)
	end
end

-- UTILS -----------------------------------------------------------

function bocuse_2_modifier_buff:AddBonusAmount(damage)
	local amount_scale = self.ability:GetSpecialValueFor("amount_scale")
	local result = self.bonus_amount + ((damage * 100) / self.parent:GetBaseMaxHealth())
	return result * amount_scale
end

function bocuse_2_modifier_buff:ApplyMana()
	local mana_gain = self.ability:GetSpecialValueFor("mana_gain")

	-- UP 2.21
	if self.ability:GetRank(21) then
		mana_gain = mana_gain + 5
	end

	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then mana_gain = mana_gain * base_stats:GetHealPower() end

	if mana_gain > 0 and self.parent:GetUnitName() ~= "npc_dota_hero_elder_titan" then
		self.parent:GiveMana(mana_gain)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self.parent, mana_gain, self.caster)
	end
end

function bocuse_2_modifier_buff:ApplyHeal()
	local min_amount = self.ability:GetSpecialValueFor("min_amount")
	local amount = (min_amount + self.bonus_amount) * self.parent:GetBaseMaxHealth() * 0.01

	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then amount = amount * base_stats:GetHealPower() end
	if amount > 0 then self.parent:Heal(amount, self.ability) end

	self.bonus_amount = 0

	if self.time > 0 then
		self:SetDuration(self.time, false)
		self:SetStackCount(math.ceil(self:GetRemainingTime()))
		return
	end

	self:Destroy()
end

function bocuse_2_modifier_buff:CalcTime()
	local amount_time_loss = self.ability:GetSpecialValueFor("amount_time_loss")
	self.time = self:GetRemainingTime() - (self.bonus_amount / amount_time_loss)

	if self.time < 0 then self.bonus_amount = self:GetRemainingTime() * amount_time_loss end
end

-- EFFECTS -----------------------------------------------------------

function bocuse_2_modifier_buff:GetStatusEffectName()
	return "particles/econ/items/lifestealer/ls_ti9_immortal/status_effect_ls_ti9_open_wounds.vpcf"
end

function bocuse_2_modifier_buff:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function bocuse_2_modifier_buff:GetEffectName()
	return "particles/bocuse/bocuse_drunk_ally_crit.vpcf"
end

function bocuse_2_modifier_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end