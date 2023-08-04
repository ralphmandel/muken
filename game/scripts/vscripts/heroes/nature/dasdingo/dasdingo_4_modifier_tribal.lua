dasdingo_4_modifier_tribal = class({})

function dasdingo_4_modifier_tribal:IsHidden() return false end
function dasdingo_4_modifier_tribal:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_4_modifier_tribal:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.hits = self.ability:GetSpecialValueFor("hits") * 4
  self.min_health = self.hits

  AddBonus(self.ability, "CON", self.parent, -9999, 0, nil)
  AddBonus(self.ability, "STR", self.parent, -9999, 0, nil)
  AddBonus(self.ability, "AGI", self.parent, 9999, 0, nil)

  self.parent:SetHealthBarOffsetOverride(300)

  Timers:CreateTimer(FrameTime(), function()
    self.parent:ModifyHealth(self.hits, self.ability, false, 0)
  end)

  if IsServer() then
    self.parent:StartGesture(ACT_DOTA_SPAWN)
    self:PlayEfxStart()
    self:StartIntervalThink(1)
  end
end

function dasdingo_4_modifier_tribal:OnRefresh(kv)
end

function dasdingo_4_modifier_tribal:OnRemoved()
  self.parent:FadeGesture(ACT_DOTA_IDLE)
  self.parent:StartGesture(ACT_DOTA_DIE)

  RemoveBonus(self.ability, "CON", self.parent)
  RemoveBonus(self.ability, "STR", self.parent)
  RemoveBonus(self.ability, "AGI", self.parent)
  self.ability.unit = nil

  if self.parent:IsAlive() then self.parent:Kill(self.ability, nil) end
end

-- API FUNCTIONS -----------------------------------------------------------

function dasdingo_4_modifier_tribal:CheckState()
	local state = {
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
		[MODIFIER_STATE_EVADE_DISABLED] = true,
		[MODIFIER_STATE_CANNOT_MISS] = true
	}

	return state
end

function dasdingo_4_modifier_tribal:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTHBAR_PIPS,
		MODIFIER_EVENT_ON_DEATH,
    MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    MODIFIER_PROPERTY_BONUS_DAY_VISION,
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    MODIFIER_EVENT_ON_ATTACK,
    MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
    MODIFIER_PROPERTY_ATTACK_RANGE_BASE_OVERRIDE
	}

	return funcs
end

function dasdingo_4_modifier_tribal:GetModifierHealthBarPips(keys)
	return self:GetParent():GetMaxHealth() / 4
end

function dasdingo_4_modifier_tribal:OnDeath(keys)
	if keys.unit == self.parent then self:Destroy() end
end

function dasdingo_4_modifier_tribal:GetModifierProcAttack_Feedback(keys)
	if self.parent:PassivesDisabled() then return end

  CreateModifierThinker(
    self.parent, self.ability, "dasdingo_4_modifier_bounce", {},
    keys.target:GetOrigin(), self.parent:GetTeamNumber(), false
  )
end

function dasdingo_4_modifier_tribal:OnAttacked(keys)
  if keys.attacker == self.parent then
		if IsServer() then keys.target:EmitSound("Hero_WitchDoctor_Ward.ProjectileImpact") end
	end

	if keys.target ~= self.parent then return end
  self.min_health = self.min_health - GetPipHitDamage(keys.attacker)
end

function dasdingo_4_modifier_tribal:GetDisableHealing()
	return 1
end

function dasdingo_4_modifier_tribal:GetMinHealth()
	return self.min_health
end

function dasdingo_4_modifier_tribal:GetModifierExtraHealthBonus()
	return self.hits - 1
end

function dasdingo_4_modifier_tribal:GetBonusDayVision()
	return 600
end

function dasdingo_4_modifier_tribal:GetBonusNightVision()
	return 450
end

function dasdingo_4_modifier_tribal:OnAttack(keys)
	if keys.attacker == self.parent then
		if self.ability.sound == nil then
			if IsServer() then self.parent:EmitSound("Hero_WitchDoctor_Ward.Attack") end
		end
	end
end

function dasdingo_4_modifier_tribal:GetModifierBaseAttack_BonusDamage()
  return BaseStats(self:GetCaster()):GetStatTotal("INT") * 2
end

function dasdingo_4_modifier_tribal:GetModifierAttackRangeOverride()
  return self:GetAbility():GetSpecialValueFor("atk_range")
end

function dasdingo_4_modifier_tribal:OnIntervalThink()
	if IsServer() then
    self.parent:StartGesture(ACT_DOTA_IDLE)
    self:StartIntervalThink(-1)
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function dasdingo_4_modifier_tribal:PlayEfxStart()
	local string = "particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healling_ward_fortunes_tout_hero_heal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
  ParticleManager:SetParticleControl(effect_cast, 2, self.parent:GetOrigin())
	self:AddParticle(effect_cast, false, false, -1, false, false)

  local string_2 = "particles/econ/items/treant_protector/ti7_shoulder/treant_ti7_golden_livingarmor.vpcf"
  self.armor_particle = ParticleManager:CreateParticle(string_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.armor_particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_origin", self.parent:GetAbsOrigin(), true)
	self:AddParticle(self.armor_particle, false, false, -1, false, false)

  local string_3 = "particles/units/heroes/hero_witchdoctor/witchdoctor_ward_skull_rubick.vpcf"
  self.wardParticle = ParticleManager:CreateParticle(string_3, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.wardParticle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_attack1", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.wardParticle, 2, self.parent:GetAbsOrigin())
	self:AddParticle(self.wardParticle, false, false, -1, false, false)

  if IsServer() then self.parent:EmitSound("Hero_WitchDoctor.Paralyzing_Cask_Cast") end
end