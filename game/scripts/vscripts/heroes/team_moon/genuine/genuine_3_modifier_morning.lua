genuine_3_modifier_morning = class({})

function genuine_3_modifier_morning:IsHidden() return false end
function genuine_3_modifier_morning:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_3_modifier_morning:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.int_allies = self.ability.kills

	self.ability:EndCooldown()
	self.ability:SetActivated(false)

  AddBonus(self.ability, "_1_AGI", self.parent, self.ability:GetSpecialValueFor("agi"), 0, nil)
  AddBonus(self.ability, "_2_REC", self.parent, self.ability:GetSpecialValueFor("special_rec"), 0, nil)

  if self.ability:GetSpecialValueFor("special_ms_night") == 0 then
    AddModifier(self.parent, self.caster, self.ability, "_modifier_movespeed_buff", {
      percent = self.ability:GetSpecialValueFor("ms")
    }, false)
  end

  GameRules:BeginTemporaryNight(self:GetDuration())

  local track_duration = self.ability:GetSpecialValueFor("special_track_duration")
  local enemies = FindUnitsInRadius(
    self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, -1,
    DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
  )

  self.ability:StartStarfalls(enemies)

  for _,enemy in pairs(enemies) do
    if track_duration > 0 and enemy:IsHero() then
      AddFOWViewer(self.parent:GetTeamNumber(), enemy:GetOrigin(), 300, track_duration, false)
    end
  end

  self.allies = FindUnitsInRadius(
    self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, -1,
    DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_DEAD + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, 0, false
  )

  for _,ally in pairs(self.allies) do
    if self.ability:GetSpecialValueFor("special_int_allies") == 1 then
      if BaseStats(ally) then BaseStats(ally):AddBaseStat("INT", self.int_allies) end
    end
  end

  self.exceptions = {
		"_1_AGI_modifier_stack", "_1_CON_modifier_stack",
		"_1_INT_modifier_stack", "_1_STR_modifier_stack",
		"_2_DEF_modifier_stack", "_2_DEX_modifier_stack",
		"_2_LCK_modifier_stack", "_2_MND_modifier_stack",
		"_2_REC_modifier_stack", "_2_RES_modifier_stack",
		"_modifier_blind", "_modifier_movespeed_debuff",
    "_modifier_percent_movespeed_debuff"
	}

	if IsServer() then self.parent:EmitSound("Genuine.Morning") end
end

function genuine_3_modifier_morning:OnRefresh(kv)
end

function genuine_3_modifier_morning:OnRemoved()
  self.parent:FindModifierByName(self.ability:GetIntrinsicModifierName()):StopEfxBuff()
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self.ability:SetActivated(true)

	RemoveBonus(self.ability, "_1_AGI", self.parent)
	RemoveBonus(self.ability, "_2_REC", self.parent)

  if self.ability:GetSpecialValueFor("special_ms_night") == 0 then
    RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)
  end

  for _,ally in pairs(self.allies) do
    if self.ability:GetSpecialValueFor("special_int_allies") == 1 then
      if BaseStats(ally) then BaseStats(ally):AddBaseStat("INT", -self.int_allies) end
    end
  end
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_3_modifier_morning:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_MODIFIER_ADDED
	}
	
	return funcs
end

function genuine_3_modifier_morning:OnModifierAdded(keys)
	if keys.unit:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.added_buff:IsDebuff() == false then return end
  if CalcDistanceBetweenEntityOBB(keys.unit, self.parent) > self.ability:GetAOERadius() then return end

	for _,mod_name in pairs(self.exceptions) do
		if mod_name == keys.added_buff:GetName() then return end
	end

	local damage = ApplyDamage({
		damage = self.ability:GetSpecialValueFor("special_strike_damage"),
		attacker = self.caster, victim = keys.unit, ability = self.ability,
		damage_type = self.ability:GetAbilityDamageType()
	})

	if keys.unit then
		if IsValidEntity(keys.unit) then
			self:PlayEfxDamage(keys.unit, damage)			
		end
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function genuine_3_modifier_morning:PlayEfxDamage(target, damage)
	if damage == 0 then return end

	local particle = "particles/genuine/genuine_zap/genuine_zap_attack_heavy_ti_5.vpcf"
	local zap_pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControlEnt(zap_pfx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(zap_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(zap_pfx)

	if IsServer() then
		self.parent:EmitSound("Hero_Pugna.NetherWard.Attack")
		target:EmitSound("Hero_Pugna.NetherWard.Target")
	end
end