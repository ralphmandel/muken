druid_3_modifier_totem = class({})

function druid_3_modifier_totem:IsHidden() return false end
function druid_3_modifier_totem:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_3_modifier_totem:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.spike_damage = self.ability:GetSpecialValueFor("special_spike_damage")
  self.flame_duration = self.ability:GetSpecialValueFor("special_flame_duration")
  self.hits = self.ability:GetSpecialValueFor("hits") * 4
  self.min_health = self.hits
  self.radius = self.ability:GetAOERadius()

  AddBonus(self.ability, "CON", self.parent, -9999, 0, nil)

  Timers:CreateTimer(FrameTime(), function()
    self.parent:ModifyHealth(self.hits, self.ability, false, 0)
  end)

	if IsServer() then
		self:PlayEfxStart(self.flame_duration > 0)
    self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
	end
end

function druid_3_modifier_totem:OnRefresh(kv)
end

function druid_3_modifier_totem:OnRemoved()
	if IsServer() then
		self.parent:StopSound("Hero_Juggernaut.FortunesTout.Loop")
		self.parent:EmitSound("Hero_Juggernaut.HealingWard.Stop")
    self.parent:StopSound("Igneo.Burn.Loop")
	end

  RemoveBonus(self.ability, "CON", self.parent)

	if self.ambient then ParticleManager:DestroyParticle(self.ambient, false) end
	if self.burn_particle then ParticleManager:DestroyParticle(self.burn_particle, false) end
	if self.parent:IsAlive() then self.parent:ForceKill(false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_3_modifier_totem:CheckState()
	local state = {
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
		[MODIFIER_STATE_EVADE_DISABLED] = true
	}

	return state
end

function druid_3_modifier_totem:DeclareFunctions()
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
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}

	return funcs
end

function druid_3_modifier_totem:GetModifierHealthBarPips(keys)
	return self:GetParent():GetMaxHealth() / 4
	--return self:GetParent():GetMaxHealth() / (self:GetParent():GetMaxHealth() / 5)
end

function druid_3_modifier_totem:OnDeath(keys)
	if keys.unit == self.parent then self:Destroy() end
end

function druid_3_modifier_totem:OnAttacked(keys)
	if keys.target ~= self.parent then return end
  self.min_health = self.min_health - GetPipHitDamage(keys.attacker)
end

function druid_3_modifier_totem:GetDisableHealing()
	return 1
end

function druid_3_modifier_totem:GetMinHealth()
	return self.min_health
end

function druid_3_modifier_totem:GetModifierExtraHealthBonus()
	return self.hits - 1
end

function druid_3_modifier_totem:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("ms_limit")
end

function druid_3_modifier_totem:GetVisualZDelta()
	return 150
end

function druid_3_modifier_totem:GetBonusDayVision()
	return self.radius
end

function druid_3_modifier_totem:GetBonusNightVision()
	return self.radius
end

function druid_3_modifier_totem:OnIntervalThink()
  local heal = self.ability:GetSpecialValueFor("heal") * BaseStats(self.caster):GetHealPower()
  local mana = self.ability:GetSpecialValueFor("mana") * BaseStats(self.caster):GetHealPower()

	local allies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius,
		self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
		self.ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
	)

	for _,ally in pairs(allies) do
    if ally ~= self.parent then
      ally:Heal(heal, self.ability)
      if ally:GetMaxMana() > 0 then
        IncreaseMana(ally, mana)
      end
    end
	end

  local enemies = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    0, 0, false
  )

  for _,enemy in pairs(enemies) do
    self:ApplySpike(enemy)
    self:ApplyFlame(enemy)
  end

  if IsServer() then
    self:PlayEfxQuill(self.spike_damage > 0)
    self:PlayEfxBurn(self.flame_duration > 0)
    self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
  end
end

-- UTILS -----------------------------------------------------------

function druid_3_modifier_totem:ApplySpike(target)
  if self.spike_damage <= 0 then return end

  self:PlayEfxQuillImpact(target)
  AddModifier(target, self.ability, "_modifier_stun", {duration = 0.5}, false)

  ApplyDamage({
    attacker = self.caster, victim = target,
    damage = self.spike_damage,
    damage_type = DAMAGE_TYPE_PHYSICAL,
    ability = self.ability
  })
end

function druid_3_modifier_totem:ApplyFlame(target)
  AddModifier(target, self.ability, "druid_3_modifier_flame", {duration = self.flame_duration}, true)
end

-- EFFECTS -----------------------------------------------------------

function druid_3_modifier_totem:PlayEfxStart(isBurn)
	local eruption_string = "particles/econ/items/juggernaut/bladekeeper_healing_ward/juggernaut_healing_ward_eruption_dc.vpcf"
	local eruption_pfx = ParticleManager:CreateParticle(eruption_string, PATTACH_CUSTOMORIGIN, self.parent)
	ParticleManager:SetParticleControl(eruption_pfx, 0, self.parent:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(eruption_pfx)

	local ambient_string = "particles/econ/items/juggernaut/jugg_fall20_immortal/jugg_fall20_immortal_healing_ward.vpcf"
	self.ambient = ParticleManager:CreateParticle(ambient_string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.ambient, 0, self.parent:GetAbsOrigin() + Vector(0, 0, 100))
	ParticleManager:SetParticleControl(self.ambient, 1, Vector(self.radius, 1, 1))
	ParticleManager:SetParticleControlEnt(self.ambient, 2, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)

  if isBurn then
    local burn_string = "particles/econ/items/phoenix/eye_of_the_sun/phoenix_supernova_egg_eye_sun_loadout.vpcf"
    self.burn_particle = ParticleManager:CreateParticle(burn_string, PATTACH_POINT_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.burn_particle, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.burn_particle, 1, Vector(self.radius, self.radius, self.radius))
    
    if IsServer() then
      self.parent:StopSound("Igneo.Burn.Loop")
      self.parent:EmitSound("Igneo.Burn.Loop")
    end
  end

	if IsServer() then self.parent:EmitSound("Hero_Juggernaut.FortunesTout.Loop") end
end

function druid_3_modifier_totem:PlayEfxQuill(isQuill)
  if isQuill == false then return end
	local particle_cast = "particles/druid/druid_lotus/lotus_quill.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 10, Vector(self.radius, 0, 0))
	ParticleManager:SetParticleControl(effect_cast, 61, Vector(1, 0, 1))
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.parent:EmitSound("Hero_Bristleback.QuillSpray.Cast") end
end

function druid_3_modifier_totem:PlayEfxQuillImpact(target)
	local particle_cast = "particles/units/heroes/hero_bristleback/bristleback_quill_spray_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Hero_Bristleback.QuillSpray.Target") end
end

function druid_3_modifier_totem:PlayEfxBurn(isBurn)
  if isBurn == false then return end
  local string = "particles/druid/flame_flower/druid_flame_flower_wave.vpcf"
	local pfx = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(pfx, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, Vector(self.radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx)

  if IsServer() then
    self.parent:StopSound("Igneo.Burn.Loop")
    self.parent:EmitSound("Igneo.Burn.Loop")
    self.parent:EmitSound("Hero_Batrider.Flamebreak.Impact")
  end
end