lawbreaker_u_modifier_form = class({})

function lawbreaker_u_modifier_form:IsHidden() return false end
function lawbreaker_u_modifier_form:IsPurgable() return false end
function lawbreaker_u_modifier_form:GetPriority() return MODIFIER_PRIORITY_ULTRA end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_u_modifier_form:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.transforming = 1
  self.main_target = nil
	self.proc_target = nil

  self.vision_range = self.ability:GetSpecialValueFor("vision_range")
  self.ability:SetActivated(false)

  AddModifier(self.parent, self.caster, self.ability, "lawbreaker_u_modifier_sequence", {}, false)

  if IsServer() then
    self:StartIntervalThink(self.ability:GetSpecialValueFor("transform_duration"))
    self:PlayEfxStart()
  end
end

function lawbreaker_u_modifier_form:OnRefresh(kv)
end

function lawbreaker_u_modifier_form:OnRemoved()
  self.ability:SetActivated(true)
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker_u_modifier_form:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = false,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}

  if self.transforming == 1 then
		table.insert(state, MODIFIER_STATE_STUNNED, true)
	end

	return state
end

function lawbreaker_u_modifier_form:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_BONUS_DAY_VISION,
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		--MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
    MODIFIER_PROPERTY_ALWAYS_ALLOW_ATTACK,
    MODIFIER_EVENT_ON_ATTACKED,
    MODIFIER_EVENT_ON_ATTACK_START,
    MODIFIER_EVENT_ON_ATTACK
	}

	return funcs
end

function lawbreaker_u_modifier_form:GetBonusDayVision()
	return self.vision_range
end

function lawbreaker_u_modifier_form:GetBonusNightVision()
	return self.vision_range
end

-- function lawbreaker_u_modifier_form:GetModifierModelChange()
-- 	return "models/heroes/muerta/muerta_ult.vmdl"
-- end

function lawbreaker_u_modifier_form:GetModifierModelScale()
	return self:GetAbility():GetSpecialValueFor("model_scale")
end

function lawbreaker_u_modifier_form:GetModifierProjectileName()
	return "particles/units/heroes/hero_muerta/muerta_ultimate_projectile.vpcf"
end

function lawbreaker_u_modifier_form:GetModifierAttackRangeBonus()
  return self:GetAbility():GetSpecialValueFor("atk_range")
end

function lawbreaker_u_modifier_form:GetAttackSound()
	return "Hero_Muerta.PierceTheVeil.Attack"
end

function lawbreaker_u_modifier_form:GetAlwaysAllowAttack(keys)
  return 1
end

function lawbreaker_u_modifier_form:OnAttacked(keys)
  if keys.attacker ~= self.parent then return end
  if keys.target:IsMagicImmune() then return end

  RemoveAllModifiersByNameAndAbility(keys.target, "_modifier_break", self.ability)

  AddModifier(keys.target, self.caster, self.ability, "_modifier_stun", {duration = 0.1}, true)
  AddModifier(keys.target, self.caster, self.ability, "_modifier_break", {
    duration = self.ability:GetSpecialValueFor("break_duration")
  }, true)
end

