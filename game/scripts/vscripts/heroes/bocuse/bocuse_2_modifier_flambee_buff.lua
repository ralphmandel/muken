bocuse_2_modifier_flambee_buff = class ({})

function bocuse_2_modifier_flambee_buff:IsHidden()
    return false
end

function bocuse_2_modifier_flambee_buff:IsPurgable()
    return true
end

-----------------------------------------------------------

function bocuse_2_modifier_flambee_buff:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local ms = self.ability:GetSpecialValueFor("ms")
    local intervals = self.ability:GetSpecialValueFor("intervals")
    self.percent = self.ability:GetSpecialValueFor("percent_per_sec") * intervals

    -- UP 2.13
	if self.ability:GetRank(13) then
		self.ability:AddBonus("_2_REC", self.parent, 12, 0, nil)
	end

	-- UP 2.21
	if self.ability:GetRank(21) then
		ms = self.ability:GetSpecialValueFor("ms") + 10
	end

	-- UP 2.11
	if self.ability:GetRank(11) then
		self.percent = (self.ability:GetSpecialValueFor("percent_per_sec") + 0.5) * intervals
	end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = ms})

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("bocuse_2_modifier_status_efx", true) end

	self:PlayEfxStart()
    self:StartIntervalThink(intervals)
end

function bocuse_2_modifier_flambee_buff:OnRefresh(kv)
	-- UP 2.13
	if self.ability:GetRank(13) then
		self.ability:RemoveBonus("_2_REC", self.parent)
		self.ability:AddBonus("_2_REC", self.parent, 12, 0, nil)
	end

	-- UP 2.21
	if self.ability:GetRank(21) then
		local ms = self.ability:GetSpecialValueFor("ms") + 10
		local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self.ability then modifier:Destroy() end
		end

		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = ms})
	end

	-- UP 2.11
	if self.ability:GetRank(11) then
		local intervals = self.ability:GetSpecialValueFor("intervals")
		self.percent = (self.ability:GetSpecialValueFor("percent_per_sec") + 0.5) * intervals
	end
end

function bocuse_2_modifier_flambee_buff:OnRemoved()
	self.ability:RemoveBonus("_2_REC", self.parent)
	if IsServer() then self.parent:StopSound("Bocuse.Flambee.Buff") end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("bocuse_2_modifier_status_efx", false) end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

--------------------------------------------------------------------------------

function bocuse_2_modifier_flambee_buff:OnIntervalThink()
    local amount = self.parent:GetMaxHealth() * self.percent * 0.01
    if amount > 0 then self.parent:Heal(amount, self.ability) end
end

--------------------------------------------------------------------------------

function bocuse_2_modifier_flambee_buff:GetStatusEffectName()
	return "particles/econ/items/lifestealer/ls_ti9_immortal/status_effect_ls_ti9_open_wounds.vpcf"
end

function bocuse_2_modifier_flambee_buff:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function bocuse_2_modifier_flambee_buff:GetEffectName()
	return "particles/bocuse/bocuse_drunk_ally_crit.vpcf"
end

function bocuse_2_modifier_flambee_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function bocuse_2_modifier_flambee_buff:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Bocuse.Flambee.Buff") end
end