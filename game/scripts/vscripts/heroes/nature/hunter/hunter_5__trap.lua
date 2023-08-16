hunter_5__trap = class({})
LinkLuaModifier("hunter_5_modifier_trap", "heroes/nature/hunter/hunter_5_modifier_trap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("hunter_5_modifier_trap_invi", "heroes/nature/hunter/hunter_5_modifier_trap_invi", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("hunter_5_modifier_debuff", "heroes/nature/hunter/hunter_5_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "_modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bleeding", "_modifiers/_modifier_bleeding", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "_modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "_modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_pull", "_modifiers/_modifier_pull", LUA_MODIFIER_MOTION_HORIZONTAL)

-- INIT

  function hunter_5__trap:GetAOERadius()
    return self:GetSpecialValueFor("trap_radius")
  end

  function hunter_5__trap:CastFilterResultLocation(vLocation)
    local caster = self:GetCaster()

    local units = FindUnitsInRadius(
      caster:GetTeamNumber(), vLocation, nil, self:GetAOERadius(),
      DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL,
      DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false
    )

    for _,unit in pairs(units) do
      return UF_FAIL_CUSTOM
    end

    local trees = GridNav:GetAllTreesAroundPoint(vLocation, self:GetAOERadius(), false)

    for _,tree in pairs(trees) do
      return UF_FAIL_CUSTOM
    end

    return UF_SUCCESS
  end

  function hunter_5__trap:GetCustomCastErrorLocation(vLocation)
    return "CANNOT SET TRAP HERE. TRY FREE LOCATION"
  end

-- SPELL START

	function hunter_5__trap:OnSpellStart()
		local caster = self:GetCaster()

    local trap = CreateUnitByName("hunter_trap", self:GetCursorPosition(), false, caster, caster, caster:GetTeamNumber())
    AddModifier(trap, self, "hunter_5_modifier_trap", {duration = self:GetSpecialValueFor("lifetime")}, false)
	end

-- EFFECTS