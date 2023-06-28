genuine_5_modifier_barrier = class({})

function genuine_5_modifier_barrier:IsHidden() return true end
function genuine_5_modifier_barrier:IsPurgable() return false end
function genuine_5_modifier_barrier:RemoveOnDeath() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_5_modifier_barrier:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.interval = 0.1
  self.invi = false

  if IsServer() then
    self.max_barrier = self.ability:GetMaxBarrier()
    self.barrier = self.ability:GetMaxBarrier()
    self:SetStackCount(self.barrier)
    self:StartIntervalThink(self.interval)
  end
end

function genuine_5_modifier_barrier:OnRefresh(kv)
end

function genuine_5_modifier_barrier:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_invisible", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_5_modifier_barrier:CheckState()
	local state = {}

  if self:GetAbility():GetSpecialValueFor("special_fly_vision") == 1 then
		table.insert(state, MODIFIER_STATE_FORCED_FLYING_VISION , true)
	end

	return state
end

function genuine_5_modifier_barrier:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT,
    MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT,
    MODIFIER_PROPERTY_ABSORB_SPELL
	}
	
	return funcs
end

function genuine_5_modifier_barrier:GetModifierConstantHealthRegen()
  return self.max_barrier * self:GetAbility():GetSpecialValueFor("barrier_regen") * 0.01 * self:GetAbility():GetSpecialValueFor("special_hp_regen")
end

function genuine_5_modifier_barrier:GetModifierIncomingSpellDamageConstant(keys)
  if self:GetAbility():GetSpecialValueFor("special_universal") == 1 then return nil end

  if not IsServer() then
    return self:GetStackCount()
  end

  local damage = keys.original_damage
  self.barrier = self.barrier - damage

  if self.barrier < 0 then
    damage = damage + self.barrier
    self.barrier = 0
  end

  self:UpdateBarrier(0, false)

  return -damage
end

function genuine_5_modifier_barrier:GetModifierIncomingDamageConstant(keys)
  if self:GetAbility():GetSpecialValueFor("special_universal") == 0 then return nil end
  
  if not IsServer() then
    return self:GetStackCount()
  end

  local damage = keys.original_damage
  self.barrier = self.barrier - damage

  if self.barrier < 0 then
    damage = damage + self.barrier
    self.barrier = 0
  end

  self:UpdateBarrier(0, false)

  return -damage
end

function genuine_5_modifier_barrier:GetAbsorbSpell(keys)
  if self.parent:PassivesDisabled() then return 0 end
  
	if self.ability:GetSpecialValueFor("special_linkens") == 1
  and self.ability:IsCooldownReady() then
    self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
    self:PlayEfxBlockSpell()
    return 1
  end

	return 0
end

function genuine_5_modifier_barrier:OnIntervalThink()
  if IsServer() then
    if self.barrier < self.max_barrier then
      self:UpdateBarrier(self.max_barrier * self.ability:GetSpecialValueFor("barrier_regen") * self.interval * 0.01, true)
    end

    if self.ability:GetSpecialValueFor("special_invi") == 1 then
      self:ApplyInvisibility()
    end

    self:StartIntervalThink(self.interval)
  end
end

-- UTILS -----------------------------------------------------------

function genuine_5_modifier_barrier:UpdateBarrier(value, isRegen)
  if self.barrier + value > self.max_barrier then value = self.max_barrier - self.barrier end

  if isRegen == true and self.ability:GetSpecialValueFor("special_hp_regen") == 1 then
    self.parent:ModifyHealth(self.parent:GetHealth() + value, self.ability, false, 0)
  end

  self.barrier = self.barrier + value
  self:SetStackCount(self.barrier)
  self:SendBuffRefreshToClients()
end

function genuine_5_modifier_barrier:ApplyInvisibility()
  if self.parent:FindModifierByNameAndCaster("_modifier_invisible", self.caster) == nil then
    if self.invi == true then
      self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
      self.invi = false
    else
      if self.ability:IsCooldownReady() then
        if IsServer() then self.parent:EmitSound("DOTA_Item.InvisibilitySword.Activate") end
        AddModifier(self.parent, self.caster, self.ability, "_modifier_invisible", {
          delay = 1, spell_break = 1
        }, false)
        self.invi = true
      end
    end
  end
end

-- EFFECTS -----------------------------------------------------------

function genuine_5_modifier_barrier:PlayEfxBlockSpell()
	local string = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("Item.LotusOrb.Target") end
end