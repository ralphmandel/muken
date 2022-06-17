bocuse_2_modifier_flambee_debuff = class ({})

function bocuse_2_modifier_flambee_debuff:IsHidden()
    return false
end

function bocuse_2_modifier_flambee_debuff:IsPurgable()
    return true
end

function bocuse_2_modifier_flambee_debuff:IsDebuff()
    return true
end

-----------------------------------------------------------

function bocuse_2_modifier_flambee_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

    local blind = self.ability:GetSpecialValueFor("blind")
    local intervals = self.ability:GetSpecialValueFor("intervals")
    self.percent = self.ability:GetSpecialValueFor("percent_per_sec")

    self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		--damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	}

    -- UP 2.11
	if self.ability:GetRank(11) then
		self.ability:AddBonus("_2_REC", self.parent, -12, 0, nil)
	end

    -- UP 2.21
	if self.ability:GetRank(21) then
        blind = blind + 10
	end

	-- UP 2.23
	if self.ability:GetRank(23) then
		intervals = self.ability:GetSpecialValueFor("intervals") - 0.2
		self.percent = (self.ability:GetSpecialValueFor("percent_per_sec") + 0.5)
	end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("bocuse_2_modifier_status_efx", true) end

    self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = blind * 2, miss_chance = blind})
    self:StartIntervalThink(intervals)
end

function bocuse_2_modifier_flambee_debuff:OnRefresh(kv)
	-- UP 2.11
	if self.ability:GetRank(11) then
		self.ability:RemoveBonus("_2_REC", self.parent)
		self.ability:AddBonus("_2_REC", self.parent, -12, 0, nil)
	end

	-- UP 2.21
	if self.ability:GetRank(21) then
		local blind = self.ability:GetSpecialValueFor("blind") + 10
		local mod = self.parent:FindAllModifiersByName("_modifier_blind")
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self.ability then modifier:Destroy() end
		end

		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = blind * 2, miss_chance = blind})
	end

	-- UP 2.23
	if self.ability:GetRank(23) then
		local intervals = self.ability:GetSpecialValueFor("intervals") - 0.2
		self.percent = (self.ability:GetSpecialValueFor("percent_per_sec") + 0.5)
		self:StartIntervalThink(intervals)
	end
end

function bocuse_2_modifier_flambee_debuff:OnRemoved()
	self.ability:RemoveBonus("_2_REC", self.parent)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("bocuse_2_modifier_status_efx", false) end

	local mod = self.parent:FindAllModifiersByName("_modifier_blind")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

--------------------------------------------------------------------------------

function bocuse_2_modifier_flambee_debuff:OnIntervalThink()
    local amount = self.parent:GetMaxHealth() * self.percent * 0.01
	if self.parent:GetUnitName() == "boss_gorillaz" then amount = amount * 0.5 end
    self.damageTable.damage = amount
    local damage = ApplyDamage(self.damageTable)

	self:PlayEfxDamage()
end

--------------------------------------------------------------------------------
function bocuse_2_modifier_flambee_debuff:GetStatusEffectName()
	return "particles/econ/items/lifestealer/ls_ti9_immortal/status_effect_ls_ti9_open_wounds.vpcf"
end

function bocuse_2_modifier_flambee_debuff:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function bocuse_2_modifier_flambee_debuff:GetEffectName()
	return "particles/bocuse/bocuse_drunk_enemy.vpcf"
end

function bocuse_2_modifier_flambee_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function bocuse_2_modifier_flambee_debuff:PlayEfxDamage()
	if IsServer() then self.parent:EmitSound("Hero_OgreMagi.Ignite.Damage") end
end