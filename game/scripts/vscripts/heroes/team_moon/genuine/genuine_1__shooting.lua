genuine_1__shooting = class({})
LinkLuaModifier("genuine_1_modifier_orb", "heroes/team_moon/genuine/genuine_1_modifier_orb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_1_modifier_starfall_stack", "heroes/team_moon/genuine/genuine_1_modifier_starfall_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "_modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear", "_modifiers/_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear_status_efx", "_modifiers/_modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function genuine_1__shooting:Spawn()
    Timers:CreateTimer(0.2, function()
      if self:IsTrained() == false then
        self:UpgradeAbility(true)
        BaseStats(self:GetCaster()):AddManaExtra(self)
      end
    end)
  end

  function genuine_1__shooting:GetIntrinsicModifierName()
		return "genuine_1_modifier_orb"
	end

	function genuine_1__shooting:GetProjectileName()
		return "particles/genuine/shooting_star/genuine_shooting.vpcf"
	end

-- SPELL START

  function genuine_1__shooting:OnOrbFire(keys)
    local caster = self:GetCaster()
    if IsServer() then caster:EmitSound("Hero_DrowRanger.FrostArrows") end
  end

  function genuine_1__shooting:OnOrbImpact(keys)
    local caster = self:GetCaster()
    if IsServer() then keys.target:EmitSound("Hero_DrowRanger.Marksmanship.Target") end

    if GameRules:IsDaytime() == false or GameRules:IsTemporaryNight() then
      local mana_steal = keys.target:GetMaxMana() * self:GetSpecialValueFor("special_mana_steal") * 0.01
      StealMana(keys.target, caster, self, mana_steal, true)
    end

    if self:IsCooldownReady() and keys.target:IsMagicImmune() == false then
      local silence = AddModifier(keys.target, caster, self, "_modifier_silence", {
        duration = self:GetSpecialValueFor("special_silence_duration")
      }, true)

      if silence then self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel())) end
    end

    if RandomFloat(0, 100) < self:GetSpecialValueFor("special_fear_chance")
    and self:IsCooldownReady() and keys.target:IsMagicImmune() == false then
      local fear = AddModifier(keys.target, caster, self, "_modifier_fear", {
        duration = self:GetSpecialValueFor("special_fear_duration"), special = 1
      }, true)

      if fear then self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel())) end
    end

    if self:GetSpecialValueFor("special_starfall_combo") > 0 then
      AddModifier(keys.target, caster, self, "genuine_1_modifier_starfall_stack", {duration = 3}, false)
    end

    ApplyDamage({
      victim = keys.target, attacker = caster,
      damage = self:GetSpecialValueFor("damage"),
      damage_type = self:GetAbilityDamageType(),
      ability = self
    })
  end

  function genuine_1__shooting:OnOrbFail(keys)
  end

-- EFFECTS