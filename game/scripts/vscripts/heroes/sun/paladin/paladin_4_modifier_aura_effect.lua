paladin_4_modifier_aura_effect = class({})

function paladin_4_modifier_aura_effect:IsHidden() return false end
function paladin_4_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_4_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.interval = self.ability:GetSpecialValueFor("interval")

  if IsServer() then self:StartIntervalThink(self.interval) end
end

function paladin_4_modifier_aura_effect:OnRefresh(kv)
end

function paladin_4_modifier_aura_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function paladin_4_modifier_aura_effect:CheckState()
	local state = {
		[MODIFIER_STATE_SILENCED] = true,
    [MODIFIER_STATE_DISARMED] = true,
	}

  if self:GetParent():IsMagicImmune() then state = {} end

	return state
end

function paladin_4_modifier_aura_effect:OnIntervalThink()
  if IsServer() then self.parent:EmitSound("Paladin.Magnus.Hit") end

  ApplyDamage({
    victim = self.parent, attacker = self.caster,
    damage = self.caster:GetMaxHealth() * self.ability:GetSpecialValueFor("damage_percent") * self.interval * 0.01,
    damage_type = self.ability:GetAbilityDamageType(),
    ability = self.ability
  })
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------