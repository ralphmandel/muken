icebreaker_u_modifier_aura = class({})

function icebreaker_u_modifier_aura:IsHidden() return false end
function icebreaker_u_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function icebreaker_u_modifier_aura:IsAura() return true end
function icebreaker_u_modifier_aura:GetModifierAura() return "icebreaker_u_modifier_aura_effect" end
function icebreaker_u_modifier_aura:GetAuraRadius() return self:GetParent():GetCurrentVisionRange() end
function icebreaker_u_modifier_aura:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function icebreaker_u_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function icebreaker_u_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end

function icebreaker_u_modifier_aura:GetAuraEntityReject(hEntity)
  if self:GetCaster():GetTeamNumber() == hEntity:GetTeamNumber() then
    if self:GetAbility():GetSpecialValueFor("special_res_allies") == 0 then
      if self:GetCaster() ~= hEntity then return true end
    else
      if hEntity:IsHero() == false then return true end
    end
  end

  return self:GetParent() == hEntity
end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_u_modifier_aura:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.radius_day = self.ability:GetSpecialValueFor("radius_day")
  self.radius_night = self.ability:GetSpecialValueFor("radius_night")
  self.radius_percent = self.ability:GetSpecialValueFor("special_radius")
  self.hits = self.ability:GetSpecialValueFor("hits") * 4
  
  self.damageTable = {
    attacker = self.caster,
    damage = self.ability:GetSpecialValueFor("special_meteor_damage"),
    damage_type = self.ability:GetAbilityDamageType(),
    ability = self.ability
  }

  AddBonus(self.ability, "_1_CON", self.parent, -9999, 0, nil)
  if self.radius_percent > 0 then self.parent:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY) end

  Timers:CreateTimer(FrameTime(), function()
    self.min_health = self.hits
    self.parent:ModifyHealth(self.hits, self.ability, false, 0)
  end)

  if IsServer() then
		self:PlayEfxStart(self.parent:GetCurrentVisionRange())
		self:OnIntervalThink()
	end
end

function icebreaker_u_modifier_aura:OnRefresh(kv)
end

function icebreaker_u_modifier_aura:OnRemoved()
  if IsServer() then
		self.parent:StopSound("Hero_Icebreaker.Zero.Loop")
		self.parent:EmitSound("Ability.FrostNova")
	end

  RemoveBonus(self.ability, "_1_CON", self.parent)

  if self.parent:IsAlive() then self.parent:Kill(self.ability, nil) end
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_u_modifier_aura:CheckState()
	local state = {
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
		[MODIFIER_STATE_EVADE_DISABLED] = true
	}

  if self:GetAbility():GetSpecialValueFor("special_fly_vision") == 1 then
		table.insert(state, MODIFIER_STATE_FORCED_FLYING_VISION, true)
	end

	return state
end

function icebreaker_u_modifier_aura:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTHBAR_PIPS,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
    MODIFIER_PROPERTY_VISUAL_Z_DELTA,
    MODIFIER_PROPERTY_BONUS_DAY_VISION,
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE
	}

	return funcs
end

function icebreaker_u_modifier_aura:GetModifierHealthBarPips(keys)
	return self:GetParent():GetMaxHealth() / 4
end

function icebreaker_u_modifier_aura:OnDeath(keys)
	if keys.unit == self.parent then self:Destroy() end
end

function icebreaker_u_modifier_aura:OnAttacked(keys)
	if keys.target ~= self.parent then return end
  local hit = 1

  if keys.attacker:IsHero() then
    if keys.attacker:GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then hit = 4 else hit = 2 end
  end

  self.min_health = self.min_health - hit
end

function icebreaker_u_modifier_aura:GetDisableHealing()
	return 1
end

function icebreaker_u_modifier_aura:GetMinHealth()
	return self.min_health
end

function icebreaker_u_modifier_aura:GetModifierExtraHealthBonus()
	return self.hits - 1
end

function icebreaker_u_modifier_aura:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("ms_limit")
end

function icebreaker_u_modifier_aura:GetVisualZDelta()
	return 350
end

