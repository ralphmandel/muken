lawbreaker_3__grenade = class({})
LinkLuaModifier("lawbreaker_3_modifier_grenade", "heroes/team_death/lawbreaker/lawbreaker_3_modifier_grenade", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function lawbreaker_3__grenade:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    if caster:HasModifier("lawbreaker_2_modifier_combo") then return false end

    return true
  end

	function lawbreaker_3__grenade:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS