bocuse_5__roux = class({})
LinkLuaModifier("bocuse_5_modifier_root", "heroes/death/bocuse/bocuse_5_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_5_modifier_roux", "heroes/death/bocuse/bocuse_5_modifier_roux", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_5_modifier_roux_aura_effect", "heroes/death/bocuse/bocuse_5_modifier_roux_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "_modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_pull", "_modifiers/_modifier_pull", LUA_MODIFIER_MOTION_HORIZONTAL)

-- INIT

  function bocuse_5__roux:CastFilterResultLocation(vLocation)
    local caster = self:GetCaster()

    if vLocation.z == 0 then return UF_FAIL_CUSTOM end

    return UF_SUCCESS
  end

  function bocuse_5__roux:GetCustomCastErrorLocation(vLocation)
    return "CANNOT CAST ON WATER"
  end

  function bocuse_5__roux:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

-- SPELL START

	function bocuse_5__roux:OnSpellStart()
		local caster = self:GetCaster()

		CreateModifierThinker(caster, self, "bocuse_5_modifier_roux", {
			duration = self:GetSpecialValueFor("lifetime")
		}, self:GetCursorPosition(), caster:GetTeamNumber(), false)
	end

-- EFFECTS