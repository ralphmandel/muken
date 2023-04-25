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

  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_blind", self.ability)

	if IsServer() then self.parent:StopSound("Bocuse.Flambee.Buff") end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_2_modifier_flambee:OnIntervalThink()
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then
    local mana_amount = self.ability:GetSpecialValueFor("mana") * BaseStats(self.caster):GetHealPower()
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self.parent, mana_amount, self.caster)
		self.parent:GiveMana(mana_amount)
	else
		if IsServer() then self.parent:EmitSound("Hero_OgreMagi.Ignite.Damage") end
    ApplyDamage({
      attacker = self.caster, victim = self.parent,
      damage = self.ability:GetSpecialValueFor("damage"),
      damage_type = self.ability:GetAbilityDamageType(),
      ability = self.ability
    })
	end
  if IsServer() then self:StartIntervalThink(self.intervals) end
end

-- UTILS -----------------------------------------------------------

function bocuse_2_modifier_flambee:ApplyBuffs()
	if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end

	if self.ability:GetSpecialValueFor("special_purge_allies") == 1 then
		self.parent:Purge(false, true, false, true, false)
	end

  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {
		percent = self.ability:GetSpecialValueFor("ms")
	})

	if IsServer() then
		self.parent:StopSound("Bocuse.Flambee.Buff")
		self.parent:EmitSound("Bocuse.Flambee.Buff")
	end
end

function bocuse_2_modifier_flambee:ApplyDebuffs()
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then return end

	if self.ability:GetSpecialValueFor("special_purge_enemies") == 1 then
		self.parent:Purge(true, false, false, false, false)
	end

  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_blind", self.ability)
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {percent = self.ability:GetSpecialValueFor("blind")})
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