bocuse_2_modifier_debuff = class({})

function bocuse_2_modifier_debuff:IsHidden()
	return false
end

function bocuse_2_modifier_debuff:IsPurgable()
	return true
end

function bocuse_2_modifier_debuff:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_2_modifier_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.bonus_amount = 0

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bocuse_2_modifier_status_efx", true) end

	local blind = self.ability:GetSpecialValueFor("blind")
	local init_duration = self.ability:GetSpecialValueFor("init_duration")
	self.intervals = self.ability:GetSpecialValueFor("intervals")

	-- UP 2.21
	if self.ability:GetRank(21) then
		blind = blind + 10
	end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = blind, miss_chance = blind})

	if IsServer() then
		self:SetDuration(init_duration, false)
		self:SetStackCount(math.ceil(self:GetRemainingTime()))
		self:StartIntervalThink(self.intervals)
	end
end

function bocuse_2_modifier_debuff:OnRefresh(kv)
	local blind = self.ability:GetSpecialValueFor("blind")
	local init_duration = self.ability:GetSpecialValueFor("init_duration")
	self.bonus_amount = 0

	local mod = self.parent:FindAllModifiersByName("_modifier_blind")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	-- UP 2.21
	if self.ability:GetRank(21) then
		blind = blind + 10
	end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = blind, miss_chance = blind})

	if IsServer() then
		self:SetDuration(init_duration, false)
		self:SetStackCount(math.ceil(self:GetRemainingTime()))
	end
end

function bocuse_2_modifier_debuff:OnRemoved()
	if IsServer() then self.parent:StopSound("Hero_OgreMagi.Ignite.Damage") end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bocuse_2_modifier_status_efx", false) end

	local mod = self.parent:FindAllModifiersByName("_modifier_blind")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_2_modifier_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function bocuse_2_modifier_debuff:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end

	self.bonus_amount = self:AddBonusAmount(keys.damage)
end

function bocuse_2_modifier_debuff:OnIntervalThink()
	if IsServer() then
		self:CalcTime()
		self:ApplyDamage()
		self:StartIntervalThink(self.intervals)
		self.parent:EmitSound("Hero_OgreMagi.Ignite.Damage")
	end
end

-- UTILS -----------------------------------------------------------

function bocuse_2_modifier_debuff:AddBonusAmount(damage)
	local amount_scale = self.ability:GetSpecialValueFor("amount_scale")
	local result = self.bonus_amount + ((damage * 100) / self.parent:GetBaseMaxHealth())
	return result * amount_scale
end

function bocuse_2_modifier_debuff:ApplyDamage()
	local min_amount = self.ability:GetSpecialValueFor("min_amount")
	local amount = (min_amount + self.bonus_amount) * self.parent:GetBaseMaxHealth() * 0.01

	ApplyDamage({
		victim = self.parent, attacker = self.caster,
		damage = amount, damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability, damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
	})

	self.bonus_amount = 0

	if self.time > 0 then
		self:SetDuration(self.time, false)
		self:SetStackCount(math.ceil(self:GetRemainingTime()))
		return
	end

	self:Destroy()
end

function bocuse_2_modifier_debuff:CalcTime()
	local amount_time_loss = self.ability:GetSpecialValueFor("amount_time_loss")
	self.time = self:GetRemainingTime() - (self.bonus_amount / amount_time_loss)

	if self.time < 0 then self.bonus_amount = self:GetRemainingTime() * amount_time_loss end
end

-- EFFECTS -----------------------------------------------------------

function bocuse_2_modifier_debuff:GetStatusEffectName()
	return "particles/econ/items/lifestealer/ls_ti9_immortal/status_effect_ls_ti9_open_wounds.vpcf"
end

function bocuse_2_modifier_debuff:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function bocuse_2_modifier_debuff:GetEffectName()
	return "particles/bocuse/bocuse_drunk_enemy.vpcf"
end

function bocuse_2_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end