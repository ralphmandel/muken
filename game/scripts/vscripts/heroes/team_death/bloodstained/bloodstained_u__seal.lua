bloodstained_u__seal = class({})
LinkLuaModifier("bloodstained_u_modifier_seal", "heroes/team_death/bloodstained/bloodstained_u_modifier_seal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_u_modifier_aura_effect", "heroes/team_death/bloodstained/bloodstained_u_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_u_modifier_slow", "heroes/team_death/bloodstained/bloodstained_u_modifier_slow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_u_modifier_copy", "heroes/team_death/bloodstained/bloodstained_u_modifier_copy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_u_modifier_copy_status_efx", "heroes/team_death/bloodstained/bloodstained_u_modifier_copy_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained__modifier_extra_hp", "heroes/team_death/bloodstained/bloodstained__modifier_extra_hp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained__modifier_target_hp", "heroes/team_death/bloodstained/bloodstained__modifier_target_hp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_generic_custom_indicator", "_modifiers/_modifier_generic_custom_indicator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bleeding", "_modifiers/_modifier_bleeding", LUA_MODIFIER_MOTION_NONE)


-- INIT

  function bloodstained_u__seal:GetIntrinsicModifierName()
    return "_modifier_generic_custom_indicator"
  end

-- SPELL START

  function bloodstained_u__seal:OnSpellStart()
    local caster = self:GetCaster()

    CreateModifierThinker(
      caster, self, "bloodstained_u_modifier_seal",
      {duration = self:GetSpecialValueFor("duration")},
      self:GetCursorPosition(), caster:GetTeamNumber(), false
    )

    if IsServer() then
      caster:EmitSound("hero_bloodseeker.bloodRite")
      caster:EmitSound("hero_bloodseeker.rupture.cast")
    end
  end

-- EFFECTS

-- CUSTOM INDICATOR

  function bloodstained_u__seal:CastFilterResultLocation(vLoc)
    if IsClient() then
      if self.custom_indicator then
        self.custom_indicator:Register(vLoc)
      end
    end

    return UF_SUCCESS
  end

  function bloodstained_u__seal:CreateCustomIndicator()
    local particle_cast = "particles/bloodstained/seal_finder_aoe.vpcf"
    local radius = self:GetSpecialValueFor("radius")

    self.effect_indicator = ParticleManager:CreateParticle(particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(self.effect_indicator, 1, Vector( radius, radius, radius ))
  end

  function bloodstained_u__seal:UpdateCustomIndicator( loc )
    ParticleManager:SetParticleControl(self.effect_indicator, 0, loc)
  end

  function bloodstained_u__seal:DestroyCustomIndicator()
    ParticleManager:DestroyParticle(self.effect_indicator, false)
    ParticleManager:ReleaseParticleIndex(self.effect_indicator)
  end