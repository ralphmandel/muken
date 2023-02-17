bocuse_2_modifier_flambee = class({})

function bocuse_2_modifier_flambee:IsHidden() return false end
function bocuse_2_modifier_flambee:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_2_modifier_flambee:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.intervals = self.ability:GetSpecialValueFor("intervals")

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bocuse_2_modifier_flambee_status_efx", true) end

	self:ApplyBuffs()
	self:ApplyDebuffs()

	if IsServer() then self:StartIntervalThink(self.intervals) end
end

function bocuse_2_modifier_flambee:OnRefresh(kv)
	self:ApplyBuffs()
	self:ApplyDebuffs()
end

function bocuse_2_modifier_flambee:OnRemoved()
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bocuse_2_modifier_flambee_status_efx", false) end

	if IsServer() then self.parent:StopSound("Bocuse.Flambee.Buff") end

	local mod = self.parent:FindAllModifiersByName("_modifier_blind")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_2_modifier_flambee:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
	}

	return funcs
end

function bocuse_2_modifier_flambee:GetModifierStatusResistanceStacking()
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then
		return self:GetAbility():GetSpecialValueFor("effect_resist")
	end

	return 0
end

function bocuse_2_modifier_flambee:OnIntervalThink()
	local amount = self.intervals * self.parent:GetMaxHealth() * self.ability:GetSpecialValueFor("amount_percent") * 0.01

	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then
		self.parent:Heal(amount, self.ability)
	else
		if IsServer() then
			self.parent:EmitSound("Hero_OgreMagi.Ignite.Damage")
		end

		ApplyDamage({
			attacker = self.caster, victim = self.parent,
			damage = amount, damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability
		})
	end
end

-- UTILS -----------------------------------------------------------

function bocuse_2_modifier_flambee:ApplyBuffs()
	if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end

	if self.ability:GetSpecialValueFor("special_init") == 1 then
		self.parent:Purge(false, true, false, true, false)
	end

	if IsServer() then
		self.parent:StopSound("Bocuse.Flambee.Buff")
		self.parent:EmitSound("Bocuse.Flambee.Buff")
	end
end

function bocuse_2_modifier_flambee:ApplyDebuffs()
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then return end

	if self.ability:GetSpecialValueFor("special_init") == 1 then
		self.parent:Purge(true, false, false, false, false)
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_blind")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {
		percent = self.ability:GetSpecialValueFor("effect_blind")
	})
end

-- EFFECTS -----------------------------------------------------------

function bocuse_2_modifier_flambee:GetStatusEffectName()
	return "particles/econ/items/lifestealer/ls_ti9_immortal/status_effect_ls_ti9_open_wounds.vpcf"
end

function bocuse_2_modifier_flambee:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function bocuse_2_modifier_flambee:GetEffectName()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return "particles/bocuse/bocuse_drunk_ally_crit.vpcf"
	else
		return "particles/bocuse/bocuse_drunk_enemy.vpcf"
	end
end

function bocuse_2_modifier_flambee:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end