function lawbreaker_u_modifier_form:OnAttackStart(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == keys.attacker:GetTeamNumber() then return end

  if IsServer() then self:PlayEfxHit() end

	self.main_target = keys.target
	self.proc_target = nil

  local enemies = FindUnitsInRadius(
    self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil,
    self.parent:Script_GetAttackRange(),
    self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
    self.ability:GetAbilityTargetFlags(), 0, false
  )

	for _,enemy in pairs(enemies) do
    if self.main_target:IsHero() and enemy:IsHero() then
      if enemy ~= self.main_target then
        self.proc_target = enemy
        self.parent:FadeGesture(ACT_DOTA_ATTACK)
        self.parent:StartGesture(ACT_DOTA_ATTACK)
        self.parent:SetSequence(self:GetSequenceName(enemy))
        print("~ kubito", self.parent:GetSequence())
        return
      end
    end
	end

  for _,enemy in pairs(enemies) do
    if enemy ~= self.main_target then
      self.proc_target = enemy
      self.parent:FadeGesture(ACT_DOTA_ATTACK)
      self.parent:StartGesture(ACT_DOTA_ATTACK)
      self.parent:SetSequence(self:GetSequenceName(enemy))
      print("~ kubito", self.parent:GetSequence())
      return
    end
	end
end

function lawbreaker_u_modifier_form:OnAttack(keys)
	if keys.attacker ~= self.parent then return end
	if self.proc_target == nil then return end
	if keys.no_attack_cooldown then return end

	local target = self.proc_target
	self.proc_target = nil
	self.main_target = nil

  self.parent:PerformAttack(target, true, true, true, false, true, false, false)

  if IsServer() then self.parent:EmitSound("Hero_Muerta.Attack.DoubleShot") end
end

function lawbreaker_u_modifier_form:OnIntervalThink()
  self.transforming = 0

  if IsServer() then self:StartIntervalThink(-1) end
end

-- UTILS -----------------------------------------------------------

function lawbreaker_u_modifier_form:GetAS()
  --local attack_speed1 = 100 + (BaseStats(self.parent):GetSpecialValueFor("attack_speed") * (BaseStats(self.parent):GetStatTotal("_1_AGI") + 1))
  local attack_speed = (BaseStats(self.parent):GetStatTotal("AGI") + 1)
  attack_speed = 100 + (BaseStats(self.parent):GetSpecialValueFor("attack_speed") * attack_speed)
  return attack_speed / 100 * BaseStats(self.parent):GetSpecialValueFor("base_attack_time")
end

function lawbreaker_u_modifier_form:GetSequenceName(target)
  local angle = VectorToAngles(target:GetOrigin() - self.parent:GetOrigin()).y
  local angle_diff = AngleDiff(self.parent:GetAngles().y, angle)
  local string_side = ""
  local string_angle = 0

  if angle_diff >= -180 then
    string_side = "r"
    string_angle = 180
  end
  if angle_diff >= -157.5 then
    string_side = "r"
    string_angle = 135
  end
  if angle_diff >= -112.5 then
    string_side = "r"
    string_angle = 90
  end
  if angle_diff >= -67.5 then
    string_side = "r"
    string_angle = 45
  end
  if angle_diff >= -22.5 then
    string_side = ""
    string_angle = 0
  end
  if angle_diff >= 22.5 then
    string_side = "l"
    string_angle = 45
  end
  if angle_diff >= 67.5 then
    string_side = "l"
    string_angle = 90
  end
  if angle_diff >= 112.5 then
    string_side = "l"
    string_angle = 135
  end
  if angle_diff >= 157.5 then
    string_side = "l"
    string_angle = 180
  end

  local sequence_name = "@muerta_double_shot_right_"..string_side..string_angle
  --print("kubito", sequence_name)
  return sequence_name
end

-- EFFECTS -----------------------------------------------------------

function lawbreaker_u_modifier_form:GetEffectName()
	return "particles/units/heroes/hero_muerta/muerta_ultimate_form_ethereal.vpcf"
end

function lawbreaker_u_modifier_form:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function lawbreaker_u_modifier_form:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_muerta/muerta_ultimate_form_screen_effect.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(1,0,0))
	self:AddParticle(effect_cast, false, false, -1, false, false)

  if IsServer() then self.parent:EmitSound("Hero_Muerta.PierceTheVeil.Cast") end
end

function lawbreaker_u_modifier_form:PlayEfxEnd()
	local particle_cast = "particles/units/heroes/hero_muerta/muerta_ultimate_form_finish.vpcf"
	local sound_cast = "Hero_Muerta.PierceTheVeil.End"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:ReleaseParticleIndex(effect_cast)

  if IsServer() then self.parent:EmitSound("Hero_Muerta.PierceTheVeil.End") end
end

function lawbreaker_u_modifier_form:PlayEfxHit()
	local particle_cast = "particles/units/heroes/hero_muerta/muerta_gunslinger.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW,self.parent)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end