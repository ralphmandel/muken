baldur_5_modifier_fire = class({})

function baldur_5_modifier_fire:IsHidden() return false end
function baldur_5_modifier_fire:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function baldur_5_modifier_fire:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  local interval = self.ability:GetSpecialValueFor("interval")

  AddBonus(self.ability, "STR", self.parent, self.ability:GetSpecialValueFor("str"), 0, nil)

  self.damageTable = {
    victim = self.parent, attacker = self.caster,
    damage = self.ability:GetSpecialValueFor("damage_burn") * interval,
    damage_type = self.ability:GetAbilityDamageType(),
    ability = self.ability
  }

  if IsServer() then
    self.parent:EmitSound("Dasdingo.Ignite.Loop")
    self:StartIntervalThink(interval)
  end
end

function baldur_5_modifier_fire:OnRefresh(kv)
end

function baldur_5_modifier_fire:OnRemoved()
  if IsServer() then self.parent:StopSound("Dasdingo.Ignite.Loop") end
  RemoveBonus(self.ability, "STR", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function baldur_5_modifier_fire:OnIntervalThink()
  ApplyDamage(self.damageTable)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function dasdingo_3_modifier_ignition:GetEffectName()
	return "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff.vpcf"
	--return "particles/dasdingo/dasdingo_fire_debuff.vpcf"
end

function dasdingo_3_modifier_ignition:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end