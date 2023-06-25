bocuse_2_modifier_flambee = class({})

function bocuse_2_modifier_flambee:IsHidden() return false end
function bocuse_2_modifier_flambee:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_2_modifier_flambee:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.intervals = self.ability:GetSpecialValueFor("intervals")

  AddStatusEfx(self.ability, "bocuse_2_modifier_flambee_status_efx", self.caster, self.parent)

	self:ApplyBuffs()
	self:ApplyDebuffs()

	if IsServer() then self:StartIntervalThink(self.intervals) end
end

function bocuse_2_modifier_flambee:OnRefresh(kv)
	self:ApplyBuffs()
	self:ApplyDebuffs()
end

function bocuse_2_modifier_flambee:OnRemoved()
  RemoveStatusEfx(self.ability, "bocuse_2_modifier_flambee_status_efx", self.caster, self.parent)

  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_blind", self.ability)

	if IsServer() then self.parent:StopSound("Bocuse.Flambee.Buff") end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_2_modifier_flambee:OnIntervalThink()
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then
    local mana_amount = self.ability:GetSpecialValueFor("mana") * BaseStats(self.caster):GetHealPower()
    IncreaseMana(self.parent, mana_amount)
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

  AddModifier(self.parent, self.caster, self.ability, "_modifier_movespeed_buff", {
    percent = self.ability:GetSpecialValueFor("ms")
  }, false)

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
  AddModifier(self.parent, self.caster, self.ability, "_modifier_blind", {
    percent = self.ability:GetSpecialValueFor("blind")
  }, false)
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