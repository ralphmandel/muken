ancient_5__petrify = class({})
LinkLuaModifier("_modifier_petrified", "modifiers/_modifier_petrified", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_petrified_status_efx", "modifiers/_modifier_petrified_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function ancient_5__petrify:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("cast_range")
  end

-- SPELL START

  function ancient_5__petrify:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    caster:FadeGesture(ACT_DOTA_TAUNT)
    caster:AddActivityModifier("taunt_2022")
    caster:AddActivityModifier("ti7")
    caster:StartGesture(ACT_DOTA_TAUNT)
    
    return true
  end

  function ancient_5__petrify:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    caster:FadeGesture(ACT_DOTA_TAUNT)
	end

	function ancient_5__petrify:OnSpellStart()
		local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    caster:FadeGesture(ACT_DOTA_TAUNT)

    if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			if target:TriggerSpellAbsorb(self) then return end
		end

    self:PlayEfxStart(target)

    AddModifier(target, caster, self, "_modifier_petrified", {
      duration = self:GetSpecialValueFor("duration")
    }, true)
	end

-- EFFECTS

  function ancient_5__petrify:PlayEfxStart(target)
    local string = "particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf"
    local pfx = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(pfx)

    local string_2 = "particles/units/heroes/hero_chen/chen_penitence.vpcf"
    local pfx_2 = ParticleManager:CreateParticle(string_2, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(pfx_2, 0, target:GetOrigin())
    ParticleManager:ReleaseParticleIndex(pfx_2)
  end