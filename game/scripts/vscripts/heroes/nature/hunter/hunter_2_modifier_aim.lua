hunter_2_modifier_aim = class({})

function hunter_2_modifier_aim:IsHidden() return false end
function hunter_2_modifier_aim:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_2_modifier_aim:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.knockback_duration = self.ability:GetSpecialValueFor("knockback_duration")
  self.knockback_distance = self.ability:GetSpecialValueFor("knockback_distance")

  AddBonus(self.ability, "DEX", self.parent, self.ability:GetSpecialValueFor("dex"), 0, nil)
  AddBonus(self.ability, "DEF", self.parent, self.ability:GetSpecialValueFor("def"), 0, nil)
  AddBonus(self.ability, "RES", self.parent, self.ability:GetSpecialValueFor("res"), 0, nil)
  AddBonus(self.ability, "LCK", self.parent, self.ability:GetSpecialValueFor("lck"), 0, nil)
  AddBonus(self.ability, "AGI", self.parent, self.ability:GetSpecialValueFor("agi"), 0, nil)

  if IsServer() then self:SetStackCount(self.ability:GetSpecialValueFor("hits")) end
end

function hunter_2_modifier_aim:OnRemoved()
  RemoveBonus(self.ability, "DEX", self.parent)
  RemoveBonus(self.ability, "DEF", self.parent)
  RemoveBonus(self.ability, "RES", self.parent)
  RemoveBonus(self.ability, "LCK", self.parent)
  RemoveBonus(self.ability, "AGI", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_2_modifier_aim:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function hunter_2_modifier_aim:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("ms_limit")
end

function hunter_2_modifier_aim:OnAttackLanded(keys)
  if not IsServer() then return end
	if keys.attacker ~= self.parent then return end
  if self:GetStackCount() == 0 then return end

  if BaseStats(self.parent).has_crit == true then
    RemoveAllModifiersByNameAndAbility(keys.target, "modifier_knockback", self.ability)
    local modifier = AddModifier(keys.target, self.ability, "modifier_knockback", {
      center_x = self.parent:GetAbsOrigin().x + 1,
      center_y = self.parent:GetAbsOrigin().y + 1,
      center_z = self.parent:GetAbsOrigin().z,
      duration = self.knockback_duration,
      knockback_duration = CalcStatus(self.knockback_duration, self.caster, keys.target),
      knockback_distance = CalcStatus(self.knockback_distance, self.caster, keys.target),
      knockback_height = 0
    }, true)

    self:PlayEfxHit(keys.target, modifier)
  end

  self:DecrementStackCount()

  if self:GetStackCount() > 0 then
    self:SetDuration(self.ability:GetSpecialValueFor("duration"), true)
  else
    RemoveBonus(self.ability, "LCK", self.parent)
    RemoveBonus(self.ability, "AGI", self.parent)
    self:StartIntervalThink(1)
  end
end

-- UTILS -----------------------------------------------------------

function hunter_2_modifier_aim:OnIntervalThink()
  self:Destroy()
  -- local loc = "Vector(" .. math.floor(self.parent:GetOrigin().x) .. ", " .. math.floor(self.parent:GetOrigin().y) .. ", 0)"
  -- print(loc)
end

-- EFFECTS -----------------------------------------------------------

function hunter_2_modifier_aim:GetEffectName()
	return "particles/items2_fx/mask_of_madness.vpcf"
end

function hunter_2_modifier_aim:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function hunter_2_modifier_aim:PlayEfxHit(target, modifier)
  if modifier then
    local string = "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
    local particle = ParticleManager:CreateParticle(string, PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetOrigin())
    modifier:AddParticle(particle, false, false, -1, false, false)
  end

	if IsServer() then target:EmitSound("Hero_Sniper.HeadShot") end
end