hunter_5__trap = class({})
LinkLuaModifier("hunter_5_modifier_trap", "heroes/nature/hunter/hunter_5_modifier_trap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("hunter_5_modifier_debuff", "heroes/nature/hunter/hunter_5_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "_modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bleeding", "_modifiers/_modifier_bleeding", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "_modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "_modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function hunter_5__trap:GetAOERadius()
    return self:GetSpecialValueFor("trap_radius")
  end

-- SPELL START

	function hunter_5__trap:OnSpellStart()
		local caster = self:GetCaster()

    local trap = CreateUnitByName("hunter_trap", self:GetCursorPosition(), false, nil, nil, caster:GetTeamNumber())
    AddModifier(trap, self, "hunter_5_modifier_trap", {duration = self:GetSpecialValueFor("lifetime")}, false)
	end

-- EFFECTS