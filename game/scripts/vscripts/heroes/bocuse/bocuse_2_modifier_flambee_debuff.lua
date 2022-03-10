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
    self.percent = self.ability:GetSpecialValueFor("percent_per_sec") * intervals

    self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		--damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	}

    -- UP 2.3
	if self.ability:GetRank(3) then
		self.ability:AddBonus("_2_REC", self.parent, -12, 0, nil)
	end

    -- UP 2.4
	if self.ability:GetRank(4) then
        blind = blind + 10
	end

	-- UP 2.5
	if self.ability:GetRank(5) then
		self.percent = (self.ability:GetSpecialValueFor("percent_per_sec") + 1.5) * intervals
	end

    self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = blind * 2, miss_chance = blind})
    self:StartIntervalThink(intervals)
end

function bocuse_2_modifier_flambee_debuff:OnRefresh(kv)
	-- UP 2.3
	if self.ability:GetRank(3) then
		self.ability:RemoveBonus("_2_REC", self.parent)
		self.ability:AddBonus("_2_REC", self.parent, -12, 0, nil)
	end

	-- UP 2.4
	if self.ability:GetRank(4) then
		local blind = self.ability:GetSpecialValueFor("blind") + 10
		local mod = self.parent:FindAllModifiersByName("_modifier_blind")
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self.ability then modifier:Destroy() end
		end

		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = blind * 2, miss_chance = blind})
	end

	-- UP 2.5
	if self.ability:GetRank(5) then
		local intervals = self.ability:GetSpecialValueFor("intervals")
		self.percent = (self.ability:GetSpecialValueFor("percent_per_sec") + 1.5) * intervals
	end
end

function bocuse_2_modifier_flambee_debuff:OnRemoved()
	self.ability:RemoveBonus("_2_REC", self.parent)

	local mod = self.parent:FindAllModifiersByName("_modifier_blind")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

--------------------------------------------------------------------------------

function bocuse_2_modifier_flambee_debuff:OnIntervalThink()
    local amount = self.parent:GetMaxHealth() * self.percent * 0.01
    self.damageTable.damage = amount
    local damage = math.floor(ApplyDamage(self.damageTable))

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