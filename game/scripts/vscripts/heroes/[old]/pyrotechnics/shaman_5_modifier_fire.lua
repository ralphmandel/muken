shaman_5_modifier_fire = class({})

function shaman_5_modifier_fire:IsHidden() return false end
function shaman_5_modifier_fire:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function shaman_5_modifier_fire:OnCreated(kv)
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
    self.parent:StopSound("shaman.Fire.Loop")
    self.parent:EmitSound("shaman.Fire.Loop")
    self:OnIntervalThink()
  end
end

function shaman_5_modifier_fire:OnRefresh(kv)
  if IsServer() then
    self.parent:StopSound("shaman.Fire.Loop")
    self.parent:EmitSound("shaman.Fire.Loop")
    ApplyDamage(self.damage_table)
  end
end

function shaman_5_modifier_fire:OnRemoved()
  if IsServer() then self.parent:StopSound("shaman.Fire.Loop") end
end

-- API FUNCTIONS -----------------------------------------------------------

function shaman_5_modifier_fire:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	
	return funcs
end

function shaman_5_modifier_fire:OnTakeDamage(keys)
  if keys.inflictor == self.ability then
    self.total_damage = self.total_damage + keys.original_damage
    
    if IsServer() then self:SetStackCount(math.floor(self.total_damage)) end

    if self:GetStackCount() >= self.ability:GetSpecialValueFor("ignition_cap") then
      AddModifier(self.parent, self.caster, self.ability, "shaman_5_modifier_ignition", {
        duration = self.ability:GetSpecialValueFor("slow_duration")
      }, true)
      self:Destroy()
    end
  end
end

function shaman_5_modifier_fire:OnIntervalThink()
	if IsServer() then
    ApplyDamage(self.damage_table)
    self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function shaman_5_modifier_fire:GetEffectName()
	return "particles/shaman/shaman_fire_debuff.vpcf"
end

function shaman_5_modifier_fire:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end