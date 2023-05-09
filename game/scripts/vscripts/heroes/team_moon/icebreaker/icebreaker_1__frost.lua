icebreaker_1__frost = class({})
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant", "heroes/team_moon/icebreaker/icebreaker__modifier_instant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_passive", "heroes/team_moon/icebreaker/icebreaker_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_passive_status_efx", "heroes/team_moon/icebreaker/icebreaker_1_modifier_passive_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_hits", "heroes/team_moon/icebreaker/icebreaker_1_modifier_hits", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_permanent_movespeed_buff", "modifiers/_modifier_permanent_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function icebreaker_1__frost:GetBehavior()
    if self:GetSpecialValueFor("special_hits") > 0 then
      return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    
    return DOTA_ABILITY_BEHAVIOR_PASSIVE
  end

-- SPELL START

	function icebreaker_1__frost:GetIntrinsicModifierName()
		return "icebreaker_1_modifier_passive"
	end

  function icebreaker_1__frost:OnSpellStart()
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "icebreaker_1_modifier_hits", {
      duration = CalcStatus(self:GetSpecialValueFor("special_hits_duration"), caster, caster)
    })
	end

  function icebreaker_1__frost:PerformFrostAttack(target)
    local caster = self:GetCaster()
    local bonus_damage = self:GetSpecialValueFor("special_bonus_damage")

    if bonus_damage > 0 then
      ApplyDamage({
        attacker = caster, victim = target,
        damage = bonus_damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self
      })
    end

    target:AddNewModifier(caster, self, "icebreaker__modifier_hypo", {
      stack = self:GetSpecialValueFor("hypo_stack")
    })

    if RandomFloat(0, 100) < self:GetSpecialValueFor("special_mini_freeze_chance")
    and target:HasModifier("icebreaker__modifier_frozen") == false then
      target:AddNewModifier(caster, self, "icebreaker__modifier_instant", {
        duration = CalcStatus(self:GetSpecialValueFor("special_mini_freeze"), caster, target)
      })
    end
  end

-- EFFECTS