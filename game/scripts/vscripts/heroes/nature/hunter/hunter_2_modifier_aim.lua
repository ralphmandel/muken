hunter_2_modifier_aim = class({})

function hunter_2_modifier_aim:IsHidden() return true end
function hunter_2_modifier_aim:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_2_modifier_aim:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.shot = false

  self.timer = AddModifier(self.parent, self.ability, "hunter_2_modifier_timer", {
    duration = self.ability:GetSpecialValueFor("duration")
  }, false)

  self.timer:SetEndCallback(function(interrupted) self:CheckTimer() end)

  self.knockback_duration = self.ability:GetSpecialValueFor("knockback_duration")
  self.knockback_distance = self.ability:GetSpecialValueFor("knockback_distance")

  AddBonus(self.ability, "DEX", self.parent, self.ability:GetSpecialValueFor("dex"), 0, nil)
  AddBonus(self.ability, "DEF", self.parent, self.ability:GetSpecialValueFor("def"), 0, nil)
  AddBonus(self.ability, "RES", self.parent, self.ability:GetSpecialValueFor("res"), 0, nil)
  AddBonus(self.ability, "LCK", self.parent, self.ability:GetSpecialValueFor("lck"), 0, nil)
  AddBonus(self.ability, "AGI", self.parent, self.ability:GetSpecialValueFor("agi"), 0, nil)  
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
    MODIFIER_EVENT_ON_ATTACK,
    MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function hunter_2_modifier_aim:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("ms_limit")
end

function hunter_2_modifier_aim:OnAttack(keys)
	if keys.attacker ~= self.parent then return end

  if self.timer then
    local duration = self.timer:GetDuration() * self.ability:GetSpecialValueFor("buff_time_update") * 0.01
    self.shot = true
    self.parent:RemoveModifierByName("hunter_2_modifier_timer")
    self.shot = false
    self.timer = AddModifier(self.parent, self.ability, "hunter_2_modifier_timer", {duration = duration}, false)
    self.timer:SetEndCallback(function(interrupted)
      self:CheckTimer()
    end)
  else
    self:Destroy()
  end
end

function hunter_2_modifier_aim:OnAttackLanded(keys)
  if not IsServer() then return end
	if keys.attacker ~= self.parent then return end

  if BaseStats(self.parent).has_crit == true then
    keys.target:RemoveModifierByNameAndCaster("modifier_knockback", self.caster)
    local modifier = AddModifier(keys.target, self.ability, "modifier_knockback", {
      center_x = self.parent:GetAbsOrigin().x + 1,
      center_y = self.parent:GetAbsOrigin().y + 1,
      center_z = self.parent:GetAbsOrigin().z,
      duration = self.knockback_duration,
      knockback_duration = CalcStatus(self.knockback_duration, self.caster, keys.target),
      knockback_distance = CalcStatus(self.knockback_distance, self.caster, keys.target),
      knockback_height = 0
    }, true)

    if IsServer() then self:PlayEfxHit(keys.target, modifier) end
  end
end

function hunter_2_modifier_aim:OnIntervalThink()
  -- local loc = "Vector(" .. math.floor(self.parent:GetOrigin().x) .. ", " .. math.floor(self.parent:GetOrigin().y) .. ", 0)"
  -- print(loc)
end

-- UTILS -----------------------------------------------------------

function hunter_2_modifier_aim:CheckTimer()
  if self.shot == true then
    self.timer = nil
  else
    self:Destroy()
  end
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