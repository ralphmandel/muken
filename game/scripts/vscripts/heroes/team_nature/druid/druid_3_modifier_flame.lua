druid_3_modifier_flame = class({})

function druid_3_modifier_flame:IsHidden() return false end
function druid_3_modifier_flame:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_3_modifier_flame:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.interval = 0.25

  AddModifier(self.parent, self.caster, self.ability, "_modifier_movespeed_debuff", {
    percent = self.ability:GetSpecialValueFor("special_flame_slow")
  }, false)

	if IsServer() then
		self.parent:EmitSound("Hero_Huskar.Burning_Spear")
    self:StartIntervalThink(self.interval)
	end
end

function druid_3_modifier_flame:OnRefresh(kv)
  if IsServer() then
    self.parent:StopSound("Hero_Huskar.Burning_Spear")
    self.parent:EmitSound("Hero_Huskar.Burning_Spear")
  end
end

function druid_3_modifier_flame:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_debuff", self.ability)
  if IsServer() then self.parent:StopSound("Hero_Huskar.Burning_Spear") end
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_3_modifier_flame:OnIntervalThink()
  ApplyDamage({
    attacker = self.caster, victim = self.parent,
    damage = self.ability:GetSpecialValueFor("special_flame_damage") * self.interval,
    damage_type = DAMAGE_TYPE_MAGICAL,
    ability = self.ability
  })

  if IsServer() then self:StartIntervalThink(self.interval) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_3_modifier_flame:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function druid_3_modifier_flame:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
