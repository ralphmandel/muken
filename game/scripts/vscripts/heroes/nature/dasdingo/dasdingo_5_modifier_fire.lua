dasdingo_5_modifier_fire = class({})

function dasdingo_5_modifier_fire:IsHidden() return false end
function dasdingo_5_modifier_fire:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_5_modifier_fire:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
  self.total_damage = 0

  self.damage_table = {
    attacker = self.caster, victim = self.parent, ability = self.ability,
    damage = self.ability:GetSpecialValueFor("fire_damage"),
    damage_type = self.ability:GetAbilityDamageType()
  }

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
    ApplyDamage(self.damage_table)
  end
end

function dasdingo_5_modifier_fire:OnRemoved()
  if IsServer() then self.parent:StopSound("Dasdingo.Fire.Loop") end
end

-- API FUNCTIONS -----------------------------------------------------------

function dasdingo_5_modifier_fire:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	
	return funcs
end

function dasdingo_5_modifier_fire:OnTakeDamage(keys)
  if keys.inflictor == self.ability then
    self.total_damage = self.total_damage + keys.original_damage
    
    if IsServer() then self:SetStackCount(math.floor(self.total_damage)) end

    if self:GetStackCount() >= self.ability:GetSpecialValueFor("ignition_cap") then
      AddModifier(self.parent, self.caster, self.ability, "dasdingo_5_modifier_ignition", {
        duration = self.ability:GetSpecialValueFor("stun_duration"), step = 1
      }, true)
      self:Destroy()
    end
  end
end

function dasdingo_5_modifier_fire:OnIntervalThink()
	if IsServer() then
    ApplyDamage(self.damage_table)
    self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function dasdingo_5_modifier_fire:GetEffectName()
	return "particles/dasdingo/dasdingo_fire_debuff.vpcf"
end

function dasdingo_5_modifier_fire:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end