function icebreaker_u_modifier_aura:GetBonusDayVision()
	return self.radius_day
end

function icebreaker_u_modifier_aura:GetBonusNightVision()
	return self.radius_night
end

function icebreaker_u_modifier_aura:GetBonusVisionPercentage()
	return self.radius_percent
end

function icebreaker_u_modifier_aura:OnIntervalThink()
	local radius = self.parent:GetCurrentVisionRange()

	if self.effect_cast then
		ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(radius, radius, radius * (radius * 0.002)))
	end

  if self.damageTable.damage > 0 then
    self:StartExplosionThink(radius)
  end

	if IsServer() then
    self:StartIntervalThink(1 / (radius * 0.01))
  end
end

-- UTILS -----------------------------------------------------------

function icebreaker_u_modifier_aura:StartExplosionThink(radius)
	local point = self.parent:GetOrigin()
	local explosion_radius = 150
	local random_x = 0
	local random_y = 0

	local quarter = RandomInt(1,4)
	if quarter == 1 then
		random_x = RandomInt(-radius, radius)
		if random_x > 0 then
			random_y = RandomInt(-radius, 0)
		else
			random_y = RandomInt(-radius, 1)
		end
	elseif quarter == 2 then
		random_x = RandomInt(-radius, radius)
		if random_x > 0 then
			random_y = RandomInt(1, radius)
		else
			random_y = RandomInt(0, radius)
		end
	elseif quarter == 3 then
		random_y = RandomInt(-radius, radius)
		if random_y > 0 then
			random_x = RandomInt(-radius, 0)
		else
			random_x = RandomInt(-radius, 1)
		end
	elseif quarter == 4 then
		random_y = RandomInt(-radius, radius)
		if random_y > 0 then
			random_x = RandomInt(1, radius)
		else
			random_x = RandomInt(0, radius)
		end
	end

	local x = self:CalculateAngle(random_x, random_y)
	local y = self:CalculateAngle(random_y, random_x)

	point.x = point.x + x
	point.y = point.y + y

	self:PlayEfxExplosion(point)

	Timers:CreateTimer(0.68, function()	
		local enemies = FindUnitsInRadius(
			self.caster:GetTeamNumber(), point, nil, explosion_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			0, 0, false
		)
	
		for _,enemy in pairs(enemies) do
			self:PlayEfxHit(enemy)
			self.damageTable.victim = enemy
			ApplyDamage(self.damageTable)
		end
	end)
end

function icebreaker_u_modifier_aura:CalculateAngle(a, b)
  if a < 0 then
    if b > 0 then b = -b end
  else
    if b < 0 then b = -b end
  end
  return a - math.floor(b/4)
end

-- EFFECTS -----------------------------------------------------------

function icebreaker_u_modifier_aura:GetEffectName()
	return "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf"
end

function icebreaker_u_modifier_aura:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker_u_modifier_aura:PlayEfxStart(radius)
	local particle_1 = "particles/icebreaker/icebreaker_zero.vpcf"

	self.effect_cast = ParticleManager:CreateParticle(particle_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(radius, radius, radius * (radius * 0.002)))
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	local particle_cast = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ambient.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then
		self.parent:EmitSound("Hero_Ancient_Apparition.ColdFeetCast")
		self.parent:EmitSound("Hero_Icebreaker.Zero.Loop")
	end
end

function icebreaker_u_modifier_aura:PlayEfxExplosion(point)
	local particle_cast = "particles/units/heroes/hero_crystalmaiden_persona/cm_persona_freezing_field_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, point)

	if IsServer() then self.parent:EmitSoundParams("hero_Crystal.freezingField.explosion", 1, 0.6, 0) end
end

function icebreaker_u_modifier_aura:PlayEfxHit(enemy)
	local caster = self:GetCaster()
	local hit_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
	ParticleManager:SetParticleControl(hit_pfx, 0, enemy:GetAbsOrigin())
	ParticleManager:SetParticleControl(hit_pfx, 1, enemy:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(hit_pfx)

	if IsServer() then enemy:EmitSound("Hero_DrowRanger.Marksmanship.Target") end
end