lawbreaker_4__rain = class({})
LinkLuaModifier("lawbreaker_4_modifier_rain", "heroes/team_death/lawbreaker/lawbreaker_4_modifier_rain", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("lawbreaker_4_modifier_aura_effect", "heroes/team_death/lawbreaker/lawbreaker_4_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function lawbreaker_4__rain:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

  function lawbreaker_4__rain:OnAbilityPhaseStart()
		local caster = self:GetCaster()
    if caster:HasModifier("lawbreaker_2_modifier_combo") then return false end

    caster:StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 4)
    caster:RemoveModifierByName("lawbreaker_2_modifier_combo")

    return true
  end

  function lawbreaker_4__rain:OnAbilityPhaseInterrupted()
		local caster = self:GetCaster()
    caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
  end

	function lawbreaker_4__rain:OnSpellStart()
		local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local delay = self:GetSpecialValueFor("delay") + ((caster:GetOrigin() - point):Length2D() / 2000)

    caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
    self:PlayEfxStart(point)

    Timers:CreateTimer(delay, function()
      CreateModifierThinker(caster, self, "lawbreaker_4_modifier_rain", {
        duration = self:GetSpecialValueFor("duration")
      }, point, caster:GetTeamNumber(), false)
    end)
	end

-- EFFECTS

  function lawbreaker_4__rain:PlayEfxStart(point)
    local caster = self:GetCaster()
    local particle_cast = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(effect_cast, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetOrigin(), false)
    ParticleManager:SetParticleControl(effect_cast, 1, point + Vector(0, 0, 2000))
    ParticleManager:ReleaseParticleIndex(effect_cast)

    if IsServer() then caster:EmitSound("Hero_Sniper.MKG_ShrapnelShoot") end
  end