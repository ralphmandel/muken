dasdingo_5_modifier_fire = class({})

function dasdingo_5_modifier_fire:IsHidden() return false end
function dasdingo_5_modifier_fire:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_5_modifier_fire:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
  self.total_damage = 0

  if IsServer() then
    self.parent:StopSound("Dasdingo.Fire.Loop")
    self.parent:EmitSound("Dasdingo.Fire.Loop")
    self:OnIntervalThink()
  end
end

function dasdingo_5_modifier_fire:OnRefresh(kv)
  if IsServer() then
    self.parent:StopSound("Dasdingo.Fire.Loop")
    self.parent:EmitSound("Dasdingo.Fire.Loop")
    self:ApplyFireDamage()
  end
end

function dasdingo_5_modifier_fire:OnRemoved()
  if IsServer() then self.parent:StopSound("Dasdingo.Fire.Loop") end
end

-- API FUNCTIONS -----------------------------------------------------------

function dasdingo_5_modifier_fire:OnIntervalThink()
	if IsServer() then
    self:ApplyFireDamage()
    self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
  end
end

-- UTILS -----------------------------------------------------------

function dasdingo_5_modifier_fire:ApplyFireDamage()
  local damageTable = {
    attacker = self.caster, victim = self.parent, ability = self.ability,
    damage = self.ability:GetSpecialValueFor("fire_damage"),
    damage_type = self.ability:GetAbilityDamageType()
  }

  self.total_damage = self.total_damage + ApplyDamage(damageTable)
  if IsServer() then self:SetStackCount(math.floor(self.total_damage)) end

  if self:GetStackCount() >= self.ability:GetSpecialValueFor("ignition_cap") then
    AddModifier(self.parent, self.caster, self.ability, "dasdingo_5_modifier_ignition", {
      duration = self.ability:GetSpecialValueFor("stun_duration"), step = 1
    }, true)
    self:Destroy()
  end
end

-- EFFECTS -----------------------------------------------------------

function dasdingo_5_modifier_fire:GetEffectName()
	return "particles/dasdingo/dasdingo_fire_debuff.vpcf"
end

function dasdingo_5_modifier_fire:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end